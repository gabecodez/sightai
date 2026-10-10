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
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password must be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else {
        errorMessage = e.message ?? 'Registration failed.';
      }
    } catch (e) {
      errorMessage = 'Registration failed. Check Firebase/Firestore setup.';
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
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else {
        errorMessage = e.message ?? 'Login failed.';
      }
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

  // CLEAR ERROR MESSAGE
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}