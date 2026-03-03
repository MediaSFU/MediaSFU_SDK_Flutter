import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Screen Wake Lock utility for keeping the screen on during calls.
///
/// This utility prevents the screen from dimming or locking during video calls,
/// which is essential for a good VoIP/meeting experience.
///
/// Usage:
/// ```dart
/// // Enable wake lock when joining a call
/// await ScreenWakeLock.enable();
///
/// // Disable when leaving the call
/// await ScreenWakeLock.disable();
/// ```
class ScreenWakeLock {
  static const MethodChannel _channel =
      MethodChannel('com.mediasfu/screen_wake_lock');

  static bool _isEnabled = false;

  /// Whether wake lock is currently enabled
  static bool get isEnabled => _isEnabled;

  /// Whether wake lock is supported on the current platform
  static bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Enable screen wake lock - prevents screen from dimming/locking
  static Future<bool> enable() async {
    if (!isSupported) {
      debugPrint('ScreenWakeLock: Not supported on this platform');
      return false;
    }

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('enable');
      _isEnabled = result?['success'] == true;
      debugPrint(
          'ScreenWakeLock: ${_isEnabled ? "Enabled" : "Failed to enable"}');
      return _isEnabled;
    } catch (e) {
      debugPrint('ScreenWakeLock: Error enabling - $e');
      return false;
    }
  }

  /// Disable screen wake lock - allows screen to dim/lock normally
  static Future<bool> disable() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('disable');
      _isEnabled = !(result?['success'] == true);
      debugPrint(
          'ScreenWakeLock: ${!_isEnabled ? "Disabled" : "Failed to disable"}');
      return !_isEnabled;
    } catch (e) {
      debugPrint('ScreenWakeLock: Error disabling - $e');
      return false;
    }
  }

  /// Check if wake lock is currently enabled on the system level
  static Future<bool> checkEnabled() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('isEnabled');
      _isEnabled = result?['enabled'] == true;
      return _isEnabled;
    } catch (e) {
      debugPrint('ScreenWakeLock: Error checking status - $e');
      return false;
    }
  }
}
