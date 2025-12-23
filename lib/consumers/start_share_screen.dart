import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../types/types.dart'
    show
        ShowAlert,
        StreamSuccessScreenType,
        StreamSuccessScreenParameters,
        StreamSuccessScreenOptions;

/// Method channel for Android foreground service control
const _screenCaptureChannel = MethodChannel('com.mediasfu/screen_capture');

/// Starts the foreground service for screen capture on Android.
/// This MUST be called before requesting screen capture on Android 10+ (API 29+).
/// On Android 14+ (API 34), failing to start this service will crash the app.
Future<void> _startAndroidForegroundService() async {
  if (kIsWeb) return;
  try {
    if (Platform.isAndroid) {
      await _screenCaptureChannel.invokeMethod('startForegroundService');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Warning: Could not start foreground service: $e');
    }
  }
}

/// Stops the foreground service for screen capture on Android.
Future<void> _stopAndroidForegroundService() async {
  if (kIsWeb) return;
  try {
    if (Platform.isAndroid) {
      await _screenCaptureChannel.invokeMethod('stopForegroundService');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Warning: Could not stop foreground service: $e');
    }
  }
}

/// Parameters for starting screen sharing.
abstract class StartShareScreenParameters
    implements StreamSuccessScreenParameters {
  // Properties as abstract getters
  bool get shared;
  ShowAlert? get showAlert;
  bool get onWeb;

  // Update function as an abstract getter
  Function(bool) get updateShared;

  // Mediasfu function as an abstract getter
  StreamSuccessScreenType get streamSuccessScreen;

  // Dynamic access operator for additional properties
  // dynamic operator [](String key);
}

/// Options for starting screen sharing.
class StartShareScreenOptions {
  StartShareScreenParameters parameters;
  int? targetWidth;
  int? targetHeight;
  BuildContext? context; // Required for desktop platforms to show screen picker

  StartShareScreenOptions({
    required this.parameters,
    this.targetWidth,
    this.targetHeight,
    this.context,
  });
}

/// Function type for starting screen sharing.
typedef StartShareScreenType = Future<void> Function(
    StartShareScreenOptions options);

/// Checks if screen sharing is supported on the current platform.
///
/// Returns true for:
/// - Web (all browsers with getDisplayMedia support)
/// - Windows, macOS, Linux (desktop)
/// - Android (via MediaProjection API)
///
/// Returns false for:
/// - iOS (requires Broadcast Upload Extension - complex native setup)
bool _isScreenShareSupported() {
  if (kIsWeb) return true;

  // Check platform - Android and desktop support getDisplayMedia
  try {
    if (Platform.isAndroid) return true;
    if (Platform.isWindows) return true;
    if (Platform.isMacOS) return true;
    if (Platform.isLinux) return true;
    // iOS requires Broadcast Upload Extension which needs native setup
    if (Platform.isIOS) return false;
  } catch (_) {
    // Platform not available (shouldn't happen)
    return false;
  }
  return false;
}

/// Returns a platform-specific message for unsupported screen sharing.
String _getUnsupportedMessage() {
  if (kIsWeb) return 'Screen sharing is not supported in this browser';

  try {
    if (Platform.isIOS) {
      return 'Screen sharing on iOS requires additional native setup. '
          'Please contact the app developer for iOS screen sharing support.';
    }
  } catch (_) {}

  return 'Screen sharing is not supported on this platform';
}

/// Checks if we need to use desktopCapturer for screen selection.
/// Desktop platforms (Windows, macOS, Linux) don't have a native screen picker
/// dialog like browsers do, so we need to manually select a source.
bool _needsDesktopCapturer() {
  if (kIsWeb) return false;
  try {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  } catch (_) {
    return false;
  }
}

/// A stateful widget that displays screen/window picker with live thumbnails
class _ScreenPickerDialog extends StatefulWidget {
  final List<DesktopCapturerSource> sources;

  const _ScreenPickerDialog({required this.sources});

  @override
  State<_ScreenPickerDialog> createState() => _ScreenPickerDialogState();
}

