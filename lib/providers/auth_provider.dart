
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _service.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  // FirebaseAuthException is left to propagate so the screen can show it.
  Future<void> signIn(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    await _service.signIn(email, password, rememberMe: rememberMe);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _service.register(name: name, email: email, password: password);
  }

  Future<void> signOut() => _service.signOut();
}

