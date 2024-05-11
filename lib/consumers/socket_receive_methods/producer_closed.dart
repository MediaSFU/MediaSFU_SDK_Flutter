import 'dart:async';
import 'package:flutter/foundation.dart';

/// Handles the case when a producer is closed.
///
/// This function is responsible for closing the consumer transport and consumer
/// associated with the closed producer. It also updates the list of consumer
/// transports and triggers a close and resize operation for the videos.
///
/// Parameters:
/// - `remoteProducerId`: The ID of the remote producer that was closed.
/// - `parameters`: A map of parameters containing callback functions and other data.
///
/// Throws:
/// - Any error that occurs during the process.

typedef CloseAndResize = Future<void> Function({
  required String producerId,
  required String kind,
  required Map<String, dynamic> parameters,
});

typedef UpdateConsumerTransports = void Function(
    List<dynamic> consumerTransports);

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> producerClosed({
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
}) async {
  try {
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    List<dynamic> consumerTransports = parameters['consumerTransports'];
    String? screenId = parameters['screenId'];
    UpdateConsumerTransports updateConsumerTransports =
        parameters['updateConsumerTransports'];

    //mediasfu functions
    CloseAndResize closeAndResize = parameters['closeAndResize'];

    // Handle producer closed
    dynamic producerToClose = consumerTransports.firstWhere(
      (transportData) => transportData['producerId'] == remoteProducerId,
      orElse: () => null,
    );

    if (producerToClose == null) {
      return;
    }

    // Check if the ID of the producer to close is equal to screenId
    String kind = producerToClose['consumer'].track.kind;

    if (producerToClose['producerId'] == screenId) {
      kind = 'screenshare';
    }

    try {
      await producerToClose['consumerTransport'].close();
      // ignore: empty_catches
    } catch (error) {}

    try {
      await producerToClose['consumer'].close();
      // ignore: empty_catches
    } catch (error) {}

    consumerTransports = consumerTransports
        .where(
            (transportData) => transportData['producerId'] != remoteProducerId)
        .toList();
    updateConsumerTransports(consumerTransports);

    // Close and resize the videos
    await closeAndResize(
      producerId: remoteProducerId,
      kind: kind,
      parameters: parameters,
    );
  } catch (error) {
    // Handle error if needed
    if (kDebugMode) {
      print('Error in producerClosed: $error');
    }
  }
}
