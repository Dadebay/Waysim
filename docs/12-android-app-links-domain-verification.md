# Waysim Android App Links: domain verification fix

Please update the **website deployment** for `waysim.co`. The Android app does not need a new build for this fix.

## Observed failure (5 November 2026)

Google Play Console → Waysim → Deep links reports **1 domain not verified** and **3 links not working**. All three links use `waysim.co` (`/r/…`, `/<locale>/r/…`, and `/pay/…`). The app's manifest already declares these HTTPS paths with `android:autoVerify="true"`.

`https://waysim.co/.well-known/assetlinks.json` currently returns HTTP 200, `Content-Type: application/json`, with no redirect. Its only SHA-256 fingerprint is:

```text
1A:17:C7:F4:62:32:BE:A2:94:A6:2C:BB:85:12:24:F6:EF:13:BD:6C:64:EF:61:47:80:E7:A7:41:A0:49:67:E0
```

Google Play Console → Waysim → Protected with Play → App signing shows the **current Play app signing certificate** and Digital Asset Links snippet with this different SHA-256 fingerprint:

```text
1B:AB:34:23:5A:BA:12:C8:8E:13:10:0C:68:18:86:E4:AC:FC:E8:2B:BD:A8:0C:AC:69:53:A1:6A:72:89:30:C8
```

The locally signed upload APK has yet another fingerprint (`D3:FF:3D:65:…`). Do **not** use the upload key instead of the Play app signing key for production App Links: Play re-signs the app delivered to users.

## Required website change

At the exact path `https://waysim.co/.well-known/assetlinks.json`, publish this JSON (or add the new fingerprint to the existing `sha256_cert_fingerprints` array):

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.waysim.app",
      "sha256_cert_fingerprints": [
        "1B:AB:34:23:5A:BA:12:C8:8E:13:10:0C:68:18:86:E4:AC:FC:E8:2B:BD:A8:0C:AC:69:53:A1:6A:72:89:30:C8"
      ]
    }
  }
]
```

If the old `1A:17:…:67:E0` fingerprint belongs to a **previous Play app signing certificate** still used by installed versions, retain it as a second array value. Otherwise remove it. Play Console's current certificate must be present either way. Do not change the package name or relation.

## Deployment checks

1. Serve the file over HTTPS at the **apex host** `waysim.co`, with HTTP 200, `Content-Type: application/json`, and no redirect, login, or HTML response. Keep `.well-known` in the URL.
2. After deployment, run:

   ```sh
   curl -fsS -D /tmp/waysim-assetlinks-headers \
     -o /tmp/waysim-assetlinks.json \
     https://waysim.co/.well-known/assetlinks.json
   jq -r '.[].target.sha256_cert_fingerprints[]' /tmp/waysim-assetlinks.json
   ```

   Confirm the full `1B:AB:…:30:C8` fingerprint appears in the output and that the response headers show `200` and `application/json` without a `Location` header.
3. Recheck `waysim.co` in Google Play Console → Waysim → Deep links. The website currently sends `Cache-Control: public, max-age=3600`, so allow for caching and Google's verification delay. The three link errors should clear when the domain verifies.
4. On a Play-installed Android device, recheck with `adb shell pm verify-app-links --re-verify com.waysim.app` and `adb shell pm get-app-links com.waysim.app`; `waysim.co` should show as verified. A debug or locally uploaded APK may have a different signing certificate and is not a valid substitute for the Play-installed build in this check.

Reference: [Android's official App Links website association guide](https://developer.android.com/training/app-links/configure-assetlinks).
