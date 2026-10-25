
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../viewmodel/camera_viewmodel.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';
import 'blind_mode_screen.dart';
import 'delete_account_screen.dart';
import 'settings_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _selectedIndex == 0 ? 'Sight AI Camera' : 'Settings',
              ),
              centerTitle: true,
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildCameraTab(context),
                const SettingsScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(Icons.camera_alt),
                  label: 'Camera',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraTab(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, vm, child) {
        if (!vm.isInitialized || vm.controller == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double cameraWidth = constraints.maxWidth > 500
                ? 450
                : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: vm,
                              child: const BlindModeScreen(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.accessibility_new),
                      label: const Text('Open Blind Mode'),
                    ),

                    const SizedBox(height: 20),

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
                              aspectRatio: 1 / vm.controller!.value.aspectRatio,
                              child: CameraPreview(vm.controller!),
                            ),
                          ),
                    ),

                    const SizedBox(height: 24),

                    
                    if (vm.imageBytes == null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: vm.isBusy
                                    ? null
                                    : () async {
                                        try {
                                          await vm.selectFromGallery();
                                        } catch (e) {
                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Gallery error: $e'),
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: vm.isBusy
                                    ? null
                                    : () async {
                                        try {
                                          await vm.capturePhoto();
                                        } catch (e) {
                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Camera error: $e'),
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Take Picture'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: vm.isBusy
                            ? null
                            : () async {
                                try {
                                  await vm.clearImage();
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Camera restart error: $e'),
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

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'AI description generated. Check console.',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('AI error: $e'),
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
    );
  }
}
