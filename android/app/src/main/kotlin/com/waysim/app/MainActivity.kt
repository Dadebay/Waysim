package com.waysim.app

import android.content.Context
import android.os.Build
import android.telephony.euicc.EuiccManager
import android.view.WindowInsets
import android.view.WindowInsetsController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) hideNavigationBar()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.waysim.app/system_ui")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideNavigationBar" -> {
                        hideNavigationBar()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.waysim.app/esim")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEsimSupported" -> result.success(isEsimSupported())
                    else -> result.notImplemented()
                }
            }
    }

    private fun hideNavigationBar() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return
        window.insetsController?.apply {
            systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            hide(WindowInsets.Type.navigationBars())
        }
    }

    /**
     * true / false from the platform; null when the answer cannot be read.
     * EuiccManager exists from Android 9 (API 28); older phones have no eSIM.
     */
    private fun isEsimSupported(): Boolean? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return false
        if (!packageManager.hasSystemFeature("android.hardware.telephony.euicc")) return false
        val manager = getSystemService(Context.EUICC_SERVICE) as? EuiccManager ?: return null
        return manager.isEnabled
    }
}
