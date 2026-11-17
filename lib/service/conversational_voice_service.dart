import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Foreground voice conversation; this is NOT an always-on wake-word engine.
class ConversationalVoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _closed = false;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    _ready = await _speech.initialize(
      onError: (error) => debugPrint('Voice recognition error: $error'),
      onStatus: (status) => debugPrint('Voice status: $status'),
    );
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);
    return _ready;
  }

  Future<void> speak(String text) async {
    if (_closed) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<bool> listen(ValueChanged<String> onFinal) async {
    if (!_ready || _closed || _speech.isListening) return false;
    await _tts.stop();
    await _speech.listen(
      onResult: (result) {
        if (!_closed && result.finalResult) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) onFinal(text);
        }
      },
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 4),
    );
    return true;
  }

  Future<void> stop() async {
    await _speech.stop();
    await _tts.stop();
  }

  Future<void> dispose() async {
    _closed = true;
    await stop();
  }
}
