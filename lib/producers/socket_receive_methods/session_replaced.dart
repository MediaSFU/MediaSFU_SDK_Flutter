import 'dart:async';
import 'package:flutter/material.dart';
import '../../types/types.dart' show ShowAlert;

/// Message shown when a newer connection of this participant took over.
const String sessionReplacedMessage = 'You joined from another tab or device.';

DateTime? _replacedAt;

/// True shortly after `session-replaced` arrived. The disconnect that follows is then expected: no generic
/// "disconnected" alert, and never an automatic rejoin (which would push the other connection out in turn).
bool wasSessionReplaced({Duration within = const Duration(seconds: 15)}) {
  final at = _replacedAt;
  return at != null && DateTime.now().difference(at) < within;
}

/// Options for [sessionReplaced].
///
/// [data] is the server payload (`roomName`, `member`, `reason`, `sessionSeq`). [useThisOne] takes the session over
/// deliberately (the SDK components reconnect with the credentials this connection used). Without a [context] the
/// message is shown through [showAlert].
class SessionReplacedOptions {
  final Map<String, dynamic>? data;
  final ShowAlert? showAlert;
  final BuildContext? context;
  final FutureOr<void> Function()? useThisOne;

  SessionReplacedOptions({this.data, this.showAlert, this.context, this.useThisOne});
}

typedef SessionReplacedType = Future<void> Function(SessionReplacedOptions options);

/// Handles the media server's `session-replaced` event (servers with participant-rejoin-v1): another tab, device or
/// a reload of this participant took over, and the server closes this connection right after. Shows
/// "You joined from another tab or device." with a "Use this one" action, and never rejoins on its own.
///
/// ```dart
/// socket.on('session-replaced', (data) => sessionReplaced(SessionReplacedOptions(
///   data: data is Map ? Map<String, dynamic>.from(data) : null, showAlert: showAlert, context: context)));
/// ```
Future<void> sessionReplaced(SessionReplacedOptions options) async {
  _replacedAt = DateTime.now();
  final context = options.context;
  if (context == null || !context.mounted) {
    options.showAlert?.call(message: sessionReplacedMessage, type: 'danger', duration: 8000);
    return;
  }
  unawaited(showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(sessionReplacedMessage),
      content: const Text('This window left the room so the other one could stay.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            _replacedAt = null;
            final takeOver = options.useThisOne;
            if (takeOver != null) unawaited(Future.sync(takeOver));
          },
          child: const Text('Use this one'),
        ),
      ],
    ),
  ));
}
