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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGHy9FxMVmQwTk0syGNfFWVpp_-7weTGY',
    appId: '1:1001214214557:android:27b7c2e181729b87166f74',
    messagingSenderId: '1001214214557',
    projectId: 'bookswap-app-e3e6a',
    storageBucket: 'bookswap-app-e3e6a.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'bookswap-YOUR_PROJECT_ID',
    storageBucket: 'bookswap-YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.bookswap',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOEusqT1Iv5JiK-H7hQ9cZJaCoY0plBK4',
    appId: '1:1001214214557:web:190a4e8038b1955d166f74',
    messagingSenderId: '1001214214557',
    projectId: 'bookswap-app-e3e6a',
    authDomain: 'bookswap-app-e3e6a.firebaseapp.com',
    storageBucket: 'bookswap-app-e3e6a.firebasestorage.app',
  );
}
