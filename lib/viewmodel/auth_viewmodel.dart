
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _authService.currentUser;

  // REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Registration failed.';
    } catch (e) {
      errorMessage = 'Registration failed. Please try again.';
      debugPrint('Registration error: $e');
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Login failed.';
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';
      debugPrint('Login error: $e');
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  // CLEAR ERROR
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
