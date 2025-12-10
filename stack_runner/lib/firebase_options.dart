import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'fake-android-api-key',
    appId: '1:1234567890:android:stackrunnerfake',
    messagingSenderId: '1234567890',
    projectId: 'stack-runner-game',
    storageBucket: 'stack-runner-game.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'fake-ios-api-key',
    appId: '1:1234567890:ios:stackrunnerfake',
    messagingSenderId: '1234567890',
    projectId: 'stack-runner-game',
    storageBucket: 'stack-runner-game.appspot.com',
    iosBundleId: 'com.example.stackRunner',
  );
}
