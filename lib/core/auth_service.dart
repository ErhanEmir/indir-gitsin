import 'package:firebase_auth/firebase_auth.dart';
import 'user_repository.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserRepository.syncOnAuth();
    return userCredential.user;
  }

  static Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserRepository.syncOnAuth();
    return userCredential.user;
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