
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';
import 'delete_account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ListTile(
          leading: const Icon(
            Icons.delete_forever_outlined,
            color: Colors.red,
          ),
          title: const Text('Delete Account'),
          subtitle: const Text(
            'Permanently delete your account',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DeleteAccountScreen(),
              ),
            );
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          subtitle: const Text(
            'Sign out of your SightAI account',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await context.read<AuthViewModel>().logout();

            if (!context.mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
