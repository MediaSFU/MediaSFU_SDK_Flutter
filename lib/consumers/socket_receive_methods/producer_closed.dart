import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../../types/types.dart'
    show
        TransportType,
        CloseAndResizeParameters,
        CloseAndResizeType,
        CloseAndResizeOptions;

/// Abstract class representing the parameters needed for the [producerClosed] function.
///
/// Contains consumer transports, screen ID, and functions for updating consumer transports,
/// closing, and resizing.
abstract class ProducerClosedParameters extends CloseAndResizeParameters {
  List<TransportType> get consumerTransports;
  String get screenId;
  void Function(List<TransportType> transports) get updateConsumerTransports;

  // Mediasfu functions
  CloseAndResizeType get closeAndResize;
  ProducerClosedParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the [producerClosed] function.
///
/// Holds the remote producer ID and the parameters required to handle the closure.
class ProducerClosedOptions {
  final String remoteProducerId;
  final ProducerClosedParameters parameters;

  ProducerClosedOptions({
    required this.remoteProducerId,
    required this.parameters,
  });
}

/// Type definition for the `producerClosed` function.
///
/// Represents a function that takes in [ProducerClosedOptions] and returns `Future<void>`.
typedef ProducerClosedType = Future<void> Function(
    ProducerClosedOptions options);

/// Handles the closure of a producer identified by its remote producer ID.
/// This function updates the consumer transports and triggers close-and-resize operations.
///
/// ### Parameters:
/// - `options` (ProducerClosedOptions): The options containing the producer ID and necessary parameters.
/// - `remoteProducerId` (String): The ID of the remote producer to be closed.
/// - `parameters` (ProducerClosedParameters): Additional parameters including consumer transports and close-and-resize logic.
///
/// ### Example:
/// ```dart
/// final parameters = MockProducerClosedParameters(); // Your implementation of ProducerClosedParameters
/// final options = ProducerClosedOptions(remoteProducerId: 'producerId', parameters: parameters);
///
/// producerClosed(options).then((_) {
///   print('Producer closed successfully');
/// }).catchError((error) {
///   print('Error closing producer: $error');
/// });
/// ```
Future<void> producerClosed(ProducerClosedOptions options) async {
  final remoteProducerId = options.remoteProducerId;
  var parameters = options.parameters.getUpdatedAllParams();

  List<TransportType> consumerTransports = parameters.consumerTransports;
  final String screenId = parameters.screenId;
  final updateConsumerTransports = parameters.updateConsumerTransports;
  final closeAndResize = parameters.closeAndResize;

  // Find the producer to close based on the provided ID
  TransportType? producerToClose = consumerTransports.firstWhereOrNull(
      (transportData) => transportData.producerId == remoteProducerId);

  if (producerToClose == null) {
    return;
  }

  if (producerToClose.producerId.isEmpty) {
    return;
  }

  // Check if the producer ID matches the screen ID and determine the kind
  String kind = producerToClose.consumer.track.kind!;
  if (producerToClose.producerId == screenId) {
    kind = 'screenshare';
  }

  try {
    // Close the consumer transport if possible
    await producerToClose.consumerTransport.close();
  } catch (error) {
    if (kDebugMode) {
      //print('Error closing consumer transport: $error');
    }
  }

  try {
    // Close the consumer
    await producerToClose.consumer.close();
  } catch (error) {
    if (kDebugMode) {
      // print('Error closing consumer: $error');
    }
  }

  // Remove the closed producer from the list
  consumerTransports = consumerTransports
      .where((transportData) => transportData.producerId != remoteProducerId)
      .toList();
  updateConsumerTransports(consumerTransports);

  // Close and resize video outputs as needed
  final optionsCloseAndResize = CloseAndResizeOptions(
    producerId: remoteProducerId,
    kind: kind,
    parameters: parameters,
  );
  await closeAndResize(
    optionsCloseAndResize,
  );
}
