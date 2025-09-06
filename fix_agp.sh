#!/usr/bin/env bash
set -e

REQUIRED_AGP="8.1.1"
REQUIRED_GRADLE="8.1"
REQUIRED_KOTLIN="1.9.23"

# Đọc phiên bản AGP đang dùng
CURRENT_AGP=$(grep 'com.android.application' -n android/settings.gradle.kts \
  | sed -E 's/.*version "([^"]+)".*/\1/' || echo "")
echo "Current AGP version: ${CURRENT_AGP:-not found}"

# Cập nhật AGP nếu cần
if [ -z "$CURRENT_AGP" ] || [ "$(printf '%s\n' "$CURRENT_AGP" "$REQUIRED_AGP" | sort -V | head -n1)" != "$REQUIRED_AGP" ]; then
  echo "Updating Android Gradle Plugin to $REQUIRED_AGP"
  sed -i \
    's/id("com.android.application") version "[^"]\+"/id("com.android.application") version "'$REQUIRED_AGP'" apply false/' \
    android/settings.gradle.kts
else
  echo "AGP already ≥ $REQUIRED_AGP"
fi

# Đọc phiên bản Kotlin plugin đang dùng
CURRENT_KOTLIN=$(grep 'org.jetbrains.kotlin.android' -n android/settings.gradle.kts \
  | sed -E 's/.*version "([^"]+)".*/\1/' || echo "")
echo "Current Kotlin version: ${CURRENT_KOTLIN:-not found}"

# Cập nhật Kotlin plugin nếu cần
if [ -z "$CURRENT_KOTLIN" ] || [ "$(printf '%s\n' "$CURRENT_KOTLIN" "$REQUIRED_KOTLIN" | sort -V | head -n1)" != "$REQUIRED_KOTLIN" ]; then
  echo "Updating Kotlin plugin to $REQUIRED_KOTLIN"
  sed -i \
    's/id("org.jetbrains.kotlin.android") version "[^"]\+"/id("org.jetbrains.kotlin.android") version "'$REQUIRED_KOTLIN'" apply false/' \
    android/settings.gradle.kts
else
  echo "Kotlin plugin already ≥ $REQUIRED_KOTLIN"
fi

# Nâng Gradle Wrapper lên
echo "Setting Gradle wrapper to $REQUIRED_GRADLE"
sed -i \
  's#distributionUrl=.*#distributionUrl=https\://services.gradle.org/distributions/gradle-'$REQUIRED_GRADLE'-bin.zip#' \
  android/gradle/wrapper/gradle-wrapper.properties

# Clean, check dependencies, build và cài APK
flutter clean
flutter pub get

# Kiểm tra nhanh môi trường và phụ thuộc
flutter doctor
(cd android && ./gradlew app:dependencies)

flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

echo "✅ Done"
