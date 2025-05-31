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
    apiKey: 'AIzaSyDmZ4frmsnDCMzRG-P_S7n12z6OTLjDbAs',
    appId: '1:107187973562:web:b09484fd82374b63a40183',
    messagingSenderId: '107187973562',
    projectId: 'inventarium-th3-2025',
    authDomain: 'inventarium-th3-2025.firebaseapp.com',
    storageBucket: 'inventarium-th3-2025.firebasestorage.app',
    measurementId: 'G-9R7V6JEEZR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKtuEiSawPodlmkrrzUTepeKxHv10YH8Q',
    appId: '1:107187973562:android:f5f384a431c17c6da40183',
    messagingSenderId: '107187973562',
    projectId: 'inventarium-th3-2025',
    storageBucket: 'inventarium-th3-2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkOuMOBOsXnVU6ulZRrtBV4ngHwS2Tb7I',
    appId: '1:107187973562:ios:999141d3905c3824a40183',
    messagingSenderId: '107187973562',
    projectId: 'inventarium-th3-2025',
    storageBucket: 'inventarium-th3-2025.firebasestorage.app',
    iosBundleId: 'com.example.inventarium',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkOuMOBOsXnVU6ulZRrtBV4ngHwS2Tb7I',
    appId: '1:107187973562:ios:999141d3905c3824a40183',
    messagingSenderId: '107187973562',
    projectId: 'inventarium-th3-2025',
    storageBucket: 'inventarium-th3-2025.firebasestorage.app',
    iosBundleId: 'com.example.inventarium',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmZ4frmsnDCMzRG-P_S7n12z6OTLjDbAs',
    appId: '1:107187973562:web:d5af204ba8c98ab9a40183',
    messagingSenderId: '107187973562',
    projectId: 'inventarium-th3-2025',
    authDomain: 'inventarium-th3-2025.firebaseapp.com',
    storageBucket: 'inventarium-th3-2025.firebasestorage.app',
    measurementId: 'G-K98DGGD57W',
  );
}
