import 'package:flutter/foundation.dart';
import '../types/types.dart' show Participant, TransportType;

abstract class ResumePauseStreamsParameters {
  // Properties as abstract getters
  List<Participant> get participants;
  List<String> get dispActiveNames;
  List<TransportType> get consumerTransports;
  String? get screenId;
  String get islevel;

  // Method to retrieve updated parameters
  ResumePauseStreamsParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ResumePauseStreamsOptions {
  final ResumePauseStreamsParameters parameters;

  ResumePauseStreamsOptions({required this.parameters});
}

typedef ResumePauseStreamsType = Future<void> Function(
    {required ResumePauseStreamsOptions options});

/// Resumes or pauses video streams based on active participants and display names.
///
/// This function manages the resumption of specific video streams (excluding audio) for participants
/// in a virtual session. It identifies the relevant video IDs from active display names, screen sharing IDs,
/// and the host's video ID, then resumes each associated transport.
///
/// - If the user level is not the host (`islevel` is not "2"), the host's video ID is also included for resumption.
/// - If active video IDs are found, the function resumes the associated transports by emitting a `consumer-resume` event
///   for each video transport.
///
/// Parameters:
/// - [options]: An instance of `ResumePauseStreamsOptions`, containing the necessary parameters
///   such as participants, display names, transport connections, and user level.
///
/// Example:
/// ```dart
/// final options = ResumePauseStreamsOptions(
///   parameters: ResumePauseStreamsParameters(
///     participants: [
///       Participant(audioID: 'a1', videoID: 'v1', name: 'User1'),
///       Participant(audioID: 'a2', videoID: 'v2', name: 'Host', islevel: '2'),
///     ],
///     dispActiveNames: ['User1', 'Host'],
///     consumerTransports: [
///       Transport(producerId: 'v1', consumer: consumer1, serverConsumerTransportId: 's1'),
///       Transport(producerId: 'v2', consumer: consumer2, serverConsumerTransportId: 's2'),
///     ],
///     screenId: 'screen1',
///     islevel: '1',
///     getUpdatedAllParams: () => updatedParams,
///   ),
/// );
///
/// await resumePauseStreams(options: options);
/// ```

Future<void> resumePauseStreams({
  required ResumePauseStreamsOptions options,
}) async {
  final parameters = options.parameters;
  final updatedParams = parameters.getUpdatedAllParams();

  List<Participant> participants = updatedParams.participants;
  List<String> dispActiveNames = updatedParams.dispActiveNames;
  List<TransportType> consumerTransports = updatedParams.consumerTransports;
  String? screenId = updatedParams.screenId;
  String islevel = updatedParams.islevel;

  try {
    // Retrieve host's video ID if user level is 2
    final host = participants.firstWhere(
        (participant) => participant.islevel == '2',
        orElse: () => Participant(audioID: '', videoID: '', name: ''));
    final String? hostVideoID = host.name.isNotEmpty ? host.videoID : null;

    // Collect video IDs of active display names and the screen producer ID
    final List<String?> videosIDs = dispActiveNames.map((name) {
      final participant = participants.firstWhere(
          (participant) => participant.name == name,
          orElse: () => Participant(audioID: '', videoID: '', name: ''));
      return participant.videoID;
    }).toList();

    // Add screen ID if available
    if (screenId != null && screenId.isNotEmpty) {
      videosIDs.add(screenId);
    }

    // Include host's video ID if user is not the host
    if (islevel != '2' && hostVideoID != null && hostVideoID.isNotEmpty) {
      videosIDs.add(hostVideoID);
    }

    // Filter non-null and non-empty video IDs
    final List<String> allVideoIDs = videosIDs.whereType<String>().toList();

    if (allVideoIDs.isNotEmpty) {
      // Filter consumer transports to resume based on video IDs and non-audio kind
      final consumerTransportsToResume = consumerTransports.where((transport) =>
          allVideoIDs.contains(transport.producerId) &&
          transport.consumer.track.kind != 'audio');

      // Emit 'consumer-resume' and resume each transport's consumer if acknowledged
      // Note 'serverConsumerId' is 'transport.consumer.id' not 'serverconsumerTransportId'
      for (var transport in consumerTransportsToResume) {
        transport.socket_.emitWithAck(
          'consumer-resume',
          {'serverConsumerId': transport.consumer.id},
          ack: (response) async {
            if (response['resumed'] == true) {
              transport.consumer.resume();
            }
          },
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during resuming or pausing streams: $error');
    }
  }
}
