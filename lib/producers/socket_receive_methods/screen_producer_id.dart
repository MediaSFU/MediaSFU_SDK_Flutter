import '../../types/types.dart' show Participant;

/// Options for managing and updating screen sharing based on the producer ID.
class ScreenProducerIdOptions {
  final String producerId;
  final String screenId;
  final bool membersReceived;
  final bool shareScreenStarted;
  final bool deferScreenReceived;
  final List<Participant> participants;
  final void Function(String) updateScreenId;
  final void Function(bool) updateShareScreenStarted;
  final void Function(bool) updateDeferScreenReceived;

  ScreenProducerIdOptions({
    required this.producerId,
    required this.screenId,
    required this.membersReceived,
    required this.shareScreenStarted,
    required this.deferScreenReceived,
    required this.participants,
    required this.updateScreenId,
    required this.updateShareScreenStarted,
    required this.updateDeferScreenReceived,
  });
}

/// Type definition for the screen producer ID function.
typedef ScreenProducerIdType = void Function(ScreenProducerIdOptions options);

/// Manages and updates screen sharing based on the producer ID.
///
/// @param [ScreenProducerIdOptions] options - The configuration options.
/// - `producerId`: The producer's unique ID for screen sharing.
/// - `screenId`: The current screen ID.
/// - `membersReceived`: Indicates if member data has been received.
/// - `shareScreenStarted`: Indicates if screen sharing has started.
/// - `deferScreenReceived`: Indicates if screen sharing should be deferred.
/// - `participants`: List of participants.
/// - `updateScreenId`: Function to update the screen ID.
/// - `updateShareScreenStarted`: Function to update the screen sharing status.
/// - `updateDeferScreenReceived`: Function to update the defer screen sharing status.
///
/// Example usage:
/// ```dart
/// final options = ScreenProducerIdOptions(
///   producerId: 'abc123',
///   screenId: 'screen1',
///   membersReceived: true,
///   shareScreenStarted: false,
///   deferScreenReceived: false,
///   participants: [Participant(screenId: 'screen1', screenOn: true)],
///   updateScreenId: (id) => print('Screen ID updated to: $id'),
///   updateShareScreenStarted: (started) => print('Share screen started: $started'),
///   updateDeferScreenReceived: (received) => print('Defer screen received: $received'),
/// );
///
/// screenProducerId(options);
/// ```
void screenProducerId(ScreenProducerIdOptions options) {
  // Check if members data has been received with the screenId participant in it
  final host = options.participants.firstWhere(
    (participant) =>
        participant.ScreenID == options.screenId &&
        participant.ScreenOn == true,
    orElse: () => Participant(
        ScreenID: '',
        ScreenOn: false,
        audioID: 'none',
        videoID: 'none',
        name: ''),
  );

  // Update UI state based on conditions
  if (host.name.isNotEmpty && options.membersReceived) {
    options.updateScreenId(options.producerId);
    options.updateShareScreenStarted(true);
    options.updateDeferScreenReceived(false);
  } else {
    options.updateScreenId(options.producerId);
    options.updateDeferScreenReceived(true);
  }
}
