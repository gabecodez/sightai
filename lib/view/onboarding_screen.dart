import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to SightAI",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 26),
              Text(
                "Understand the world around you with the help of AI.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Text(
                "Take a photo and SightAI will describe what it sees.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Text(
                "Images submitted for AI analysis are sent through Google's AI services for processing. Please avoid submitting sensitive information or confidential images. For more information about how your data is handled, please see our Privacy Policy on the SightAI website.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse('https://sightai.dev/#legal-disclaimer'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text(
                'View Privacy Policy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text("Get Started", style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
