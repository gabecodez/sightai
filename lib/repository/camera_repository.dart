import 'package:camera/camera.dart';
import '../service/camera_service.dart';

class CameraRepository {
  final CameraService _service = CameraService();

  Future<void> initCamera() async {
    await _service.initializeCamera();
  }

  CameraController? getController() {
    return _service.getCameraController();
  }

  Future<String> takePicture() async {
    return await _service.captureImage();
  }
}