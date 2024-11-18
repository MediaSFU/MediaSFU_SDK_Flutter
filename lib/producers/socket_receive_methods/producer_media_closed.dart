import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../types/types.dart'
    show
        CloseAndResizeParameters,
        CloseAndResizeType,
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        ReorderStreamsParameters,
        ReorderStreamsType,
        TransportType,
        CloseAndResizeOptions,
        PrepopulateUserMediaOptions,
        ReorderStreamsOptions;

/// Abstract class defining the parameters required for closing media of a producer.
abstract class ProducerMediaClosedParameters
    implements
        CloseAndResizeParameters,
        PrepopulateUserMediaParameters,
        ReorderStreamsParameters {
  // Core properties as abstract getters
  List<TransportType> get consumerTransports;
  String get hostLabel;
  bool get shared;

  // Update functions as abstract getters returning functions
  void Function(List<TransportType>) get updateConsumerTransports;
  void Function(bool) get updateShared;
  void Function(bool) get updateShareScreenStarted;
  void Function(String) get updateScreenId;
  void Function(bool) get updateShareEnded;

  // Mediasfu functions as abstract getters
  CloseAndResizeType get closeAndResize;
  PrepopulateUserMediaType get prepopulateUserMedia;
  ReorderStreamsType get reorderStreams;

  // Method to retrieve updated parameters as an abstract getter
  ProducerMediaClosedParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Class representing options for closing a producer's media.
class ProducerMediaClosedOptions {
  final String producerId;
  final String kind; // 'video' | 'screen' | 'audio' | 'screenshare'
  final ProducerMediaClosedParameters parameters;

  ProducerMediaClosedOptions({
    required this.producerId,
    required this.kind,
    required this.parameters,
  });
}

// Typedef for the closure function signature
typedef ProducerMediaClosedType = Future<void> Function(
    ProducerMediaClosedOptions options);

/// Handles the closure of a media producer's stream or screenshare.
///
/// This function identifies the transport associated with the given `producerId`,
/// closes it, and updates shared states based on the `kind` of media.
///
/// If the `producerId` is found in the `consumerTransports` list, the associated transport
/// and consumer are closed, and the `consumerTransports` list is updated accordingly. If
/// the `kind` is `screenshare` or `screen`, and the media is shared, the share settings are reset.
///
/// Throws an error if any transport or consumer closure fails.
///
/// Example usage:
/// ```dart
/// final parameters = ProducerMediaClosedOptions(
///   producerId: 'abc123',
///   kind: 'screenshare',
///   parameters: myParameters,
/// );
///
/// await producerMediaClosed(
///   producerId: parameters.producerId,
///   kind: parameters.kind,
///   parameters: parameters.parameters,
/// );
/// ```
///
/// - [producerId] (`String`): The ID of the producer to close.
/// - [kind] (`String`): Type of media (e.g., 'video', 'screenshare').
/// - [parameters] (`ProducerMediaClosedParameters`): Configuration and dependencies for handling the closure.

Future<void> producerMediaClosed(
  ProducerMediaClosedOptions options,
) async {
  final producerId = options.producerId;
  final kind = options.kind;
  final parameters = options.parameters;

  // Get updated parameters
  final updatedParameters = parameters.getUpdatedAllParams();

  final consumerTransports = updatedParameters.consumerTransports;
  final updateConsumerTransports = updatedParameters.updateConsumerTransports;
  final hostLabel = updatedParameters.hostLabel;
  final shared = updatedParameters.shared;
  final updateShared = updatedParameters.updateShared;
  final updateShareScreenStarted = updatedParameters.updateShareScreenStarted;
  final updateScreenId = updatedParameters.updateScreenId;
  final updateShareEnded = updatedParameters.updateShareEnded;
  final closeAndResize = updatedParameters.closeAndResize;
  final prepopulateUserMedia = updatedParameters.prepopulateUserMedia;
  final reorderStreams = updatedParameters.reorderStreams;

  // Find the transport for the producer to close
  TransportType? producerToClose = consumerTransports.firstWhereOrNull(
      (transportData) => transportData.producerId == producerId);

  if (producerToClose == null) {
    return;
  }

  if (producerToClose.producerId.isNotEmpty) {
    try {
      await producerToClose['consumerTransport'].close();
    } catch (error) {
      if (kDebugMode) {
        print('Error closing consumer transport: $error');
      }
    }

    try {
      producerToClose.consumer.close();
    } catch (error) {
      if (kDebugMode) {
        print('Error closing consumer: $error');
      }
    }

    final updatedTransports = consumerTransports
        .where(
          (transportData) => transportData.producerId != producerId,
        )
        .toList();
    updateConsumerTransports(updatedTransports);

    final optionsClose = CloseAndResizeOptions(
      producerId: producerId,
      kind: kind,
      parameters: updatedParameters,
    );
    await closeAndResize(
      optionsClose,
    );
  } else if (kind == 'screenshare' || kind == 'screen') {
    if (shared) {
      updateShared(false);
    } else {
      updateShareScreenStarted(false);
      updateScreenId('');
    }
    updateShareEnded(true);
    final optionsPrepopulate = PrepopulateUserMediaOptions(
      name: hostLabel,
      parameters: updatedParameters,
    );
    await prepopulateUserMedia(
      optionsPrepopulate,
    );
    final optionsReorder = ReorderStreamsOptions(
      add: false,
      screenChanged: true,
      parameters: updatedParameters,
    );
    await reorderStreams(
      optionsReorder,
    );
  }
}
