import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Giriş yap
  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Kayıt ol
  static Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Çıkış yap
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı durumunu dinle
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mevcut kullanıcı
  static User? get currentUser => _auth.currentUser;
}