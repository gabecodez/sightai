import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    controller = CameraController(
      cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
  }

  CameraController? getCameraController() {
    return controller;
  }

  Future<dynamic> captureImage() async {
    final image = await controller!.takePicture();

    // Used for photo saving.
    // On web, return XFile for easier handling, on mobile return path string.
    if (kIsWeb) {
      return image; // XFile
    } else {
      return image.path; // String
    }
  }
}