import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../viewmodel/camera_viewmodel.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sight AI Camera"),
        ),
        body: Consumer<CameraViewModel>(
          builder: (context, vm, child) {
            if (!vm.isInitialized || vm.controller == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: CameraPreview(vm.controller!),
                ),

                const SizedBox(height: 12),

                FloatingActionButton(
                  onPressed: () async {
                    await vm.capturePhoto();
                  },
                  child: const Icon(Icons.camera_alt),
                ),

                const SizedBox(height: 12),

                if (vm.imagePath != null) ...[
                  const Text(
                    "Captured Image",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // On web, display using the URL, on mobile display using the file path
                  kIsWeb
                      ? (vm.webImageUrl != null
                          ? Image.network(
                              vm.webImageUrl!,
                              height: 180,
                            )
                          : const SizedBox())
                      : Image.file(
                          File(vm.imagePath!),
                          height: 180,
                        ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}