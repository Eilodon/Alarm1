import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

flutter {
    // Trỏ về thư mục project Flutter
    source = "../.."
}

// Load release keystore nếu có
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.reader(Charsets.UTF_8).use { keystoreProperties.load(it) }
}

android {
    namespace = "pandora.a123"
    compileSdk = flutter.compileSdk

    defaultConfig {
    applicationId = "pandora.a123"
    minSdk = flutter.minSdk
    targetSdk = flutter.targetSdk
        versionCode = (project.findProperty("flutter.versionCode") as String?)?.toInt() ?: 1
        versionName = (project.findProperty("flutter.versionName") as String?) ?: "1.0.0"
        multiDexEnabled = true
    }

    signingConfigs {
        getByName("debug") {
            // debug dùng keystore mặc định của Android Studio
        }
        create("release") {
            // Nếu có key.properties thì dùng, không thì bỏ qua để cấu hình sau
            if (keystoreProperties.isNotEmpty()) {
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        @Suppress("UnstableApiUsage")
        coreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        // Tuỳ chọn: loại trừ nếu gặp trùng lặp license/resources
        resources.excludes += setOf(
            "META-INF/AL2.0",
            "META-INF/LGPL2.1",
        )
    }
}

dependencies {
    // Desugaring cho Java 8+ APIs trên minSdk thấp
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // AndroidX cơ bản
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity-ktx:1.9.2")
    implementation("androidx.fragment:fragment-ktx:1.8.3")
    implementation("androidx.preference:preference-ktx:1.2.1")

    // (Tuỳ nhu cầu) Firebase BOM + libs runtime nếu bạn dùng
    // implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
    // implementation("com.google.firebase:firebase-analytics-ktx")
    // implementation("com.google.firebase:firebase-crashlytics-ktx")
}