class _ScreenPickerDialogState extends State<_ScreenPickerDialog> {
  int _selectedIndex = 0;
  String _selectedTab = 'screens'; // 'screens' or 'windows'

  List<DesktopCapturerSource> get screens =>
      widget.sources.where((s) => s.type == SourceType.Screen).toList();

  List<DesktopCapturerSource> get windows =>
      widget.sources.where((s) => s.type == SourceType.Window).toList();

  List<DesktopCapturerSource> get currentSources =>
      _selectedTab == 'screens' ? screens : windows;

  @override
  Widget build(BuildContext context) {
    final hasScreens = screens.isNotEmpty;
    final hasWindows = windows.isNotEmpty;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 680,
        height: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.screen_share, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Choose what to share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab buttons
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasScreens)
                    _buildTabButton(
                      'Entire Screen',
                      Icons.desktop_windows,
                      'screens',
                    ),
                  if (hasWindows)
                    _buildTabButton(
                      'Window',
                      Icons.web_asset,
                      'windows',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid of sources with thumbnails
            Expanded(
              child: currentSources.isEmpty
                  ? Center(
                      child: Text(
                        _selectedTab == 'screens'
                            ? 'No screens available'
                            : 'No windows available',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 16 / 10,
                      ),
                      itemCount: currentSources.length,
                      itemBuilder: (context, index) {
                        final source = currentSources[index];
                        final isSelected = _selectedIndex == index;
                        return _buildSourceTile(source, index, isSelected);
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: currentSources.isNotEmpty
                      ? () => Navigator.of(context)
                          .pop(currentSources[_selectedIndex])
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, String tab) {
    final isSelected = _selectedTab == tab;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = tab;
          _selectedIndex = 0;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4285F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTile(
      DesktopCapturerSource source, int index, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      onDoubleTap: () {
        Navigator.of(context).pop(source);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF4285F4) : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2D2D2D),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                child: Container(
                  color: const Color(0xFF1A1A1A),
                  child: source.thumbnail != null
                      ? Image.memory(
                          source.thumbnail!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(source);
                          },
                        )
                      : _buildPlaceholder(source),
                ),
              ),
            ),
            // Name label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4285F4).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Text(
                source.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(DesktopCapturerSource source) {
    return Center(
      child: Icon(
        source.type == SourceType.Screen
            ? Icons.desktop_windows
            : Icons.web_asset,
        size: 48,
        color: Colors.white24,
      ),
    );
  }
}

/// Shows a dialog for the user to select which screen or window to share.
/// Returns the selected source, or null if cancelled.
Future<DesktopCapturerSource?> _showScreenPickerDialog(
    BuildContext context) async {
  // Get available screen and window sources with thumbnails
  final sources = await desktopCapturer.getSources(
    types: [SourceType.Screen, SourceType.Window],
    thumbnailSize: ThumbnailSize(320, 180), // 16:9 aspect ratio thumbnails
  );

  if (sources.isEmpty) {
    return null;
  }

  // If there's only one screen and no windows, use it directly
  final screens = sources.where((s) => s.type == SourceType.Screen).toList();
  if (screens.length == 1 && sources.length == 1) {
    return screens.first;
  }

  // Show the enhanced picker dialog
  return showDialog<DesktopCapturerSource>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _ScreenPickerDialog(sources: sources);
    },
  );
}

/// Starts the screen sharing process.
///
/// Supports the following platforms:
/// - **Web**: Uses browser's getDisplayMedia API
/// - **Android**: Uses MediaProjection API (user will see a permission dialog)
/// - **Windows/macOS/Linux**: Uses native screen capture APIs with source picker
/// - **iOS**: Not supported (requires Broadcast Upload Extension)
///
/// @param [StartShareScreenOptions] options - The options for starting screen sharing.
/// @param [StartShareScreenParameters] options.parameters - The parameters for screen sharing.
///
/// This function displays an alert if screen sharing fails or is not supported.
/// It also calls the `streamSuccessScreen` function when sharing is successful.
///
/// Example:
/// ```dart
/// final options = StartShareScreenOptions(
///   parameters: StartShareScreenParameters(
///     shared: false,
///     showAlert: (msg, type, duration) => print(msg),
///     updateShared: (isShared) => print("Shared: $isShared"),
///     onWeb: true,
///     streamSuccessScreen: (stream, parameters) async => print("Success"),
///   ),
///  targetWidth: 1920,
///  targetHeight: 1080,
/// );
/// await startShareScreen(options);
/// ```

