/// Translation Consumer Switch Utilities
///
/// Provides functions to switch between original audio and translated audio
/// by pausing/resuming the appropriate consumers.
///
/// Key concepts:
/// - When a user subscribes to a translation, the original audio consumer should be paused
/// - When translation stops or user unsubscribes, resume the original audio consumer
/// - Translation producers are consumed via the regular pipe producer flow (newPipeProducer)
/// - We just need to pause/resume the original audio consumers
/// - IMPORTANT: Must respect breakout room state - don't resume audio for speakers not in our room
///
/// The consumer transports array contains objects with:
/// - consumerTransport: The mediasoup Transport object
/// - serverConsumerTransportId: ID on the server
/// - producerId: The producer being consumed
/// - consumer: The mediasoup Consumer object
/// - socket_: The socket used for this transport
library;

import '../../types/types.dart'
    show
        TransportType,
        Participant,
        BreakoutParticipant,
        EventType,
        TranslationMeta;

// ============================================================================
// Types
// ============================================================================

/// Parameters for translation consumer switch operations
abstract class TranslationConsumerSwitchParameters {
  List<TransportType> get consumerTransports;
  String get roomName;
  String get member;
  void Function(List<TransportType>) get updateConsumerTransports;

  // Breakout room state
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  List<List<BreakoutParticipant>>? get breakoutRooms;
  List<BreakoutParticipant>? get limitedBreakRoom;
  List<Participant> get participants;
  List<Participant>? get refParticipants;
  String get islevel;
  EventType get eventType;
  int? get hostNewRoom;

  // Allow dynamic access for other parameters
  dynamic operator [](String key);
}

/// Options for pausing original producer
class PauseOriginalProducerOptions {
  final String originalProducerId;
  final String? speakerId;
  final TranslationConsumerSwitchParameters parameters;

  PauseOriginalProducerOptions({
    required this.originalProducerId,
    this.speakerId,
    required this.parameters,
  });
}

/// Options for resuming original producer
class ResumeOriginalProducerOptions {
  final String originalProducerId;
  final String? speakerId;
  final TranslationConsumerSwitchParameters parameters;

  ResumeOriginalProducerOptions({
    required this.originalProducerId,
    this.speakerId,
    required this.parameters,
  });
}

/// Options for stopping translation consumption
class StopConsumingTranslationOptions {
  final String speakerId;
  final String language;
  final Map<String, dynamic> translationProducerMap;
  final TranslationConsumerSwitchParameters parameters;

  StopConsumingTranslationOptions({
    required this.speakerId,
    required this.language,
    required this.translationProducerMap,
    required this.parameters,
  });
}

/// Result of checking if consuming translation for speaker
class TranslationConsumptionStatus {
  final bool consuming;
  final String? language;
  final String? translationProducerId;
  final String? originalProducerId;

  TranslationConsumptionStatus({
    required this.consuming,
    this.language,
    this.translationProducerId,
    this.originalProducerId,
  });
}

/// Active translation consumer info
class ActiveTranslationConsumer {
  final String speakerId;
  final String translationProducerId;
  final String originalProducerId;
  final String language;

  ActiveTranslationConsumer({
    required this.speakerId,
    required this.translationProducerId,
    required this.originalProducerId,
    required this.language,
  });
}

// ============================================================================
// Type Definitions
// ============================================================================

typedef PauseOriginalProducerType = Future<void> Function(
    PauseOriginalProducerOptions options);
typedef ResumeOriginalProducerType = Future<void> Function(
    ResumeOriginalProducerOptions options);
typedef StopConsumingTranslationType = Future<String?> Function(
    StopConsumingTranslationOptions options);

// ============================================================================
// Functions
// ============================================================================

/// Check if a speaker is in the current user's breakout room (or main room).
/// Returns true if the speaker's audio should be active (they are in our room).
///
/// This mirrors the logic in resumePauseAudioStreams.dart to ensure parity:
/// - In webinars: host audio is always active for non-hosts
/// - In conferences: host audio depends on hostNewRoom vs current user's room
/// - Regular participants: must be in the same limitedBreakRoom
bool isSpeakerInMyBreakoutRoom(
  String speakerName,
  TranslationConsumerSwitchParameters parameters,
) {
  final breakOutRoomStarted = parameters.breakOutRoomStarted;
  final breakOutRoomEnded = parameters.breakOutRoomEnded;
  final limitedBreakRoom = parameters.limitedBreakRoom ?? [];
  final participants = parameters.participants;
  final islevel = parameters.islevel;
  final eventType = parameters.eventType;
  final hostNewRoom = parameters.hostNewRoom ?? -1;
  final breakoutRooms = parameters.breakoutRooms ?? [];
  final member = parameters.member;

  // If breakout rooms are not active, everyone is in the same room
  if (!breakOutRoomStarted || breakOutRoomEnded) {
    return true;
  }

  // Check if the speaker is the host
  final host = participants.where((p) => p.islevel == '2').firstOrNull;
  final speakerIsHost = host?.name == speakerName;

  // If current user is NOT the host, apply host audio logic
  if (islevel != '2') {
    // For webinars, host audio is always included
    if (eventType == EventType.webinar && speakerIsHost) {
      return true;
    }

    // For conferences, check if host should be audible based on hostNewRoom
    if (eventType == EventType.conference && speakerIsHost) {
      // Find which breakout room the current user is in
      int memberBreakRoom = -1;
      for (int i = 0; i < breakoutRooms.length; i++) {
        if (breakoutRooms[i].any((p) => p.name == member)) {
          memberBreakRoom = i;
          break;
        }
      }
      final inBreakRoom = memberBreakRoom != -1;

      if (inBreakRoom) {
        // User is in a breakout room
        return memberBreakRoom == hostNewRoom;
      } else {
        // User is in main room
        if (hostNewRoom == -1) {
          return true; // Host is also in main room
        }
        return hostNewRoom == memberBreakRoom && memberBreakRoom != -1;
      }
    }
  }

  // For regular participants (non-host), check if they're in our limitedBreakRoom
  return limitedBreakRoom.any((p) => p.name == speakerName);
}

