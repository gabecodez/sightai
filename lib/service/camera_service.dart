import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;

  // INITIALIZE CAMERA
  Future<void> initializeCamera() async {
    // Dispose of old camera controller
    final oldController = controller;
    controller = null;

    if (oldController != null) {
      await oldController.dispose();
    }

    cameras = await availableCameras();

    if (cameras == null || cameras!.isEmpty) {
      throw Exception('No camera found on this device.');
    }

    final newController = CameraController(
      cameras!.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await newController.initialize();
      controller = newController;
    } catch (e) {
      await newController.dispose();
      rethrow;
    }
  }

  // GET CAMERA CONTROLLER
  CameraController? getCameraController() {
    return controller;
  }

  // TAKE PHOTO
  Future<XFile> captureImage() async {
    final camera = controller;

    if (camera == null || !camera.value.isInitialized) {
      throw Exception('Camera is not initialized.');
    }

    return await camera.takePicture();
  }

  // DISPOSE CAMERA
  Future<void> disposeCamera() async {
    final oldController = controller;
    controller = null;

    if (oldController != null) {
      await oldController.dispose();
    }
  }
}
