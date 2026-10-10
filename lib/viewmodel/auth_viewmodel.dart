
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get currently logged-in user
  User? get currentUser => _auth.currentUser;

  // REGISTER NEW USER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());

      // Save user information in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // LOGIN EXISTING USER
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // LOGOUT USER
  Future<void> logout() async {
    await _auth.signOut();
  }
}
