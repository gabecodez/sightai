
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../viewmodel/camera_viewmodel.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';
import 'blind_mode_screen.dart';
import 'delete_account_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sight AI Camera'),
          centerTitle: true,
          actions: [
            // DELETE ACCOUNT
            IconButton(
              tooltip: 'Delete Account',
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteAccountScreen(),
                  ),
                );
              },
            ),

            // LOGOUT - EXISTING TEAMMATE CODE
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final double cameraWidth =
                    constraints.maxWidth > 500
                        ? 450
                        : constraints.maxWidth * 0.9;

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // OPEN BLIND MODE
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChangeNotifierProvider.value(
                                  value: vm,
                                  child: const BlindModeScreen(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.accessibility_new,
                          ),
                          label: const Text('Open Blind Mode'),
                        ),

                        const SizedBox(height: 20),

                        // LIVE CAMERA OR CAPTURED PHOTO
                        Center(
                          child: vm.imageBytes != null
                              ? Image.memory(
                                  vm.imageBytes!,
                                  width: cameraWidth,
                                  fit: BoxFit.contain,
                                )
                              : SizedBox(
                                  width: cameraWidth,
                                  child: AspectRatio(
                                    aspectRatio: vm
                                        .controller!
                                        .value
                                        .aspectRatio,
                                    child: CameraPreview(
                                      vm.controller!,
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 24),

                        // BEFORE TAKING A PHOTO
                        if (vm.imageBytes == null) ...[
                          ElevatedButton.icon(
                            onPressed: vm.isBusy
                                ? null
                                : () async {
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

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: vm.isBusy
                                ? null
                                : () async {
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
                        ]

                        // AFTER TAKING A PHOTO
                        else ...[
                          ElevatedButton.icon(
                            onPressed: vm.isBusy
                                ? null
                                : () async {
                                    try {
                                      await vm.clearImage();
                                    } catch (e) {
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Camera restart error: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Choose Again'),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: vm.isBusy
                                ? null
                                : () async {
                                    try {
                                      await vm.generateDesc();

                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'AI description generated. Check console.',
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
