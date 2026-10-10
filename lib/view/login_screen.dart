import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';
import 'register_screen.dart';
import 'camera_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CameraScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sight AI'),
      ),

      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.visibility,
                  size: 90,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome to Sight AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // EMAIL
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // ERROR
                if (authViewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      authViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                // LOGIN BUTTON
                ElevatedButton(
                  onPressed:
                      authViewModel.isLoading ? null : _login,
                  child: authViewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: 15),

                // REGISTER BUTTON
                TextButton(
                  onPressed: authViewModel.isLoading
                      ? null
                      : () {
                          authViewModel.clearError();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "Don't have an account? Register",
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}