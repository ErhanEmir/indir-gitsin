import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCneWBluBA6-SPMKbBh9kHgF13FmF7VI4',
    appId: '1:431898814853:android:84b68aa21ede348981bcec',
    messagingSenderId: '431898814853',
    projectId: 'indir-gitsin',
    storageBucket: 'indir-gitsin.firebasestorage.app',
  );
}
