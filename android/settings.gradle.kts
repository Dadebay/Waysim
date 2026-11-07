pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    id("com.google.firebase.crashlytics") version("3.0.7") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")

// Flutter 3.47 scans plugin build files for KGP declarations even when the
// declaration is guarded by FlutterFire's AGP 9 / built-in Kotlin check.
// Use generated build scripts that omit only that unused fallback branch.
if (providers.gradleProperty("android.builtInKotlin").orNull == "true") {
    val kgpFallback =
        Regex("""(?m)^if \(agpMajor < 9 \|\| !builtInKotlin\) \{\s*apply plugin: 'kotlin-android'\s*\}""")
    val generatedDir = file(".gradle/flutterfire-built-in-kotlin")

    listOf("firebase_analytics", "firebase_app_check", "firebase_core", "firebase_crashlytics")
        .forEach { pluginName ->
            val plugin = project(":$pluginName")
            val original = plugin.projectDir.resolve("build.gradle").readText()
            check(kgpFallback.findAll(original).count() == 1) {
                "Expected one KGP fallback in $pluginName; inspect its updated Gradle script."
            }
            val migrated = original.replace(kgpFallback, "")
            val generated = generatedDir.resolve("$pluginName.gradle")
            generated.parentFile.mkdirs()
            if (!generated.exists() || generated.readText() != migrated) {
                generated.writeText(migrated)
            }
            plugin.buildFileName = plugin.projectDir.toPath().relativize(generated.toPath()).toString()
        }
}
