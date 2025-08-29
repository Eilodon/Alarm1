#!/usr/bin/env bash
set -e

REQUIRED_AGP="8.1.1"
REQUIRED_GRADLE="8.7"

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

# Nâng Gradle Wrapper lên
echo "Setting Gradle wrapper to $REQUIRED_GRADLE"
sed -i \
  's#distributionUrl=.*#distributionUrl=https\://services.gradle.org/distributions/gradle-'$REQUIRED_GRADLE'-all.zip#' \
  android/gradle/wrapper/gradle-wrapper.properties

# Clean, get packages, build và cài APK
flutter clean
flutter pub get
flutter build apk --release --android-skip-build-dependency-validation
adb install -r build/app/outputs/flutter-apk/app-release.apk

echo "✅ Done"
