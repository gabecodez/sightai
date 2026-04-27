import 'package:flutter/material.dart';
import 'view/camera_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3-flash-preview',
  );

  // Provide a prompt that contains text
  final prompt = [Content.text('Write a story about a magic backpack.')];

  // To generate text output, call generateContent with the text input
  final response = await model.generateContent(prompt);
  print(response.text);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    );
  }
}
