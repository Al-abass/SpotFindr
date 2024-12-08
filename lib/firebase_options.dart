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
    apiKey: 'AIzaSyBXRS7R9suvSgyGMvD--0hyeyqvSrEfk0s',
    appId: '1:709196753681:web:4ec5973444094354b27ab0',
    messagingSenderId: '709196753681',
    projectId: 'spotfindr-c941e',
    authDomain: 'spotfindr-c941e.firebaseapp.com',
    storageBucket: 'spotfindr-c941e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLmcz8Tj_wYgKqYZGNZnQyWJvSiyBavts',
    appId: '1:709196753681:android:992b03fa5831c791b27ab0',
    messagingSenderId: '709196753681',
    projectId: 'spotfindr-c941e',
    storageBucket: 'spotfindr-c941e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtM5bbvnVzHW8Rg_47IFfKTL_SZmHaZJw',
    appId: '1:709196753681:ios:7e65eb0510c3ec09b27ab0',
    messagingSenderId: '709196753681',
    projectId: 'spotfindr-c941e',
    storageBucket: 'spotfindr-c941e.firebasestorage.app',
    iosBundleId: 'com.example.spotfinder',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtM5bbvnVzHW8Rg_47IFfKTL_SZmHaZJw',
    appId: '1:709196753681:ios:7e65eb0510c3ec09b27ab0',
    messagingSenderId: '709196753681',
    projectId: 'spotfindr-c941e',
    storageBucket: 'spotfindr-c941e.firebasestorage.app',
    iosBundleId: 'com.example.spotfinder',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBXRS7R9suvSgyGMvD--0hyeyqvSrEfk0s',
    appId: '1:709196753681:web:e0907da27a4a0559b27ab0',
    messagingSenderId: '709196753681',
    projectId: 'spotfindr-c941e',
    authDomain: 'spotfindr-c941e.firebaseapp.com',
    storageBucket: 'spotfindr-c941e.firebasestorage.app',
  );

}