import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Spoken feedback for the accessible camera. No microphone or speech recognition.
class BlindModeService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String message) async {
    debugPrint('Blind Mode audio: $message');
    await _tts.stop();
    await _tts.speak(message);
  }

  Future<void> feedback() => HapticFeedback.mediumImpact();
  Future<void> stop() => _tts.stop();
  Future<void> dispose() => _tts.stop();
}
