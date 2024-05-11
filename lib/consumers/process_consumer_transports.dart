import 'dart:async';
import 'package:flutter/foundation.dart';

/// Processes consumer transports by pausing and resuming consumer streams based on certain conditions.
///
/// The [consumerTransports] parameter is a list of dynamic objects representing the consumer transports.
/// The [lStreams_] parameter is a list of dynamic objects representing the lStreams.
/// The [parameters] parameter is a map of string keys and dynamic values representing the parameters.
///
/// The [processConsumerTransports] function performs the following steps:
/// 1. Retrieves the [getUpdatedAllParams] function from the [parameters] map and assigns it to the [getUpdatedAllParams] variable.
/// 2. Calls the [getUpdatedAllParams] function to update the [parameters] map.
/// 3. Retrieves specific values from the [parameters] map and assigns them to variables.
/// 4. Defines a [sleep] function using the [parameters] map.
/// 5. Defines a helper function [isValidProducerId] to check if a producerId is valid in the given stream arrays.
/// 6. Filters the [consumerTransports] list to get paused consumer transports that are not audio.
/// 7. Filters the [consumerTransports] list to get unpaused consumer transports that are not audio.
/// 8. Pauses consumer transports after a short delay using the [sleep] function.
/// 9. Emits consumer.pause() for each filtered transport (not audio).
/// 10. Emits consumer.resume() for each filtered transport (not audio) if the corresponding server response indicates successful resumption.
///
/// Throws an error if any errors occur during the process of pausing or resuming consumer transports.

typedef Sleep = Future<void> Function(int milliseconds);
typedef GetUpdatedAllParamsFunction = Map<String, dynamic> Function();

Future<void> processConsumerTransports(
    {required List<dynamic> consumerTransports,
    required List<dynamic> lStreams_,
    required Map<String, dynamic> parameters}) async {
  try {
    GetUpdatedAllParamsFunction getUpdatedAllParams =
        parameters['getUpdatedAllParams'];

    parameters = getUpdatedAllParams();

    var remoteScreenStream = parameters['remoteScreenStream'];
    var oldAllStreams = parameters['oldAllStreams'];
    var newLimitedStreams = parameters['newLimitedStreams'];

    //mediasfu functions
    Sleep sleep = parameters['sleep'];

    // Function to check if the producerId is valid in the given stream arrays
    bool isValidProducerId(String producerId, List<dynamic> streamArrays) {
      return producerId.isNotEmpty &&
          producerId != "" &&
          streamArrays.any((streamArray) =>
              streamArray.length > 0 &&
              streamArray.any((stream) => stream['producerId'] == producerId));
    }

    // // Get paused consumer transports that are audio
    // var consumerTransportsToResumeAudio = consumerTransports.where(
    //     (transport) =>
    //         isValidProducerId(transport['producerId'], [
    //           lStreams_,
    //           remoteScreenStream,
    //           oldAllStreams,
    //           newLimitedStreams
    //         ]) &&
    //         transport['consumer'].paused== true &&
    //         transport['consumer']track.kind == "audio");

    // // Get unpaused consumer transports that are audio
    // var consumerTransportsToPauseAudio = consumerTransports.where((transport) =>
    //     transport['producerId'] != null &&
    //     transport['producerId'] != "" &&
    //     !lStreams_
    //         .any((stream) => stream['producerId'] == transport['producerId']) &&
    //     transport['consumer'] != null &&
    //     transport['consumer'].track.kind != null &&
    //     transport['consumer'].paused!= true &&
    //     transport['consumer'].track.kind == "audio" &&
    //     !remoteScreenStream
    //         .any((stream) => stream['producerId'] == transport['producerId']) &&
    //     !oldAllStreams
    //         .any((stream) => stream['producerId'] == transport['producerId']) &&
    //     !newLimitedStreams
    //         .any((stream) => stream['producerId'] == transport['producerId']));

    // // Pause consumer transports after a short delay
    // await sleep(100);

    // // Emit consumer.pause() for each filtered transport (audio)
    // for (var transport in consumerTransportsToPauseAudio) {
    //   await transport['consumer'].pause();
    //   await transport['socket_'].emitWithAck("consumer-pause", {
    //     "serverConsumerId": transport['serverConsumerTransportId']
    //   }, ack:(paused) async {
    //     // Handle the response if needed
    //   });
    // }

    // Get paused consumer transports that are not audio
    var consumerTransportsToResume = consumerTransports.where((transport) =>
        isValidProducerId(transport['producerId'], [
          lStreams_,
          remoteScreenStream,
          oldAllStreams,
          newLimitedStreams
        ]) &&
        transport['consumer'] != null &&
        transport['consumer'].paused == true &&
        transport['consumer'].track.kind != "audio");

    // Get unpaused consumer transports that are not audio
    var consumerTransportsToPause = consumerTransports.where((transport) =>
        transport['producerId'] != null &&
        transport['producerId'] != "" &&
        !lStreams_
            .any((stream) => stream['producerId'] == transport['producerId']) &&
        transport['consumer'] != null &&
        transport['consumer'].track.kind != null &&
        transport['consumer'].paused != true &&
        transport['consumer'].track.kind != "audio" &&
        !remoteScreenStream
            .any((stream) => stream['producerId'] == transport['producerId']) &&
        !oldAllStreams
            .any((stream) => stream['producerId'] == transport['producerId']) &&
        !newLimitedStreams
            .any((stream) => stream['producerId'] == transport['producerId']));

    // Pause consumer transports after a short delay

    await sleep(100);

    // Emit consumer.pause() for each filtered transport (not audio)
    for (var transport in consumerTransportsToPause) {
      await transport['consumer'].pause();
      await transport['socket_'].emitWithAck("consumer-pause", {
        "serverConsumerId": transport['serverConsumerTransportId']
      }, ack: (paused) async {
        // Handle the response if needed
      });
    }

    // Emit consumer.resume() for each filtered transport (not audio)
    for (var transport in consumerTransportsToResume) {
      await transport['socket_'].emitWithAck("consumer-resume", {
        "serverConsumerId": transport['serverConsumerTransportId']
      }, ack: (resumed) async {
        if (resumed['resumed'] == true) {
          await transport['consumer'].resume();
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
