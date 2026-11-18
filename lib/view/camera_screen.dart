import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/camera_viewmodel.dart';
import 'blind_mode_screen.dart';
import 'settings_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _selectedIndex = 0;

  // Shows camera or gallery failures without stopping the rest of the screen.
  void _reportIssue(String prefix, Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$prefix: $error')));
  }

  // Keeps Blind Mode tied to the same camera view model as the main screen.
  void _openBlindMode(CameraViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const BlindModeScreen(),
        ),
      ),
    );
  }

  // Switches between the camera and settings views.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..initialize(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [_cameraView(context), _settingsView(context)],
        ),
      ),
    );
  }

  // The settings page with a back button to return to the camera view.
  Widget _settingsView(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back to camera',
                    onPressed: () => setState(() => _selectedIndex = 0),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: SettingsScreen()),
          ],
        ),
      ),
    );
  }

  // Builds the main camera screen, including loading, preview, and controls.
  Widget _cameraView(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, vm, child) {
        if (!vm.isInitialized || vm.controller == null) {
          final colorScheme = Theme.of(context).colorScheme;
          return ColoredBox(
            color: colorScheme.surface,
            child: Center(
              child: Semantics(
                liveRegion: true,
                label: 'Starting camera',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Starting camera...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final hasImage = vm.imageBytes != null;

        return LayoutBuilder(
          builder: (context, constraints) {
            final colorScheme = Theme.of(context).colorScheme;
            final mediaQuery = MediaQuery.of(context);
            final topSpacing = mediaQuery.padding.top + 64;
            final bottomSpacing = mediaQuery.padding.bottom + 118;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: ColoredBox(color: colorScheme.surface)),
                Positioned(
                  top: topSpacing,
                  left: 12,
                  right: 12,
                  bottom: bottomSpacing,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.75,
                        ),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: SizedBox.expand(
                        child: hasImage
                            ? Image.memory(
                                vm.imageBytes!,
                                fit: BoxFit.cover,
                                semanticLabel: 'Selected image',
                              )
                            : _liveCameraPreview(vm.controller!, constraints),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                color: colorScheme.onSurface,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sight AI',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.onPrimary,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          button: true,
                          label: 'Open Blind Mode',
                          hint: 'Uses large controls and spoken assistance',
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9D648),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.onSurface,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => _openBlindMode(vm),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.accessibility_new_rounded,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Blind Mode',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _actionTray(
                      hasImage ? _reviewActions(vm) : _liveCameraActions(vm),
                      colorScheme,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Scales the live preview image to fill the frame without stretching.
  Widget _liveCameraPreview(
    CameraController controller,
    BoxConstraints constraints,
  ) {
    final isPortrait = constraints.maxHeight > constraints.maxWidth;
    final previewAspectRatio = isPortrait
        ? 1 / controller.value.aspectRatio
        : controller.value.aspectRatio;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: isPortrait ? 100 : 100 * previewAspectRatio,
          height: isPortrait ? 100 / previewAspectRatio : 100,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  // Gives the bottom buttons one shared menu with consistent spacing.
  Widget _actionTray(Widget child, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }

  // Shows the controls when the live camera is ready.
  Widget _liveCameraActions(CameraViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _secondaryAction(
            label: 'Gallery',
            icon: Icons.photo_library_rounded,
            onTap: vm.isBusy
                ? null
                : () async {
                    try {
                      await vm.selectFromGallery();
                    } catch (error) {
                      _reportIssue('Gallery error', error);
                    }
                  },
          ),
          Semantics(
            button: true,
            label: 'Take picture',
            hint: 'Capture a photo to analyze',
            child: Material(
              color: colorScheme.primaryContainer,
              shape: const CircleBorder(
                side: BorderSide(color: Color(0xFFFFFFFF), width: 4),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: vm.isBusy
                    ? null
                    : () async {
                        try {
                          await vm.capturePhoto();
                        } catch (error) {
                          _reportIssue('Camera error', error);
                        }
                      },
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          _secondaryAction(
            label: 'Settings',
            icon: Icons.settings_rounded,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ],
      ),
    );
  }

  // Smaller buttons for additional actions.
  Widget _secondaryAction({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 72,
        height: 82,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: colorScheme.outline),
                  ),
                ),
                child: Icon(icon, color: colorScheme.onSurface, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Buttons shown after an image has been taken.
  Widget _reviewActions(CameraViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Choose another image',
            child: OutlinedButton.icon(
              onPressed: vm.isBusy
                  ? null
                  : () async {
                      try {
                        await vm.clearImage();
                      } catch (error) {
                        _reportIssue('Camera restart error', error);
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(0, 58),
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Choose Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Describe image',
            hint: 'Analyze the selected image with AI',
            child: FilledButton.icon(
              onPressed: vm.isBusy
                  ? null
                  : () async {
                      try {
                        await vm.generateDesc();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'AI description generated. Check console.',
                            ),
                          ),
                        );
                      } catch (error) {
                        _reportIssue('AI error', error);
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                minimumSize: const Size(0, 58),
                side: BorderSide(color: colorScheme.outline, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                'Describe',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