/// Pause the original audio producer consumer when switching to translation.
/// This saves bandwidth by not receiving audio we won't use.
///
/// NOTE: Only pauses if the speaker is in our breakout room. If they're not,
/// their audio is already paused by the breakout room logic.
Future<void> pauseOriginalProducer(PauseOriginalProducerOptions options) async {
  try {
    final originalProducerId = options.originalProducerId;
    final speakerId = options.speakerId;
    final parameters = options.parameters;
    final consumerTransports = parameters.consumerTransports;

    // If we have a speakerId, check if they're in our breakout room
    if (speakerId != null &&
        !isSpeakerInMyBreakoutRoom(speakerId, parameters)) {
      return;
    }

    // Find the consumer transport for this original producer
    final transport = consumerTransports.firstWhere(
      (t) => t.producerId == originalProducerId && t.consumer.kind == 'audio',
      orElse: () => throw Exception('Transport not found'),
    );

    // Check if already paused
    if (transport.consumer.paused) {
      return;
    }

    // Pause locally
    transport.consumer.pause();

    // Notify server
    transport.socket_.emit(
      'consumer-pause',
      {'serverConsumerId': transport.serverConsumerTransportId},
    );
  } catch (e) {
    // Transport not found or other error - silently ignore
  }
}

/// Resume the original audio producer consumer when translation stops.
///
/// NOTE: Only resumes if the speaker is in our breakout room. If they're not,
/// their audio should stay paused (controlled by breakout room logic).
Future<void> resumeOriginalProducer(
    ResumeOriginalProducerOptions options) async {
  try {
    final originalProducerId = options.originalProducerId;
    final speakerId = options.speakerId;
    final parameters = options.parameters;
    final consumerTransports = parameters.consumerTransports;

    // If we have a speakerId, check if they're in our breakout room
    if (speakerId != null &&
        !isSpeakerInMyBreakoutRoom(speakerId, parameters)) {
      return;
    }

    // Find the consumer transport for this original producer
    final transport = consumerTransports.firstWhere(
      (t) => t.producerId == originalProducerId && t.consumer.kind == 'audio',
      orElse: () => throw Exception('Transport not found'),
    );

    // Check if already resumed
    if (!transport.consumer.paused) {
      return;
    }

    // Resume on server first
    transport.socket_.emitWithAck(
      'consumer-resume',
      {'serverConsumerId': transport.serverConsumerTransportId},
      ack: (response) {
        if (response is Map && response['resumed'] == true) {
          transport.consumer.resume();
        }
      },
    );
  } catch (e) {
    // Transport not found or other error - silently ignore
  }
}

/// Check if we're currently consuming a translation for a given speaker.
/// Looks for consumers that have translation metadata attached.
TranslationConsumptionStatus isConsumingTranslationForSpeaker(
  String speakerId,
  List<TransportType> consumerTransports,
  Map<String, dynamic> translationProducerMap,
) {
  // Check our translation map for this speaker
  for (final entry in translationProducerMap.entries) {
    final producerId = entry.key;
    final meta = entry.value;

    if (meta is TranslationMeta) {
      if (meta.speakerId == speakerId) {
        // Verify we have a consumer for this translation producer
        final hasConsumer = consumerTransports.any(
          (t) => t.producerId == producerId,
        );

        if (hasConsumer) {
          return TranslationConsumptionStatus(
            consuming: true,
            language: meta.language,
            translationProducerId: producerId,
            originalProducerId: meta.originalProducerId,
          );
        }
      }
    }
  }

  return TranslationConsumptionStatus(consuming: false);
}

