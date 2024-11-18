import 'package:flutter/foundation.dart';
import '../../types/types.dart' show CoHostResponsibility, EventType, ShowAlert;

/// Represents the options for updating co-host status and responsibilities.
class UpdatedCoHostOptions {
  final String coHost;
  final List<CoHostResponsibility> coHostResponsibility;
  final ShowAlert? showAlert;
  final EventType eventType;
  final String islevel;
  final String member;
  final bool youAreCoHost;
  final void Function(String) updateCoHost;
  final void Function(List<CoHostResponsibility>) updateCoHostResponsibility;
  final void Function(bool) updateYouAreCoHost;

  UpdatedCoHostOptions({
    required this.coHost,
    required this.coHostResponsibility,
    this.showAlert,
    required this.eventType,
    required this.islevel,
    required this.member,
    required this.youAreCoHost,
    required this.updateCoHost,
    required this.updateCoHostResponsibility,
    required this.updateYouAreCoHost,
  });
}

typedef UpdatedCoHostType = Future<void> Function(UpdatedCoHostOptions options);

/// Updates co-host information and responsibilities based on provided options.
///
/// This function checks the event type and level to conditionally update
/// co-host information, responsibilities, and the current user's co-host status.
///
/// Example usage:
/// ```dart
/// updatedCoHost(
///   UpdatedCoHostOptions(
///     coHost: "user123",
///     coHostResponsibility: [CoHostResponsibility("moderate", true)],
///     showAlert: (message, type, duration) => print("Alert: $message"),
///     eventType: EventType.conference,
///     islevel: "1",
///     member: "user123",
///     youAreCoHost: false,
///     updateCoHost: (host) => print("Updated co-host: $host"),
///     updateCoHostResponsibility: (resps) => print("Responsibilities: $resps"),
///     updateYouAreCoHost: (status) => print("You are now co-host: $status"),
///   ),
/// );
/// ```

void updatedCoHost(UpdatedCoHostOptions options) async {
  try {
    if (options.eventType != EventType.broadcast &&
        options.eventType != EventType.chat) {
      // Update co-host if event type is not broadcast or chat
      options.updateCoHost(options.coHost);
      options.updateCoHostResponsibility(options.coHostResponsibility);

      if (options.member == options.coHost) {
        if (!options.youAreCoHost) {
          options.updateYouAreCoHost(true);
          options.showAlert?.call(
            message: 'You are now a co-host.',
            type: 'success',
            duration: 3000,
          );
        }
      } else {
        options.updateYouAreCoHost(false);
      }
    } else if (options.islevel != '2') {
      options.updateYouAreCoHost(true);
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error in updatedCoHost: $error");
    }
  }
}
