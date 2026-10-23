import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// Returns a spoken-friendly description without changing the existing camera VM.
class BlindModeAIService {
  Future<String> describe(Uint8List bytes) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
    );
    final response = await model.generateContent([
      Content.multi([
        TextPart('Describe this image clearly for a blind or visually impaired '
            'person. Mention important objects, approximate positions and '
            'visible text. Be concise and do not guess uncertain details.'),
        InlineDataPart('image/jpeg', bytes),
      ]),
    ]);
    final result = response.text?.trim();
    final description = (result == null || result.isEmpty)
        ? 'Sorry, I could not describe this image.'
        : result;
    debugPrint('Sight AI Blind Mode Description: $description');
    return description;
  }
}
