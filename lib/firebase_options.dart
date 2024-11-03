// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA61X6DFnBvtdRlc-I6ggs-sIqZ5MnWmSE',
    appId: '1:384917567101:web:acd7993370a48c1879e314',
    messagingSenderId: '384917567101',
    projectId: 'my-flutter-project-56fb5',
    authDomain: 'my-flutter-project-56fb5.firebaseapp.com',
    storageBucket: 'my-flutter-project-56fb5.appspot.com',
    measurementId: 'G-8VL1QJ5EJX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsDEYlvbP21VrC6KW9cRUI-G60tDy0U_4',
    appId: '1:384917567101:android:f559c0640f4e01a079e314',
    messagingSenderId: '384917567101',
    projectId: 'my-flutter-project-56fb5',
    storageBucket: 'my-flutter-project-56fb5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9azyJMi1A4xrW4AiY417IPzWNS6ZW7gU',
    appId: '1:384917567101:ios:2f2e135a2c78993b79e314',
    messagingSenderId: '384917567101',
    projectId: 'my-flutter-project-56fb5',
    storageBucket: 'my-flutter-project-56fb5.appspot.com',
    iosBundleId: 'com.example.miniProjet',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD9azyJMi1A4xrW4AiY417IPzWNS6ZW7gU',
    appId: '1:384917567101:ios:2f2e135a2c78993b79e314',
    messagingSenderId: '384917567101',
    projectId: 'my-flutter-project-56fb5',
    storageBucket: 'my-flutter-project-56fb5.appspot.com',
    iosBundleId: 'com.example.miniProjet',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA61X6DFnBvtdRlc-I6ggs-sIqZ5MnWmSE',
    appId: '1:384917567101:web:aa0fda7f94519d3079e314',
    messagingSenderId: '384917567101',
    projectId: 'my-flutter-project-56fb5',
    authDomain: 'my-flutter-project-56fb5.firebaseapp.com',
    storageBucket: 'my-flutter-project-56fb5.appspot.com',
    measurementId: 'G-QFZE62YBNP',
  );
}
