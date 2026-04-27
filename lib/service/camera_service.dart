import 'package:camera/camera.dart';

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

  Future<String> captureImage() async {
    final image = await controller!.takePicture();
    return image.path;
  }
}