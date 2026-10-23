import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/blind_mode_ai_service.dart';
import '../service/blind_mode_service.dart';
import '../viewmodel/camera_viewmodel.dart';

/// Accessible camera UI. Receives the existing CameraViewModel from CameraScreen.
class BlindModeScreen extends StatefulWidget {
  const BlindModeScreen({super.key});

  @override
  State<BlindModeScreen> createState() => _BlindModeScreenState();
}

class _BlindModeScreenState extends State<BlindModeScreen> {
  final BlindModeService _audio = BlindModeService();
  final BlindModeAIService _ai = BlindModeAIService();
  bool _working = false;
  String _status = 'Blind Mode ready';
  String _description = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _audio.initialize();
        if (mounted) {
          await _audio.speak('Blind Mode enabled. Use the large buttons to '
              'take a picture or choose from gallery, then describe the image.');
        }
      } catch (error) {
        debugPrint('Blind Mode speech setup error: $error');
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
      debugPrint('Blind Mode announcement error: $error');
    }
  }

  Future<void> _perform(Future<void> Function(CameraViewModel) action) async {
    if (_working) return;
    final vm = context.read<CameraViewModel>();
    setState(() => _working = true);
    try {
      await action(vm);
    } catch (error) {
      debugPrint('Blind Mode action error: $error');
      await _announce('Sorry, that action could not be completed.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _capture(CameraViewModel vm) async {
    await vm.capturePhoto();
    if (!mounted) return;
    setState(() => _description = '');
    await _announce('Photo captured. Tap Describe Image.');
  }

  Future<void> _gallery(CameraViewModel vm) async {
    final previous = vm.imageBytes;
    await vm.selectFromGallery();
    if (!mounted) return;
    if (vm.imageBytes != null && !identical(previous, vm.imageBytes)) {
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
    final result = await _ai.describe(bytes);
    if (!mounted) return;
    setState(() => _description = result);
    await _announce(result);
  }

  Future<void> _reset(CameraViewModel vm) async {
    await vm.clearImage();
    if (!mounted) return;
    setState(() => _description = '');
    await _announce('Camera ready for another picture.');
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
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Blind Mode'),
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