Future<void> startShareScreen(StartShareScreenOptions options) async {
  final targetWidth = options.targetWidth ?? 1280;
  final targetHeight = options.targetHeight ?? 720;
  final parameters = options.parameters;
  bool shared = parameters.shared;
  final showAlert = parameters.showAlert;
  final updateShared = parameters.updateShared;
  final streamSuccessScreen = parameters.streamSuccessScreen;

  try {
    // Check if screen sharing is supported on this platform
    if (!_isScreenShareSupported()) {
      if (showAlert != null) {
        showAlert(
          message: _getUnsupportedMessage(),
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // On Android, start foreground service BEFORE requesting screen capture
    // This is REQUIRED on Android 10+ (API 29) and MANDATORY on Android 14+ (API 34)
    // Without this, the app will crash when trying to start MediaProjection
    await _startAndroidForegroundService();

    // Request screen capture using getDisplayMedia
    // This works on Web, Android, Windows, macOS, and Linux
    try {
      MediaStream stream;

      // Desktop platforms need to use desktopCapturer to select a source
      if (_needsDesktopCapturer()) {
        final context = options.context;
        if (context == null) {
          // No context provided - try to get sources directly and use first screen
          final sources = await desktopCapturer.getSources(
            types: [SourceType.Screen],
          );

          if (sources.isEmpty) {
            await _stopAndroidForegroundService();
            throw Exception('No screens available to share');
          }

          // Use the first screen
          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': {
              'deviceId': {'exact': sources.first.id},
              'width': targetWidth,
              'height': targetHeight,
              'frameRate': 30
            },
            'audio': false
          });
        } else {
          // Show screen picker dialog
          final selectedSource = await _showScreenPickerDialog(context);
          if (selectedSource == null) {
            // User cancelled
            await _stopAndroidForegroundService();
            updateShared(false);
            return;
          }

          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': {
              'deviceId': {'exact': selectedSource.id},
              'width': targetWidth,
              'height': targetHeight,
              'frameRate': 30
            },
            'audio': false
          });
        }
      } else {
        // Web and Android use standard getDisplayMedia with native picker
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': {
            'cursor': 'always',
            'width': targetWidth,
            'height': targetHeight,
            'frameRate': 30
          },
          'audio': false
        });
      }

      try {
        final optionsStream = StreamSuccessScreenOptions(
          stream: stream,
          parameters: parameters,
        );
        await streamSuccessScreen(optionsStream);
      } catch (_) {}
      shared = true;
    } catch (error) {
      shared = false;

      // Stop foreground service on error
      await _stopAndroidForegroundService();

      String errorMessage = 'Could not share screen, check and retry';

      // Provide more specific error messages
      if (error.toString().contains('NotAllowedError') ||
          error.toString().contains('Permission')) {
        errorMessage =
            'Screen sharing permission denied. Please allow screen capture and try again.';
      } else if (error.toString().contains('NotFoundError') ||
          error.toString().contains('source not found')) {
        errorMessage = 'No screen found to share.';
      } else if (error.toString().contains('NotSupportedError')) {
        errorMessage = 'Screen sharing is not supported on this device.';
      } else if (error.toString().contains('cancelled') ||
          error.toString().contains('canceled')) {
        // User cancelled - not an error
        updateShared(false);
        return;
      }

      showAlert?.call(
        message: errorMessage,
        type: 'danger',
        duration: 3000,
      );

      if (kDebugMode) {
        print('Screen share error: $error');
      }
    }

    // Update the shared variable
    updateShared(shared);
  } catch (error) {
    if (kDebugMode) {
      print('Error starting screen share: $error');
    }
    rethrow;
  }
}
