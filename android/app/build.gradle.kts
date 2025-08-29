plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.notes_reminder_app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.notes_reminder_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    // bật core library desugaring
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // dùng debug keystore có sẵn
    signingConfigs {
        getByName("debug")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // thư viện desugar để hỗ trợ Java 8+ cho AAR
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