/// Get all active translation consumers from the map.
List<ActiveTranslationConsumer> getActiveTranslationConsumers(
  Map<String, dynamic> translationProducerMap,
  List<TransportType> consumerTransports,
  Map<String, String> speakerIdByProducerId,
) {
  final results = <ActiveTranslationConsumer>[];

  for (final entry in translationProducerMap.entries) {
    final producerId = entry.key;
    final meta = entry.value;

    if (meta is TranslationMeta) {
      // Verify we have an active consumer
      final hasConsumer = consumerTransports.any(
        (t) => t.producerId == producerId,
      );

      if (hasConsumer) {
        results.add(ActiveTranslationConsumer(
          speakerId: meta.speakerId,
          translationProducerId: producerId,
          originalProducerId: meta.originalProducerId,
          language: meta.language,
        ));
      }
    }
  }

  return results;
}

/// Find the original producer ID for a speaker from all audio streams.
/// This is needed when we receive a translation producer and need to pause the original.
String? findOriginalProducerForSpeaker(
  String speakerId,
  List<Map<String, dynamic>> allAudioStreams,
) {
  final stream = allAudioStreams.firstWhere(
    (s) =>
        s['name'] == speakerId ||
        (s['producerId'] as String?)?.contains(speakerId) == true,
    orElse: () => <String, dynamic>{},
  );
  return stream['producerId'] as String?;
}

/// Stop consuming a translation producer and close its consumer.
/// Returns the original producer ID if found, so caller can resume it.
///
/// Flow:
/// 1. Find the translation producer ID from the translation map
/// 2. Find the consumer transport for that producer
/// 3. Close the consumer (both locally and on server)
/// 4. Return the original producer ID for resuming
Future<String?> stopConsumingTranslation(
    StopConsumingTranslationOptions options) async {
  try {
    final language = options.language;
    final translationProducerMap = options.translationProducerMap;
    final parameters = options.parameters;
    final consumerTransports = parameters.consumerTransports;
    final updateConsumerTransports = parameters.updateConsumerTransports;

    // Find the original producer ID and translation producer ID from the map
    String? originalProducerId;
    String? translationProducerId;

    for (final entry in translationProducerMap.entries) {
      final pid = entry.key;
      final meta = entry.value;
      if (meta is TranslationMeta) {
        if (meta.language == language && meta.speakerId == options.speakerId) {
          translationProducerId = pid;
          originalProducerId = meta.originalProducerId;
          break;
        }
      }
    }

    if (translationProducerId == null) {
      return originalProducerId;
    }

    // Find the consumer transport for the translation producer
    final transportIndex = consumerTransports.indexWhere(
      (t) => t.producerId == translationProducerId,
    );

    if (transportIndex == -1) {
      return originalProducerId;
    }

    final transport = consumerTransports[transportIndex];

    // Close the consumer on the server
    transport.socket_.emit(
      'consumer-close',
      {'serverConsumerId': transport.serverConsumerTransportId},
    );

    // Close the consumer locally
    transport.consumer.close();

    // Remove from consumer transports array
    final updatedTransports = List<TransportType>.from(consumerTransports);
    updatedTransports.removeAt(transportIndex);
    updateConsumerTransports(updatedTransports);

    return originalProducerId;
  } catch (e) {
    return null;
  }
}

/// Handle breakout room changes for translation audio.
///
/// When a user moves between breakout rooms, we need to re-evaluate
/// which translation streams should be active:
/// - Resume original audio for speakers now in our room (if no translation active)
/// - The breakout room audio logic (resumePauseAudioStreams) will handle pausing
///   speakers not in our room
///
/// This function is called after breakout room updates to sync translation state.
Future<void> syncTranslationStateAfterBreakoutChange(
  Map<String, dynamic> translationProducerMap,
  Map<String, String> speakerIdByProducerId,
  TranslationConsumerSwitchParameters parameters,
) async {
  try {
    final consumerTransports = parameters.consumerTransports;

    // For each active translation, check if the speaker is now in our room or not
    for (final entry in translationProducerMap.entries) {
      final originalProducerId = entry.key;
      final langMap = entry.value;

      final speakerId = speakerIdByProducerId[originalProducerId];
      if (speakerId == null) continue;

      final inMyRoom = isSpeakerInMyBreakoutRoom(speakerId, parameters);
      final hasTranslation = langMap.isNotEmpty;

      // Find the original producer's consumer
      TransportType? originalTransport;
      try {
        originalTransport = consumerTransports.firstWhere(
          (t) =>
              t.producerId == originalProducerId && t.consumer.kind == 'audio',
        );
      } catch (e) {
        continue; // Not found
      }

      if (inMyRoom && hasTranslation) {
        // Speaker is in our room and we have translation - original should be paused
        if (!originalTransport.consumer.paused) {
          await pauseOriginalProducer(PauseOriginalProducerOptions(
            originalProducerId: originalProducerId,
            speakerId: speakerId,
            parameters: parameters,
          ));
        }
      }
      // Note: If speaker is NOT in our room, the breakout room audio logic
      // (resumePauseAudioStreams) will handle pausing their audio.
    }
  } catch (e) {
    // Handle error silently
  }
}
