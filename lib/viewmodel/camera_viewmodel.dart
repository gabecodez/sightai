import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../repository/camera_repository.dart';
import '../service/image_saver/image_saver.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository = CameraRepository();

  CameraController? controller;
  bool isInitialized = false;
  String? imagePath;
  String? webImageUrl;
  Uint8List? imageBytes;

  Future<void> initialize() async {
    await _repository.initCamera();
    controller = _repository.getController();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> generateDesc() async {
    if (imageBytes == null) return;

    final image = imageBytes!;
    final imagePart = InlineDataPart('image/jpeg', image);

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
    );

    final prompt = TextPart(
      'Provide a detailed explanation of the attached image.',
    );

    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    print(response.text);
  }

  Future<void> capturePhoto() async {
    final xfile = await _repository.takePicture();
    final bytes = await xfile.readAsBytes();

    imagePath = xfile.path;
    imageBytes = bytes;

    webImageUrl = await saveImage(bytes);

    notifyListeners();
  }
}
