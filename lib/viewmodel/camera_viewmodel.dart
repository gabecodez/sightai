import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:html' as html;
import '../repository/camera_repository.dart';

import 'package:firebase_ai/firebase_ai.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository = CameraRepository();

  CameraController? controller;
  bool isInitialized = false;
  String? imagePath;
  String? webImageUrl; // For web display

  Future<void> initialize() async {
    await _repository.initCamera();
    controller = _repository.getController();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> generateDesc() async {
    XFile xfile = await _repository.takePicture();
    final image = await xfile.readAsBytes();
    final imagePart = InlineDataPart('image/jpeg', image);

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
    );

    // Provide a prompt that contains text
    final prompt = TextPart(
      'Provide a detailed explanation of the attached image.',
    );

    // To generate text output, call generateContent with the text input and image
    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);
    print(response.text);
  }

  Future<void> capturePhoto() async {
    // On web, takePicture returns an XFile with bytes
    if (kIsWeb) {
      XFile xfile = await _repository.takePicture();
      final bytes = await xfile.readAsBytes();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      webImageUrl = url;
      imagePath = url;
      // Trigger download
      html.AnchorElement(href: url)
        ..setAttribute('download', 'captured_image.jpg')
        ..click();
      // Don't revoke url immediately, or image won't display
    } else {
      // On mobile, takePicture returns a file path
      final result = await _repository.takePicture();
      imagePath = result;
      if (imagePath != null && (Platform.isAndroid || Platform.isIOS)) {
        await ImageGallerySaver.saveFile(imagePath!);
      }
      webImageUrl = null;
    }

    notifyListeners();
  }
}
