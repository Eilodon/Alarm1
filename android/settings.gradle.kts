import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id("com.android.application") version "8.6.1" apply false
        // Note: using 'com.google.gms.google-services' (correct id) instead of the typo in the request
        id("com.google.gms.google-services") version "4.4.2" apply false
        id("com.google.firebase.crashlytics") version "3.0.2" apply false
    }

    // Tìm Flutter SDK và include Flutter Gradle plugin
    val localProperties = Properties()
    val localPropertiesFile = File(rootDir, "local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.reader(Charsets.UTF_8).use { localProperties.load(it) }
    }
    val flutterSdkPath = localProperties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_SDK")
    check(!flutterSdkPath.isNullOrBlank()) {
        "Flutter SDK not found. Define 'flutter.sdk' in local.properties or set FLUTTER_SDK env var."
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

// Flutter plugin loader
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        maven {
            val p = Properties()
            val f = File(rootDir, "local.properties")
            if (f.exists()) f.inputStream().use { p.load(it) }
            val sdk = p.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_SDK")
            url = uri("${sdk}/bin/cache/artifacts/engine")
        }
    }
}

rootProject.name = "android"
include(":app")
