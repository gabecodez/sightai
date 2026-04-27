import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../repository/camera_repository.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository = CameraRepository();

  CameraController? controller;
  bool isInitialized = false;
  String? imagePath;

  Future<void> initialize() async {
    await _repository.initCamera();
    controller = _repository.getController();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> capturePhoto() async {
    imagePath = await _repository.takePicture();
    notifyListeners();
  }
}