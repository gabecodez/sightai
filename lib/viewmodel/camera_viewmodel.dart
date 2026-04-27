import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:html' as html;
import '../repository/camera_repository.dart';

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