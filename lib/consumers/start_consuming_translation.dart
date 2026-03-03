import 'package:flutter/foundation.dart' show debugPrint;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        SignalNewConsumerTransportParameters,
        SignalNewConsumerTransportOptions,
        TranslationMeta,
        TransportType;
import 'signal_new_consumer_transport.dart' show signalNewConsumerTransport;

abstract class StartConsumingTranslationParameters
    implements SignalNewConsumerTransportParameters {
  Map<String, dynamic>? get translationProducerMap;
  Set<String>? get activeTranslationProducerIds;
  List<TransportType> get consumerTransports;
  void Function(List<TransportType>) get updateConsumerTransports;
  List<String> get consumingTransports;
  void Function(List<String>) get updateConsumingTransports;
}

class StartConsumingTranslationOptions {
  final io.Socket nsock;
  final String producerId;
  final String islevel;
  final StartConsumingTranslationParameters parameters;
  final TranslationMeta translationMeta;

  StartConsumingTranslationOptions({
    required this.nsock,
    required this.producerId,
    required this.islevel,
    required this.parameters,
    required this.translationMeta,
  });
}

Future<void> startConsumingTranslation(
    StartConsumingTranslationOptions options) async {
  final nsock = options.nsock;
  final producerId = options.producerId;
  final islevel = options.islevel;
  final parameters = options.parameters;
  final translationMeta = options.translationMeta;

  final activeTranslationProducerIds = parameters.activeTranslationProducerIds;
  final consumerTransports = parameters.consumerTransports;
  final updateConsumerTransports = parameters.updateConsumerTransports;
  final consumingTransports = parameters.consumingTransports;
  final updateConsumingTransports = parameters.updateConsumingTransports;

  // STEP 1: Close any existing translation consumers for this speaker (different language)
  final originalProducerId = translationMeta.originalProducerId;
  final translationProducerMap = parameters.translationProducerMap;

  if (translationProducerMap != null) {
    final producersToRemove = <String>[];

    // Iterate over the map to find conflicting translations
    for (final entry in translationProducerMap.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is TranslationMeta) {
        if (value.originalProducerId == originalProducerId &&
            value.language != translationMeta.language) {
          // Found a translation for the same source but different language
          final existingTranslationProducerId = key;

          // Check if we are consuming this
          final transportIndex = consumerTransports.indexWhere(
            (t) => t.producerId == existingTranslationProducerId,
          );

          if (transportIndex != -1) {
            final transport = consumerTransports[transportIndex];

            try {
              // Close on server
              transport.socket_.emit('consumer-close', {
                'serverConsumerId': transport.serverConsumerTransportId,
              });

              // Close locally
              transport.consumer.close();
            } catch (e) {
              debugPrint('[Translation] Error closing existing consumer: $e');
            }

            // Remove from tracking
            activeTranslationProducerIds?.remove(existingTranslationProducerId);

            // Remove from consumer transports
            final updatedTransports =
                List<TransportType>.from(consumerTransports);
            updatedTransports.removeAt(transportIndex);
            updateConsumerTransports(updatedTransports);

            // Remove from consuming transports
            final updatedConsuming = List<String>.from(consumingTransports);
            updatedConsuming.remove(existingTranslationProducerId);
            updateConsumingTransports(updatedConsuming);

            producersToRemove.add(existingTranslationProducerId);
          }
        }
      }
    }

    // Remove from map
    for (final pid in producersToRemove) {
      translationProducerMap.remove(pid);
    }
  }

  // STEP 2: Track this producer as translation
  activeTranslationProducerIds?.add(producerId);

  // STEP 3: Update translationProducerMap with new producer
  if (translationProducerMap != null) {
    translationProducerMap[producerId] = translationMeta;
  }

  // STEP 4: Signal new consumer transport
  final optionsSignal = SignalNewConsumerTransportOptions(
    remoteProducerId: producerId,
    islevel: islevel,
    nsock: nsock,
    parameters: parameters,
  );

  await signalNewConsumerTransport(optionsSignal);

  // STEP 5: Pause original producer (locally and on server)
  final freshParams = parameters.getUpdatedAllParams();
  final freshConsumerTransports = freshParams.consumerTransports;
  final transportIndex = freshConsumerTransports.indexWhere(
    (t) => t.producerId == originalProducerId,
  );

  if (transportIndex != -1) {
    final transport = freshConsumerTransports[transportIndex];
    try {
      transport.consumer.pause();

      // Also notify the server to stop sending original audio data
      // Use the transport's own socket (it may be a different pipe socket)
      // and the consumer's actual ID (not serverConsumerTransportId which is the transport ID)
      transport.socket_.emit('consumer-pause', {
        'serverConsumerId': transport.consumer.id,
      });
    } catch (e) {
      debugPrint('[Translation] Error pausing original producer: $e');
    }
  }
}
