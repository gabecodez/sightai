import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/blind_mode_service.dart';
import '../service/conversation_image_service.dart';
import '../service/conversational_voice_service.dart';
import '../viewmodel/camera_viewmodel.dart';

/// Accessible camera UI. Receives the existing CameraViewModel from CameraScreen.
class BlindModeScreen extends StatefulWidget {
  const BlindModeScreen({super.key});

  @override
  State<BlindModeScreen> createState() => _BlindModeScreenState();
}

class _BlindModeScreenState extends State<BlindModeScreen> {
  final BlindModeService _audio = BlindModeService();
  final ConversationImageService _conversation = ConversationImageService();
  final ConversationalVoiceService _voice = ConversationalVoiceService();
  bool _voiceReady = false;
  bool _voiceActive = false;
  bool _working = false;
  String _status = 'High Contrast Mode ready';
  String _description = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _audio.initialize();
        _voiceReady = await _voice.initialize();
        if (mounted) setState(() {});
        if (mounted) {
          await _audio.speak('High Contrast enabled. Use the large buttons to '
              'take a picture or choose from gallery, then describe the image.');
        }
      } catch (error) {
        debugPrint('High Contrast speech setup error: $error');
      }
    });
  }

  Future<void> _announce(String message) async {
    if (!mounted) return;
    setState(() => _status = message);
    try {
      await _audio.feedback();
      await _audio.speak(message);
    } catch (error) {
      debugPrint('High Contrast announcement error: $error');
    }
  }

  Future<void> _perform(Future<void> Function(CameraViewModel) action) async {
    if (_working) return;
    final vm = context.read<CameraViewModel>();
    setState(() => _working = true);
    try {
      await action(vm);
    } catch (error) {
      debugPrint('High Contrast action error: $error');
      await _announce('Sorry, that action could not be completed.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _capture(CameraViewModel vm) async {
    await vm.capturePhoto();
    if (!mounted) return;
    _conversation.setImage(vm.imageBytes!);
    setState(() => _description = '');
    await _announce('Photo captured. Tap Describe Image.');
  }

  Future<void> _gallery(CameraViewModel vm) async {
    final previous = vm.imageBytes;
    await vm.selectFromGallery();
    if (!mounted) return;
    if (vm.imageBytes != null && !identical(previous, vm.imageBytes)) {
      _conversation.setImage(vm.imageBytes!);
      setState(() => _description = '');
      await _announce('Image selected. Tap Describe Image.');
    }
  }

  Future<void> _describe(CameraViewModel vm) async {
    final bytes = vm.imageBytes;
    if (bytes == null) {
      await _announce('Take a picture or select an image first.');
      return;
    }
    await _announce('Analyzing image. Please wait.');
    _conversation.setImage(bytes);
    final result = await _conversation.ask('Describe this image clearly for a visually impaired person.');
    if (!mounted) return;
    setState(() => _description = result);
    await _announce(result);
  }

  Future<void> _reset(CameraViewModel vm) async {
    await vm.clearImage();
    if (!mounted) return;
    _conversation.clear();
    setState(() => _description = '');
    await _announce('Camera ready for another picture.');
  }

  Future<void> _startVoice() async {
    if (!_voiceReady || _voiceActive) return;
    setState(() => _voiceActive = true);
    await _voice.speak('Voice conversation started. What would you like to know?');
    await _listenAgain();
  }

  Future<void> _listenAgain() async {
    if (!mounted || !_voiceActive) return;
    setState(() => _status = 'Listening for your question');
    final started = await _voice.listen((command) async {
      await _handleVoiceCommand(command);
    });
    if (!started && mounted) {
      setState(() => _status = 'Microphone unavailable. Tap Start Voice again.');
      _voiceActive = false;
    }
  }

  Future<void> _handleVoiceCommand(String command) async {
    if (!mounted || !_voiceActive || _working) return;
    setState(() { _working = true; _status = 'Processing: $command'; });
    String answer;
    try {
      final vm = context.read<CameraViewModel>();
      final cmd = command.toLowerCase();
      if (cmd.contains('stop listening') || cmd == 'stop' ||
          cmd.contains('goodbye')) {
        setState(() { _voiceActive = false; _status = 'Voice stopped'; });
        await _voice.speak('Voice conversation stopped.');
        return;
      } else if (cmd.contains('repeat')) {
        answer = _description.isEmpty ? 'Nothing to repeat yet.' : _description;
      } else if (cmd.contains('take picture') || cmd.contains('take photo') ||
          cmd.contains('what is in front') || cmd.contains('describe surroundings') ||
          cmd.contains('new picture')) {
        if (vm.imageBytes != null) await vm.clearImage();
        await vm.capturePhoto();
        _conversation.setImage(vm.imageBytes!);
        answer = await _conversation.ask('Describe this image for a visually impaired person.');
      } else if (cmd.contains('open gallery')) {
        await vm.selectFromGallery();
        if (vm.imageBytes != null) _conversation.setImage(vm.imageBytes!);
        answer = 'Gallery selection completed.';
      } else if (cmd.contains('clear image') || cmd.contains('choose again')) {
        await vm.clearImage();
        _conversation.clear();
        answer = 'Camera ready for another picture.';
      } else {
        if (vm.imageBytes != null && _description.isEmpty) {
          _conversation.setImage(vm.imageBytes!);
        }
        answer = await _conversation.ask(command);
      }
      if (!mounted) return;
      setState(() { _description = answer; _status = answer; });
      await _voice.speak(answer);
    } catch (error) {
      debugPrint('Sight AI voice command failed: $error');
      await _voice.speak('Sorry, I could not complete that request.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
    if (mounted && _voiceActive) await _listenAgain();
  }

  Future<void> _stopVoice() async {
    setState(() { _voiceActive = false; _status = 'Voice stopped'; });
    await _voice.stop();
  }

  Widget _button(String label, IconData icon, VoidCallback? onPressed,
      String hint) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      child: SizedBox(
        width: double.infinity,
        height: 76,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 30),
          label: Text(label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voice.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('High Contrast Mode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CameraViewModel>(
        builder: (context, vm, _) {
          final hasImage = vm.imageBytes != null;
          final disabled = _working || vm.isBusy;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.accessibility_new,
                      color: Colors.yellow, size: 64),
                  const SizedBox(height: 12),
                  const Text('Sight AI Accessible Camera',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,
                          fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(_status, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.yellow, fontSize: 19)),
                  ),
                  if (hasImage) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Selected image preview', image: true,
                      child: Image.memory(vm.imageBytes!, height: 180,
                          fit: BoxFit.contain),
                    ),
                  ],
                  if (_working) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: 24),
                  _button('Start Voice Conversation', Icons.mic,
                      !_voiceReady || _voiceActive ? null : _startVoice,
                      'Start spoken questions and automatic follow-up listening'),
                  const SizedBox(height: 12),
                  _button('Stop Voice Conversation', Icons.mic_off,
                      _voiceActive ? _stopVoice : null,
                      'Stop microphone recognition'),
                  const SizedBox(height: 12),
                  _button('Take Picture', Icons.camera_alt,
                      disabled || !vm.isInitialized ? null :
                          () => _perform(_capture),
                      'Capture an image with the camera'),
                  const SizedBox(height: 12),
                  _button('Choose From Gallery', Icons.photo_library,
                      disabled ? null : () => _perform(_gallery),
                      'Select an image from your gallery'),
                  const SizedBox(height: 12),
                  _button('Describe Image', Icons.record_voice_over,
                      disabled || !hasImage ? null :
                          () => _perform(_describe),
                      'Hear a description of the selected image'),
                  const SizedBox(height: 12),
                  _button('Repeat Description', Icons.replay,
                      disabled || _description.isEmpty ? null :
                          () { _audio.speak(_description); },
                      'Repeat the most recent description'),
                  const SizedBox(height: 12),
                  _button('Stop Speaking', Icons.volume_off,
                      () { _audio.stop(); },
                      'Stop spoken feedback'),
                  const SizedBox(height: 12),
                  _button('Choose Again', Icons.refresh,
                      disabled || !hasImage ? null :
                          () => _perform(_reset),
                      'Clear image and restart camera'),
                  if (_description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SelectableText(_description,
                        style: const TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
