import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../repository/camera_repository.dart';
import '../service/image_saver/image_saver.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository = CameraRepository();

  CameraController? controller;

  bool isInitialized = false;
  bool isBusy = false;
  bool isSwitchingCamera = false;
  bool _isDisposed = false;

  Uint8List _normalizeImageOrientation(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      final oriented = img.bakeOrientation(decoded);
      return Uint8List.fromList(img.encodeJpg(oriented, quality: 95));
    } catch (error) {
      debugPrint('Image orientation normalization error: $error');
      return bytes;
    }
  }

  String? imagePath;
  String? webImageUrl;
  Uint8List? imageBytes;
  String? aiDescription;

  // Notify listeners safely
  void _update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Update the busy state for camera.
  void setBusy(bool value) {
    if (isBusy == value) return;
    isBusy = value;
    _update();
  }

  // INITIALIZE CAMERA
  Future<void> initialize() async {
    isInitialized = false;
    _update();

    try {
      await _repository.initCamera();

      if (_isDisposed) return;

      controller = _repository.getController();

      if (controller == null || !controller!.value.isInitialized) {
        throw Exception('Camera initialization failed.');
      }

      isInitialized = true;
      _update();
    } catch (e) {
      isInitialized = false;
      debugPrint('Camera initialization error: $e');
      _update();
    }
  }

  // Flip the camera between front and back.
  Future<void> flipCamera() async {
    if (isBusy) return;

    isSwitchingCamera = true;
    _update();
    try {
      await _repository.flipCamera();

      if (_isDisposed) return;

      controller = _repository.getController();
      if (controller == null || !controller!.value.isInitialized) {
        throw Exception('Camera switching failed.');
      }
      isInitialized = true;
      _update();
    } catch (error) {
      debugPrint('Camera flip error: $error');
      rethrow;
    } finally {
      isSwitchingCamera = false;
      _update();
    }
  }

  // TAKE PHOTO
  Future<void> capturePhoto() async {
    if (isBusy) return;

    final camera = controller;

    if (camera == null || !camera.value.isInitialized) {
      throw Exception('Camera is not ready.');
    }

    isBusy = true;
    _update();

    try {
      final XFile photo = await _repository.takePicture();
      final bytes = _normalizeImageOrientation(await photo.readAsBytes());

      if (_isDisposed) return;

      imagePath = photo.path;
      imageBytes = bytes;
      aiDescription = null;

      _update();

      // Preserve existing image saving feature
      try {
        webImageUrl = await saveImage(bytes);
      } catch (e) {
        debugPrint('Image save error: $e');
      }
    } finally {
      isBusy = false;
      _update();
    }
  }

  // SELECT IMAGE FROM GALLERY
  Future<void> selectFromGallery() async {
    if (isBusy) return;

    isBusy = true;
    _update();

    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null || _isDisposed) return;

      final bytes = _normalizeImageOrientation(await image.readAsBytes());

      if (_isDisposed) return;

      imagePath = image.path;
      imageBytes = bytes;
      aiDescription = null;

      _update();

      try {
        webImageUrl = await saveImage(bytes);
      } catch (e) {
        debugPrint('Image save error: $e');
      }
    } finally {
      isBusy = false;
      _update();
    }
  }

  // CHOOSE AGAIN - RESTART LIVE CAMERA
  Future<void> clearImage() async {
    if (isBusy) return;

    isBusy = true;
    _update();

    try {
      // Restart the camera using CameraRepository.
      // CameraService should dispose the old controller
      // before creating a new one.
      await _repository.initCamera();

      if (_isDisposed) return;

      final newController = _repository.getController();

      if (newController == null || !newController.value.isInitialized) {
        throw Exception('Camera failed to restart.');
      }

      controller = newController;
      isInitialized = true;

      // Clear photo only after camera restarts
      imagePath = null;
      imageBytes = null;
      webImageUrl = null;
      aiDescription = null;

      _update();
    } catch (e) {
      debugPrint('Camera restart error: $e');
      rethrow;
    } finally {
      isBusy = false;
      _update();
    }
  }

  // GENERATE AI DESCRIPTION
  Future<String> generateDesc() async {
    final bytes = imageBytes;

    if (bytes == null) {
      throw Exception('Please take or select an image first.');
    }

    final imagePart = InlineDataPart('image/jpeg', bytes);

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
    );

    final prompt = TextPart(
      'Describe what is visible in this image in one concise paragraph. '
      'Include notable visual details and, when clearly relevant, art style '
      'or composition. Do not create section headings, numbered lists, or a '
      'step-by-step breakdown.',
    );

    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final description = response.text?.trim();
    final safeDescription = (description == null || description.isEmpty)
        ? 'No description generated.'
        : description;
    aiDescription = safeDescription;
    debugPrint(safeDescription);
    return safeDescription;
  }

  // CLEANUP
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
