
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../viewmodel/camera_viewmodel.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sight AI Camera'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthViewModel>().logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
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
                  child: vm.imageBytes != null
                      ? Center(
                          child: Image.memory(
                            vm.imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : CameraPreview(vm.controller!),
                ),

                const SizedBox(height: 12),

                if (vm.imageBytes == null) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await vm.capturePhoto();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Camera error: $e',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Picture'),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await vm.selectFromGallery();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gallery error: $e',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ] else ...[
                  const Text(
                    'Selected Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: vm.clearImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Choose Again'),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await vm.generateDesc();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'AI description generated. Check the console.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'AI error: $e',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm Image'),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
