# Notes & Reminders App

A Flutter application to manage notes, schedule reminders, transcribe speech, play text aloud, and chat with Gemini AI.

## Features

* Create, edit, and organize notes backed by Firebase.
* Schedule reminders with local notifications.
* Voice dictation to turn speech into notes.
* Text‑to‑speech playback for notes.
* Chat with Gemini for analysis or conversational replies.

## Firebase Configuration

1. Create a Firebase project and enable Firestore and Authentication (anonymous sign‑in).
2. Run `flutterfire configure` and replace the placeholder values in `lib/firebase_options.dart`.
3. Download your `google-services.json` and `GoogleService-Info.plist` files and place them in `android/app/` and `ios/Runner/`.
4. Rebuild the app so Firebase can initialize with your settings.

## API Keys

The app reads API keys from Dart defines or environment variables.

* **Gemini** – `GEMINI_API_KEY`
* **Text‑to‑Speech** – `TTS_API_KEY`

Pass the keys when running or building:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_gemini_key \
             --dart-define=TTS_API_KEY=your_tts_key
```

Use the same `--dart-define` flags for `flutter build` commands.

## Platform Permissions

### Android

The manifest requests:

* `INTERNET` – access Gemini and TTS APIs.
* `POST_NOTIFICATIONS` – show reminders on Android 13+.
* `SCHEDULE_EXACT_ALARM` – schedule precise alarms.

### iOS

Add to `ios/Runner/Info.plist`:

* `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` for voice input.
* Notification permissions for alerts, badges, and sounds are requested at runtime.

## Build & Run

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=your_gemini_key \
           --dart-define=TTS_API_KEY=your_tts_key
```

### Building for release

```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_gemini_key \
                 --dart-define=TTS_API_KEY=your_tts_key
flutter build ios --dart-define=GEMINI_API_KEY=your_gemini_key \
                 --dart-define=TTS_API_KEY=your_tts_key
```

Run the tests with:

```bash
flutter test
```


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
