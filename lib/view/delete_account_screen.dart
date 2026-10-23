import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

/// Deletes the signed-in email/password user's Firebase Auth account and
/// the Firestore profile document created during registration.
/// Other user-owned collections/storage require a separate backend cleanup.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'You are not signed in.');
      return;
    }

    final email = user.email;
    final password = _passwordController.text;
    if (email == null || password.isEmpty) {
      setState(() => _error = 'Enter your account password to continue.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permanently delete account?'),
        content: const Text(
          'This will permanently delete your sign-in account and its '
          'Sight AI profile. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      // Firebase requires a recent sign-in before account deletion.
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

      // This app creates the profile at users/{uid} on registration.
      // Remove it while still authenticated so user-scoped rules can apply.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      debugPrint('Sight AI account deletion completed.');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Account deletion authentication error: ${e.code}');
      if (!mounted) return;
      setState(() {
        _error = switch (e.code) {
          'wrong-password' || 'invalid-credential' => 'Incorrect password. Try again.',
          'requires-recent-login' => 'Please sign out, sign in again, and retry.',
          'too-many-requests' => 'Too many attempts. Please try again later.',
          _ => 'Could not delete account: ${e.message ?? e.code}',
        };
      });
    } on FirebaseException catch (e) {
      debugPrint('Account deletion Firestore error: ${e.code}');
      if (!mounted) return;
      setState(() => _error = 'Could not remove your profile: ${e.message ?? e.code}. Account deletion was not completed.');
    } catch (e) {
      debugPrint('Account deletion error: $e');
      if (!mounted) return;
      setState(() => _error = 'Account deletion could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Delete your Sight AI account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This permanently deletes your Firebase sign-in account and your '
                  'Sight AI profile. Other uploaded data, if any, may require '
                  'separate removal. You cannot undo account deletion.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !_isDeleting,
                  decoration: const InputDecoration(
                    labelText: 'Confirm your password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isDeleting ? null : _deleteAccount,
                  icon: _isDeleting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.delete_forever),
                  label: Text(_isDeleting ? 'Deleting account...' : 'Delete Account Permanently'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
