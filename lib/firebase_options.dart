// Firebase configuration for the My Wallet app (web).
//
// This mirrors the file that `flutterfire configure` would generate. It is set
// up for the Web platform (the app is demoed in Chrome). To add Android/iOS,
// register those apps in the Firebase console or run `flutterfire configure`.
//
// Note: the web apiKey is NOT a secret — it is meant to live in client code;
// access is controlled by Firestore security rules.
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
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions is only configured for web. '
          'Run the app with `flutter run -d chrome`, or run '
          '`flutterfire configure` to add other platforms.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7wQc29BEjPyZ-YjCdn56oESjq-S8hIc0',
    appId: '1:272186846996:web:833685644f88791cbedc01',
    messagingSenderId: '272186846996',
    projectId: 'des3113-7d1fe',
    authDomain: 'des3113-7d1fe.firebaseapp.com',
    storageBucket: 'des3113-7d1fe.firebasestorage.app',
    measurementId: 'G-PNVEMDWBL7',
  );
}
