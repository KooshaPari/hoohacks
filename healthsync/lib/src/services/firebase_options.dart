// File: firebase_options.dart
// This is a placeholder configuration file for Firebase.
// For production, generate this file using 'flutterfire configure'

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for your app
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Placeholder Firebase configuration options for Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: 'placeholder-app-id',
    messagingSenderId: 'placeholder-sender-id',
    projectId: 'placeholder-project-id',
    authDomain: 'placeholder-auth-domain',
    storageBucket: 'placeholder-storage-bucket',
  );

  // Placeholder Firebase configuration options for Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: 'placeholder-app-id',
    messagingSenderId: 'placeholder-sender-id',
    projectId: 'placeholder-project-id',
    storageBucket: 'placeholder-storage-bucket',
  );

  // Placeholder Firebase configuration options for iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: 'placeholder-app-id',
    messagingSenderId: 'placeholder-sender-id',
    projectId: 'placeholder-project-id',
    storageBucket: 'placeholder-storage-bucket',
    iosClientId: 'placeholder-ios-client-id',
    iosBundleId: 'com.phenotype.healthsync',
  );

  // Placeholder Firebase configuration options for macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: 'placeholder-app-id',
    messagingSenderId: 'placeholder-sender-id',
    projectId: 'placeholder-project-id',
    storageBucket: 'placeholder-storage-bucket',
    iosClientId: 'placeholder-ios-client-id',
    iosBundleId: 'com.phenotype.healthsync',
  );
}
