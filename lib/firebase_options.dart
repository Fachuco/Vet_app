import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Platform no soportado');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8esdh-_lw0kSRhqzy2ThO8405b4RvdLA',
    authDomain: 'appvet-b73c1.firebaseapp.com',
    projectId: 'appvet-b73c1',
    storageBucket: 'appvet-b73c1.appspot.com', 
    messagingSenderId: '1032235857356',
    appId: '1:1032235857356:web:e6f4502144edfd9b701969',
  );
}