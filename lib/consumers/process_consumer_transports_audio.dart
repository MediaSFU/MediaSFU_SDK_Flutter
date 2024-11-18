import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show TransportType, SleepType, SleepOptions, Stream;

abstract class ProcessConsumerTransportsAudioParameters {
  // Property as an abstract getter
  SleepType get sleep;

  // Method to retrieve updated parameters
  ProcessConsumerTransportsAudioParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ProcessConsumerTransportsAudioOptions {
  final List<TransportType> consumerTransports;
  final List<Stream> lStreams;
  final ProcessConsumerTransportsAudioParameters parameters;

  ProcessConsumerTransportsAudioOptions({
    required this.consumerTransports,
    required this.lStreams,
    required this.parameters,
  });
}

typedef ProcessConsumerTransportsAudioType = Future<void> Function(
    ProcessConsumerTransportsAudioOptions options);

/// Adjusts the audio state of consumer transports based on provided streams.
///
/// This function examines each audio consumer transport:
/// - If a transport's `producerId` matches an entry in `lStreams` and is currently paused, it resumes the transport.
/// - If a transport's `producerId` does not match any entry in `lStreams` and is unpaused, it pauses the transport.
/// - The function incorporates a delay before pausing to allow for smoother transitions.
///
/// ### Parameters:
/// - `options` (`ProcessConsumerTransportsAudioOptions`):
///   - `consumerTransports`: List of audio transports that may need to be paused or resumed.
///   - `lStreams`: List of streams that represent valid audio sources for the transports.
///   - `parameters`: Contains:
///     - `sleep`: A function to add a delay before pausing a transport.
///     - `getUpdatedAllParams`: A function that refreshes the parameters used for transport processing.
///
/// ### Behavior:
/// - **Pausing and Resuming**: Pauses transports not found in `lStreams` and resumes those that are.
/// - **Delay Handling**: A short delay is added before pausing transports to optimize timing for smooth state transitions.
/// - **Socket Events**: Emits `consumer-pause` and `consumer-resume` events to the server to synchronize transport states.
///
/// ### Example Usage:
/// ```dart
/// final parameters = ProcessConsumerTransportsAudioParameters(
///   sleep: (options) async => await Future.delayed(Duration(milliseconds: options.ms)),
///   getUpdatedAllParams: () => updatedParams, // Returns the latest parameters
/// );
///
/// await processConsumerTransportsAudio(
///   ProcessConsumerTransportsAudioOptions(
///     consumerTransports: [transport1, transport2],
///     lStreams: [stream1, stream2],
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Logs any errors encountered during the processing of transports in debug mode.

Future<void> processConsumerTransportsAudio(
    ProcessConsumerTransportsAudioOptions options) async {
  // Retrieve and destructure updated parameters
  final ProcessConsumerTransportsAudioParameters parameters =
      options.parameters.getUpdatedAllParams();
  final SleepType sleep = parameters.sleep;

  final List<TransportType> consumerTransports = options.consumerTransports;
  final List<Stream> lStreams = options.lStreams;

  try {
    // Helper function to check if producerId exists in any provided stream array
    bool isValidProducerId(String producerId, List<List<Stream>> streamArrays) {
      return producerId.isNotEmpty &&
          streamArrays.any((streamArray) =>
              streamArray.isNotEmpty &&
              streamArray.any((stream) => stream.producerId == producerId));
    }

    // Get paused consumer transports that are audio
    final consumerTransportsToResume = consumerTransports.where((transport) =>
        isValidProducerId(transport.producerId, [lStreams]) &&
        transport.consumer.paused == true &&
        transport.consumer.track.kind == 'audio');

    // Get unpaused consumer transports that are audio and not in lStreams
    final consumerTransportsToPause = consumerTransports.where((transport) =>
        transport.producerId.isNotEmpty &&
        transport.producerId != "" &&
        !lStreams.any((stream) => stream.producerId == transport.producerId) &&
        transport.consumer.track.kind == 'audio' &&
        transport.consumer.paused == false);

    // Pause consumer transports after a short delay
    final sleepOptions = SleepOptions(ms: 100);
    await sleep(sleepOptions);

    // Note 'serverConsumerId' is 'transport.consumer.id' not 'serverconsumerTransportId'
    for (final transport in consumerTransportsToPause) {
      transport.consumer.pause();
      transport.socket_.emitWithAck("consumer-pause", {
        'serverConsumerId': transport.consumer.id,
      }, ack: (paused) {
        // Handle pause acknowledgment
      });
    }

    // Note 'serverConsumerId' is 'transport.consumer.id' not 'serverconsumerTransportId'
    for (final transport in consumerTransportsToResume) {
      transport.socket_.emitWithAck(
          "consumer-resume", {'serverConsumerId': transport.consumer.id},
          ack: (resumed) async {
        if (resumed['resumed'] == true) {
          transport.consumer.resume();
        }
      });
    }
  } catch (error) {
    // Handle errors during the process of pausing or resuming consumer transports
    if (kDebugMode) {
      print('Error processing consumer transports: $error');
    }

    // throw new Error('Error processing consumer transports: $error');
  }
}
