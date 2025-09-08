import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
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

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "android"
include(":app")
