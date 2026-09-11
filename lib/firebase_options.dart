import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaoIgEWGw4Jly4bCkePIOJfQ4aF_A0pHY',
    appId: '1:431898814853:web:b89e7c04886914af81bcec',
    messagingSenderId: '431898814853',
    projectId: 'indir-gitsin',
    storageBucket: 'indir-gitsin.firebasestorage.app',
  );
}
