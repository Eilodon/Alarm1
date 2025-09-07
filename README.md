# Notes & Reminders App

A Flutter application to manage notes, schedule reminders, transcribe speech, play text aloud, and chat with Gemini AI.

For an overview of how the app is structured, see the architecture documentation in [Vietnamese](docs/ARCHITECTURE.md) or [English](docs/ARCHITECTURE_en.md), including the AuthService flow and ConnectivityService strategy.

## Quick Setup

1. Copy `.env.example` to `.env` and add your API keys.
2. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
3. Launch the app:

   ```bash
   flutter run --dart-define-from-file=.env
   ```

## Features

* Create, edit, and organize notes backed by Firebase.
* Schedule reminders with local notifications.
* Voice dictation to turn speech into notes.
* Text‑to‑speech playback for notes.
* Chat with Gemini for analysis or conversational replies.
* Backup and restore encrypted notes with an optional password.
* Notes waiting to sync display a warning icon (e.g., `sync_problem`) and upload automatically when connectivity returns.
* Swipe notes to pin, share, or delete. Long‑press a note to mark it done, set a reminder, or share.

## Firebase Configuration

1. Create a Firebase project and enable Firestore and Authentication (anonymous sign‑in).
2. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
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

## Voice Commands

### Android

1. Open **Settings > Apps > Default apps > Assist app** and choose *Notes Reminder App*.
2. Long-press the home button or use the assist gesture and speak to create a note.

### iOS

1. Open the Shortcuts app and add the **Create Note** shortcut from Notes Reminder App.
2. Say “Hey Siri, create note” to launch the app and dictate your note.

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

## Backup & Restore

Use the backup feature to export your notes to an encrypted JSON file. Each
note is encrypted with AES‑GCM. When exporting, you may supply a password to
derive the encryption key. If you leave the password blank, the key stored in
secure storage on the device is used instead.

To restore notes, choose the backup file and enter the same password you used
when exporting (or leave it blank to use the device key). The imported notes
will replace the existing ones on the device.


## Troubleshooting

### Firebase fails to connect

* Ensure you are logged into Firebase and have access to the project by running `firebase login` and `firebase projects:list`.
* Confirm `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist` are correctly placed.
* Rebuild after fixing the configuration:

  ```bash
  flutter clean
  flutter run --dart-define=GEMINI_API_KEY=your_gemini_key \
             --dart-define=TTS_API_KEY=your_tts_key
  ```

### Missing API key

* Provide `GEMINI_API_KEY` and `TTS_API_KEY` using `--dart-define` or environment variables.
* After adding the keys, rerun the app with the commands above.

### No network connection

* Check that the device or emulator has internet access.
* Once the network is restored, run the clean and run commands again to restart the app.



## Contributing

CI runs dependency checks on every pull request. Before submitting your changes, make sure the following commands complete without conflicts or incompatible constraints:

```bash
flutter pub outdated
flutter pub outdated --mode=null-safety --exit-code
```

Resolve any reported issues so the automated workflow can pass before your PR is merged.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

