import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  // INITIALIZE CAMERA
  Future<void> initializeCamera({CameraLensDirection? preferred}) async {
    cameras = await availableCameras();

    if (cameras == null || cameras!.isEmpty) {
      throw Exception('No camera found on this device.');
    }

    final direction = preferred ?? _lensDirection;
    CameraDescription? selected;
    for (final camera in cameras!) {
      if (camera.lensDirection == direction) {
        selected = camera;
        break;
      }
    }
    if (selected == null) {
      throw Exception(
        direction == CameraLensDirection.front
            ? 'No front camera is available.'
            : 'No back camera is available.',
      );
    }

    // Dispose of old camera controller
    final oldController = controller;
    controller = null;

    if (oldController != null) {
      await oldController.dispose();
    }

    final newController = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await newController.initialize();
      controller = newController;
      _lensDirection = selected.lensDirection;
    } catch (e) {
      await newController.dispose();
      rethrow;
    }
  }

  // FLIP CAMERA
  Future<void> flipCamera() async {
    final direction = _lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await initializeCamera(preferred: direction);
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
