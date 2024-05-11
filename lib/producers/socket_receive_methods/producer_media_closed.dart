// ignore_for_file: empty_catches

import 'dart:async';

/// Closes the video or screenshare of a participant.
///
/// [producerId] is the ID of the producer.
/// [kind] is the kind of media (video, screenshare).
/// [parameters] is a map of parameters including:
///   - [getUpdatedAllParams]: A function that returns an updated map of parameters.
///   - [consumerTransports]: A list of consumer transports.
///   - [updateConsumerTransports]: A function to update the consumer transports.
///   - [hostLabel]: The label of the host.
///   - [shared]: A boolean indicating if the media is shared.
///   - [updateShared]: A function to update the shared status.
///   - [updateShareScreenStarted]: A function to update the screen sharing status.
///   - [updateScreenId]: A function to update the screen ID.
///   - [updateShareEnded]: A function to update the share ended status.
///   - [closeAndResize]: A function to close and resize the media.
///   - [prepopulateUserMedia]: A function to prepopulate user media.
///   - [reorderStreams]: A function to reorder streams.
///
/// This function updates the UI to optimize interest levels and closes the video or screenshare.
/// If the producer to close is found in the consumer transports, it closes the consumer transport and consumer,
/// removes the producer from the consumer transports, and calls the [closeAndResize] function.
/// If the kind is 'screenshare' or 'screen', it updates the shared status, screen sharing status, screen ID,
/// share ended status, prepopulates user media, and calls the [reorderStreams] function.

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef CloseAndResize = Future<void> Function({
  required String producerId,
  required String kind,
  required Map<String, dynamic> parameters,
});

typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

Future<void> producerMediaClosed({
  required String producerId,
  required String kind,
  required Map<String, dynamic> parameters,
}) async {
  // Update to close the video, screenshare of a participant
  // producerId is the id of the producer
  // kind is the kind of media (video, screenshare)
  // never emitted for audio

  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  List<dynamic>? consumerTransports = parameters['consumerTransports'];
  Function? updateConsumerTransports = parameters['updateConsumerTransports'];
  String hostLabel = parameters['hostLabel'];
  bool shared = parameters['shared'];
  Function(bool)? updateShared = parameters['updateShared'];
  Function(bool)? updateShareScreenStarted =
      parameters['updateShareScreenStarted'];
  Function(String)? updateScreenId = parameters['updateScreenId'];
  Function(bool)? updateShareEnded = parameters['updateShareEnded'];

  // mediasfu functions
  CloseAndResize closeAndResize = parameters['closeAndResize'];
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];
  ReorderStreams reorderStreams = parameters['reorderStreams'];

  if (updateConsumerTransports == null ||
      consumerTransports == null ||
      updateShared == null ||
      updateShareScreenStarted == null ||
      updateScreenId == null ||
      updateShareEnded == null) {
    return; // Handle missing or null parameters
  }

  // Operations to update UI to optimize interest levels and close the video or screenshare
  var producerToClose = consumerTransports.firstWhere(
    (transportData) => transportData['producerId'] == producerId,
    orElse: () => null,
  );

  if (producerToClose != null) {
    try {
      await producerToClose['consumerTransport'].close();
    } catch (error) {}

    try {
      await producerToClose['consumer'].close();
    } catch (error) {}

    consumerTransports = consumerTransports
        .where((transportData) => transportData['producerId'] != producerId)
        .toList();
    updateConsumerTransports(consumerTransports);

    await closeAndResize(
      producerId: producerId,
      kind: kind,
      parameters: parameters,
    );
  } else {
    if (kind == 'screenshare' || kind == 'screen') {
      if (shared) {
        await updateShared(false);
      } else {
        await updateShareScreenStarted(false);
        await updateScreenId('');
      }
      await updateShareEnded(true);
      prepopulateUserMedia(name: hostLabel, parameters: parameters);
      await reorderStreams(
          add: false, screenChanged: true, parameters: parameters);
    }
  }
}
