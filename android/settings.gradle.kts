pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    // dùng biến môi trường FLUTTER_ROOT thay vì Properties lằng nhằng
    val flutterRoot = System.getenv("FLUTTER_ROOT")
        ?: throw GradleException("FLUTTER_ROOT not set; export it to your Flutter SDK path")
    includeBuild("$flutterRoot/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "notes_reminder_app"
include(":app")
