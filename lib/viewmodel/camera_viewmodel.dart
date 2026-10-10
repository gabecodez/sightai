
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/camera_repository.dart';
import '../service/image_saver/image_saver.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository = CameraRepository();

  CameraController? controller;
  bool isInitialized = false;
  String? imagePath;
  String? webImageUrl;
  Uint8List? imageBytes;

  // Initialize camera
  Future<void> initialize() async {
    await _repository.initCamera();
    controller = _repository.getController();
    isInitialized = true;
    notifyListeners();
  }

  // Generate AI image description
  // Teammate's existing functionality preserved
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

  // Capture photo using camera
  // Teammate's existing functionality preserved
  Future<void> capturePhoto() async {
    final xfile = await _repository.takePicture();
    final bytes = await xfile.readAsBytes();

    imagePath = xfile.path;
    imageBytes = bytes;

    webImageUrl = await saveImage(bytes);

    notifyListeners();
  }

  // NEW: Select image from gallery
  Future<void> selectFromGallery() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    imagePath = image.path;
    imageBytes = bytes;

    webImageUrl = await saveImage(bytes);

    notifyListeners();
  }

  // NEW: Clear image and choose again
  void clearImage() {
    imagePath = null;
    imageBytes = null;
    webImageUrl = null;

    notifyListeners();
  }
}
