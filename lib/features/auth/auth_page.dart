import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
    _animCtrl.reset();
    _animCtrl.forward();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Lütfen tüm alanları doldurun');
      return;
    }

    if (!_isLogin && password != _confirmCtrl.text.trim()) {
      setState(() => _error = 'Şifreler eşleşmiyor');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Şifre en az 6 karakter olmalı');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });

    try {
      if (_isLogin) {
        await AuthService.signInWithEmailAndPassword(email, password);
      } else {
        await AuthService.signUpWithEmailAndPassword(email, password);
      }
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.contains('user-not-found')) msg = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
      else if (msg.contains('wrong-password')) msg = 'Hatalı şifre';
      else if (msg.contains('email-already-in-use')) msg = 'Bu e-posta adresi zaten kullanımda';
      else if (msg.contains('invalid-email')) msg = 'Geçersiz e-posta adresi';
      else if (msg.contains('weak-password')) msg = 'Şifre çok zayıf';
      else if (msg.contains('too-many-requests')) msg = 'Çok fazla deneme — biraz bekle';
      else if (msg.contains('invalid-credential')) msg = 'Geçersiz e-posta veya şifre';
      else if (msg.contains('operation-not-allowed') || msg.contains('firebase_auth/unknown')) {
        msg = 'Firebase Authentication > Email/Password henüz açık değil. Console\'dan etkinleştir.';
      }
      else msg = 'Bir hata oluştu: $msg';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, const Color(0xFF7B0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'İndir Gitsin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin ? 'Hesabınıza giriş yapın' : 'Yeni bir hesap oluşturun',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-posta',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Şifre tekrar',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!, style: TextStyle(color: cs.onErrorContainer, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading ? null : _toggleMode,
                    child: Text(
                      _isLogin ? 'Hesabın yok mu? Kayıt ol' : 'Zaten hesabın var mı? Giriş yap',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Devam ederek Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
