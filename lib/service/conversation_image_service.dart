import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// Image-grounded, short-lived conversation. No conversation is persisted.
class ConversationImageService {
  Uint8List? _image;
  final List<String> _history = [];

  void setImage(Uint8List bytes) {
    _image = bytes;
    _history.clear();
  }

  void clear() {
    _image = null;
    _history.clear();
  }

  Future<String> ask(String question) async {
    final bytes = _image;
    if (bytes == null) {
      return 'Please take a picture first.';
    }
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
    );
    final context = _history.join('\n');
    final response = await model.generateContent([
      Content.multi([
        TextPart('You are Sight AI, an accessibility assistant. Answer the '
            'latest question about the attached photo, using prior dialogue '
            'only to resolve references. Never claim to see beyond the photo. '
            'If details or text are unclear, say so. Keep answers brief and '
            'easy to hear.\nPrevious dialogue:\n$context\nUser: $question'),
        InlineDataPart('image/jpeg', bytes),
      ]),
    ]);
    final answer = response.text?.trim();
    final safeAnswer = (answer == null || answer.isEmpty)
        ? 'Sorry, I could not answer that question.'
        : answer;
    _history.add('User: $question\nAssistant: $safeAnswer');
    if (_history.length > 6) _history.removeAt(0);
    return safeAnswer;
  }
}
