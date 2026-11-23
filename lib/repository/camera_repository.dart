import 'package:camera/camera.dart';
import '../service/camera_service.dart';

class CameraRepository {
  final CameraService _service = CameraService();

  Future<void> initCamera() async {
    await _service.initializeCamera();
  }

  Future<void> flipCamera() async {
    await _service.flipCamera();
  }

  CameraController? getController() {
    return _service.getCameraController();
  }

  Future<XFile> takePicture() async {
    return await _service.captureImage();
  }
}
