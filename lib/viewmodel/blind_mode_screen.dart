
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../viewmodel/camera_viewmodel.dart';
import '../service/blind_mode_service.dart';

class BlindModeScreen extends StatelessWidget {
  const BlindModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: const _BlindModeContent(),
    );
  }
}

class _BlindModeContent extends StatefulWidget {
  const _BlindModeContent();

  @override
  State<_BlindModeContent> createState() =>
      _BlindModeContentState();
}

class _BlindModeContentState extends State<_BlindModeContent> {
  final BlindModeService _voice = BlindModeService();

  bool _listening = false;
  String _status = 'Voice assistant ready';
  String _lastAnswer = '';

  @override
  void initState() {
    super.initState();
    _enableVoice();
  }

  Future<void> _enableVoice() async {
    await _voice.enableBlindMode();
  }

  Future<void> _listen() async {
    if (_listening) return;

    final started = await _voice.startListening((command) {
      if (!mounted) return;

      setState(() => _listening = false);
      _handleCommand(command);
    });

    if (!mounted) return;

    setState(() {
      _listening = started;
      _status = started ? 'Listening...' : 'Microphone unavailable';
    });
  }

  Future<void> _handleCommand(String command) async {
    final vm = context.read<CameraViewModel>();

    debugPrint('Voice Command: $command');

    setState(() => _status = 'Processing: $command');

    try {
      if (command.contains('take photo') ||
          command.contains('take picture')) {
        await vm.capturePhoto();
        await _respond('Photo captured.');
      } else if (command.contains('open gallery')) {
        await vm.selectFromGallery();
        await _respond('Gallery selection completed.');
      } else if (command.contains('choose again')) {
        await vm.clearImage();
        await _respond('Camera ready.');
      } else if (command.contains('describe image')) {
        final description = await vm.generateDesc();
        await _respond(description);
      } else {
        // Any other speech is treated as an AI question.
        final answer = await vm.askImageQuestion(command);
        await _respond(answer);
      }
    } catch (e) {
      debugPrint('Blind Mode Error: $e');
      await _respond('Sorry, something went wrong.');
    }
  }

  Future<void> _respond(String message) async {
    debugPrint('Sight AI Response: $message');

    if (!mounted) return;

    setState(() {
      _lastAnswer = message;
      _status = 'Ready for next command';
    });

    await _voice.speak(message);
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sight AI Blind Mode'),
        centerTitle: true,
      ),
      body: Consumer<CameraViewModel>(
        builder: (context, vm, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.accessibility_new,
                    size: 70,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Blind Mode + AI Voice Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _status,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  if (vm.imageBytes != null)
                    Image.memory(
                      vm.imageBytes!,
                      height: 200,
                    ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _listening || vm.isBusy
                        ? null
                        : _listen,
                    icon: const Icon(Icons.mic),
                    label: Text(
                      _listening
                          ? 'Listening...'
                          : 'Start Voice Command',
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_lastAnswer.isNotEmpty)
                    Text(
                      _lastAnswer,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
