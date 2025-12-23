import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Enum representing the various features that may have platform-specific support.
enum MediasfuFeature {
  /// Screen annotation/screenboard feature (web only).
  screenboard,

  /// Virtual backgrounds feature (mobile only - iOS/Android).
  virtualBackgrounds,

  /// Screen sharing feature (all platforms with platform-specific implementations).
  screenShare,

  /// Whiteboard feature (all platforms).
  whiteboard,
}

/// Utility class for checking platform-specific feature support.
///
/// This class provides methods to check whether specific MediaSFU features
/// are supported on the current platform and to get appropriate messages
/// for unsupported features.
///
/// Example:
/// ```dart
/// if (!PlatformFeatureSupport.isSupported(MediasfuFeature.screenboard)) {
///   final message = PlatformFeatureSupport.getUnsupportedMessage(MediasfuFeature.screenboard);
///   showAlert(message: message, type: 'danger');
///   return;
/// }
/// ```
class PlatformFeatureSupport {
  PlatformFeatureSupport._();

  /// Returns true if the current platform is web.
  static bool get isWeb => kIsWeb;

  /// Returns true if the current platform is Android.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Returns true if the current platform is iOS.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns true if the current platform is Windows.
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Returns true if the current platform is macOS.
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns true if the current platform is Linux.
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Returns true if the current platform is a mobile platform (iOS or Android).
  static bool get isMobile => isAndroid || isIOS;

  /// Returns true if the current platform is a desktop platform (Windows, macOS, or Linux).
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Returns the current platform name as a human-readable string.
  static String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }

  /// Checks if a specific feature is supported on the current platform.
  ///
  /// Returns `true` if the feature is supported, `false` otherwise.
  static bool isSupported(MediasfuFeature feature) {
    switch (feature) {
      case MediasfuFeature.screenboard:
        // Screenboard (screen annotation) is only supported on web
        return kIsWeb;

      case MediasfuFeature.virtualBackgrounds:
        // Virtual backgrounds are only supported on mobile (iOS/Android)
        // using ML Kit Selfie Segmentation
        return isMobile;

      case MediasfuFeature.screenShare:
        // Screen sharing is supported on all platforms with platform-specific implementations:
        // - Web: getDisplayMedia
        // - Android: MediaProjection with foreground service
        // - iOS: Broadcast Extension
        // - Desktop: flutter_webrtc desktop capturer
        return true;

      case MediasfuFeature.whiteboard:
        // Whiteboard is supported on all platforms
        return true;
    }
  }

  /// Returns the list of supported platforms for a given feature.
  static List<String> getSupportedPlatforms(MediasfuFeature feature) {
    switch (feature) {
      case MediasfuFeature.screenboard:
        return ['Web'];

      case MediasfuFeature.virtualBackgrounds:
        return ['Android', 'iOS'];

      case MediasfuFeature.screenShare:
        return ['Web', 'Android', 'iOS', 'Windows', 'macOS', 'Linux'];

      case MediasfuFeature.whiteboard:
        return ['Web', 'Android', 'iOS', 'Windows', 'macOS', 'Linux'];
    }
  }

  /// Returns a user-friendly message for when a feature is not supported.
  ///
  /// [feature] - The feature that is not supported.
  /// [includeAlternatives] - If true, includes information about alternative platforms.
  static String getUnsupportedMessage(
    MediasfuFeature feature, {
    bool includeAlternatives = true,
  }) {
    final featureName = _getFeatureName(feature);
    final supportedPlatforms = getSupportedPlatforms(feature);

    if (includeAlternatives && supportedPlatforms.isNotEmpty) {
      final platformsString = supportedPlatforms.join(', ');
      return '$featureName is not available on $platformName. '
          'This feature is only supported on: $platformsString.';
    }

    return '$featureName is not available on $platformName.';
  }

  /// Returns the human-readable name for a feature.
  static String _getFeatureName(MediasfuFeature feature) {
    switch (feature) {
      case MediasfuFeature.screenboard:
        return 'Screen Annotation (Screenboard)';
      case MediasfuFeature.virtualBackgrounds:
        return 'Virtual Backgrounds';
      case MediasfuFeature.screenShare:
        return 'Screen Sharing';
      case MediasfuFeature.whiteboard:
        return 'Whiteboard';
    }
  }

  /// Convenience method to check screenboard support.
  static bool get isScreenboardSupported =>
      isSupported(MediasfuFeature.screenboard);

  /// Convenience method to check virtual backgrounds support.
  static bool get isVirtualBackgroundsSupported =>
      isSupported(MediasfuFeature.virtualBackgrounds);

  /// Convenience method to check screen share support.
  static bool get isScreenShareSupported =>
      isSupported(MediasfuFeature.screenShare);

  /// Convenience method to check whiteboard support.
  static bool get isWhiteboardSupported =>
      isSupported(MediasfuFeature.whiteboard);
}
