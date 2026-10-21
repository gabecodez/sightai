
import 'package:flutter_test/flutter_test.dart';
import 'package:sightai_prototype/viewmodel/camera_viewmodel.dart';

void main() {
  group('Sight AI Camera Tests', () {
    late CameraViewModel viewModel;

    setUp(() {
      viewModel = CameraViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    // Test Case 1: Camera not initialized
    test('Cannot capture photo before camera initializes', () async {
      expect(viewModel.isInitialized, false);

      await expectLater(
        viewModel.capturePhoto(),
        throwsException,
      );
    });

    // Test Case 2: No image selected
    test('Cannot generate AI description without image', () async {
      expect(viewModel.imageBytes, isNull);

      await expectLater(
        viewModel.generateDesc(),
        throwsException,
      );
    });
  });
}
