import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuration for the existing Firebase web app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Firebase is configured for the web app only.');
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDhDtC9uO-tmCGOrq3KhqvCLXJTEJGlm4w',
    authDomain: 'wedding-projects-15a73.firebaseapp.com',
    projectId: 'wedding-projects-15a73',
    storageBucket: 'wedding-projects-15a73.firebasestorage.app',
    messagingSenderId: '462827758399',
    appId: '1:462827758399:web:4bcbd168f0d8d7d13e298a',
    measurementId: 'G-T5DHC2FTN8',
  );
}
