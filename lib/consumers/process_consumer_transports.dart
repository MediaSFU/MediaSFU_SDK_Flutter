import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show Stream, TransportType, SleepType, SleepOptions;

abstract class ProcessConsumerTransportsParameters {
  // Properties as abstract getters
  List<Stream> get remoteScreenStream;
  List<Stream> get oldAllStreams;
  List<Stream> get newLimitedStreams;

  // Mediasfu function as an abstract getter
  SleepType get sleep;

  // Method to retrieve updated parameters
  ProcessConsumerTransportsParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ProcessConsumerTransportsOptions {
  final List<TransportType> consumerTransports;
  final List<Stream> lStreams_;
  final ProcessConsumerTransportsParameters parameters;

  ProcessConsumerTransportsOptions({
    required this.consumerTransports,
    required this.lStreams_,
    required this.parameters,
  });
}

typedef ProcessConsumerTransportsType = Future<void> Function(
    ProcessConsumerTransportsOptions options);

/// Processes consumer transports to pause or resume video streams based on provided stream lists.
///
/// This function iterates over consumer transports, checking if each transport's `producerId`
/// matches any in the provided lists of streams (`lStreams_`, `remoteScreenStream`, `oldAllStreams`,
/// `newLimitedStreams`). If a transport is paused and its producerId matches a stream in the lists,
/// it resumes the transport. If a transport is unpaused and its producerId does not match any stream
/// in the lists, it pauses the transport after a brief delay.
///
/// Parameters:
/// - [options] (`ProcessConsumerTransportsOptions`): Contains:
///   - [consumerTransports]: List of transports to process.
///   - [lStreams_]: List of current streams to compare producerIds against.
///   - [parameters]: Includes the `sleep` function for a delay and lists of old and new streams.
///
/// Example:
/// ```dart
/// final parameters = ProcessConsumerTransportsParameters(
///   remoteScreenStream: [screenStream1],
///   oldAllStreams: [oldStream1, oldStream2],
///   newLimitedStreams: [limitedStream1],
///   sleep: (options) async => await Future.delayed(Duration(milliseconds: options.ms)),
///   getUpdatedAllParams: () => updatedParams, // Function to retrieve updated parameters if needed
/// );
///
/// await processConsumerTransports(
///   ProcessConsumerTransportsOptions(
///     consumerTransports: [transport1, transport2],
///     lStreams_: [stream1, stream2],
///     parameters: parameters,
///   ),
/// );
/// ```

Future<void> processConsumerTransports(
    ProcessConsumerTransportsOptions options) async {
  // Retrieve and destructure updated parameters
  final ProcessConsumerTransportsParameters parameters =
      options.parameters.getUpdatedAllParams();
  final SleepType sleep = parameters.sleep;

  final List<TransportType> consumerTransports = options.consumerTransports;
  final List<Stream> lStreams_ = options.lStreams_;
  final List<Stream> remoteScreenStream = parameters.remoteScreenStream;
  final List<Stream> oldAllStreams = parameters.oldAllStreams;
  final List<Stream> newLimitedStreams = parameters.newLimitedStreams;

  try {
    // Helper function to check if producerId exists in any provided stream array
    bool isValidProducerId(String producerId, List<List<Stream>> streamArrays) {
      return producerId.isNotEmpty &&
          streamArrays.any((streamArray) =>
              streamArray.any((stream) => stream.producerId == producerId));
    }

    // Get paused consumer transports that are not audio
    final consumerTransportsToResume = consumerTransports.where((transport) =>
        isValidProducerId(transport.producerId, [
          lStreams_,
          remoteScreenStream,
          oldAllStreams,
          newLimitedStreams
        ]) &&
        transport.consumer.paused &&
        transport.consumer.track.kind != 'audio');

    // Get unpaused consumer transports that are not audio and not in lStreams
    final consumerTransportsToPause = consumerTransports.where((transport) =>
        transport.producerId.isNotEmpty &&
        !lStreams_.any((stream) => stream.producerId == transport.producerId) &&
        transport.consumer.track.kind != 'audio' &&
        !remoteScreenStream
            .any((stream) => stream.producerId == transport.producerId) &&
        !oldAllStreams
            .any((stream) => stream.producerId == transport.producerId) &&
        !newLimitedStreams
            .any((stream) => stream.producerId == transport.producerId) &&
        !transport.consumer.paused);

    // Pause consumer transports after a short delay
    final sleepOptions = SleepOptions(ms: 100);
    await sleep(sleepOptions);

    // Emit consumer.pause() for each filtered transport (not audio)
    // Note 'serverConsumerId' is 'transport.consumer.id' not 'serverconsumerTransportId'
    for (final transport in consumerTransportsToPause) {
      transport.consumer.pause();
      transport.socket_.emitWithAck(
          "consumer-pause", {'serverConsumerId': transport.consumer.id},
          ack: (_) {});
    }

    // Emit consumer.resume() for each filtered transport (not audio)
    // Note 'serverConsumerId' is 'transport.consumer.id' not 'serverconsumerTransportId'
    for (final transport in consumerTransportsToResume) {
      transport.socket_.emitWithAck("consumer-resume", {
        'serverConsumerId': transport.consumer.id,
      }, ack: (resumed) async {
        if (resumed['resumed'] == true) {
          transport.consumer.resume();
        }
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in processConsumerTransports: $error');
    }
  }
}
