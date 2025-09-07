import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    authDomain: 'test',
    storageBucket: 'test',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    storageBucket: 'test',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    iosClientId: 'test',
    iosBundleId: 'test',
    storageBucket: 'test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    iosClientId: 'test',
    iosBundleId: 'test',
    storageBucket: 'test',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    storageBucket: 'test',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
    storageBucket: 'test',
  );
}
