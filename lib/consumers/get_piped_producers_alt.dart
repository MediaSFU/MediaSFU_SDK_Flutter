import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'start_consuming_translation.dart'
    show
        startConsumingTranslation,
        StartConsumingTranslationOptions,
        StartConsumingTranslationParameters;
import '../types/types.dart'
    show
        SignalNewConsumerTransportParameters,
        SignalNewConsumerTransportType,
        SignalNewConsumerTransportOptions,
        TranslationMeta,
        ListenerTranslationPreferences;

/// Parameters for signaling new consumer transport.
abstract class GetPipedProducersAltParameters
    implements
        SignalNewConsumerTransportParameters,
        StartConsumingTranslationParameters {
  // Properties as abstract getters
  String get member;
  SignalNewConsumerTransportType get signalNewConsumerTransport;
  ListenerTranslationPreferences? get listenerTranslationPreferences;
  Map<String, dynamic>? get translationProducerMap;
  Map<String, dynamic>? get speakerTranslationStates;
  Set<String>? get translationSubscriptions;
  Map<String, dynamic>? get listenerTranslationOverrides;

  // Method to get updated parameters
  GetPipedProducersAltParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for retrieving piped producers.
class GetPipedProducersAltOptions {
  bool? community;
  final io.Socket nsock;
  final String islevel;
  final GetPipedProducersAltParameters parameters;

  GetPipedProducersAltOptions({
    this.community = false,
    required this.nsock,
    required this.islevel,
    required this.parameters,
  });
}

typedef GetPipedProducersAltType = Future<void> Function(
    GetPipedProducersAltOptions options);

/// Retrieves piped producers and signals new consumer transport for each retrieved producer.
///
/// Emits a `getProducersPipedAlt` event to the server using the provided [nsock] socket instance, [islevel] flag,
/// and [parameters]. The server responds with a list of producer IDs, and for each ID, this function calls
/// the `signalNewConsumerTransport` function in [parameters] to handle the new consumer transport.
///
/// - [options] (`GetPipedProducersAltOptions`): The options for the operation, including the socket instance, level,
///   and additional parameters.
///
/// Example:
/// ```dart
/// final parameters = GetPipedProducersAltParameters(
///   member: 'memberId',
///   signalNewConsumerTransport: (nsock, remoteProducerId, islevel, parameters) async {
///     // Implementation for signaling new consumer transport
///   },
/// );
///
/// await getPipedProducersAlt(
///   GetPipedProducersAltOptions(
///     community: true,
///     nsock: socketInstance,
///     islevel: '1',
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// Throws:
/// Logs and rethrows any errors encountered during the operation.
Future<void> getPipedProducersAlt(
  GetPipedProducersAltOptions options,
) async {
  try {
    final nsock = options.nsock;
    final islevel = options.islevel;
    final parameters = options.parameters;
    final member = parameters.member;
    final signalNewConsumerTransport = parameters.signalNewConsumerTransport;
    bool? community = options.community;

    String emitEvent = 'getProducersPipedAlt';
    if (community == true) {
      emitEvent = 'getProducersAlt';
    }

    // Emit request to get piped producers
    nsock.emitWithAck(
      emitEvent,
      {'islevel': islevel, 'member': member},
      ack: (dynamic producerIds) async {
        // Callback to handle the server response with producer IDs
        if (producerIds is List && producerIds.isNotEmpty) {
          for (final id in producerIds) {
            String remoteProducerId;
            TranslationMeta? translationMeta;

            if (id is String) {
              remoteProducerId = id;
            } else if (id is Map<String, dynamic>) {
              remoteProducerId = id['id'];
              if (id['translationMeta'] != null) {
                translationMeta =
                    TranslationMeta.fromMap(id['translationMeta']);
              }
            } else {
              continue;
            }

            if (translationMeta != null) {
              // Re-fetch parameters to get the latest state
              final freshParams = parameters.getUpdatedAllParams();
              final listenerTranslationPreferences =
                  freshParams.listenerTranslationPreferences;
              final speakerTranslationStates =
                  freshParams.speakerTranslationStates;
              final translationSubscriptions =
                  freshParams.translationSubscriptions;
              final listenerTranslationOverrides =
                  freshParams.listenerTranslationOverrides;

              final normalizedLang = translationMeta.language.toLowerCase();

              // 1. SPEAKER-CONTROLLED (from metadata): Speaker set output language for everyone
              final isSpeakerControlledFromMeta =
                  translationMeta.isSpeakerControlled == true;

              // 2. Fallback: Check local state - this tells us WHICH language the speaker chose
              final speakerState =
                  speakerTranslationStates?[translationMeta.speakerId];
              final speakerStateOutputLanguage =
                  speakerState?['outputLanguage'] as String?;
              final speakerStateEnabled =
                  speakerState?['enabled'] as bool? ?? false;

              // For speaker-controlled translations, we should ONLY consume the language the speaker chose
              // isSpeakerControlledFromMeta just tells us the speaker is in control mode
              // isSpeakerControlledFromState tells us this specific language matches what the speaker chose
              final isSpeakerControlledFromState = speakerStateEnabled &&
                  speakerStateOutputLanguage?.toLowerCase() == normalizedLang;

              // If speaker-controlled mode but we don't have state yet OR language doesn't match, skip
              // This prevents consuming ALL translations when speaker only chose ONE language
              final shouldSkipBecauseWrongLanguage =
                  isSpeakerControlledFromMeta &&
                      speakerStateEnabled &&
                      speakerStateOutputLanguage?.toLowerCase() !=
                          normalizedLang;

              // 3. LISTENER SUBSCRIPTION: Listener explicitly chose this language
              final subscriptionKey =
                  '${translationMeta.speakerId}_$normalizedLang';
              final isListenerSubscribed =
                  translationSubscriptions?.contains(subscriptionKey) ?? false;

              // 4. CHECK LISTENER PREFERENCES (server-synced, includes global preference)
              bool overrideBlocksConsumption = false;
              bool shouldConsumeForOverride = false;
              bool shouldConsumeForGlobal = false;

              // Check per-speaker preference first (higher priority than global)
              final perSpeakerPref = listenerTranslationPreferences
                  ?.perSpeaker[translationMeta.speakerId];
              final globalPref = listenerTranslationPreferences?.globalLanguage;

              // Also check legacy overrides for backwards compatibility
              final listenerOverride =
                  listenerTranslationOverrides?[translationMeta.speakerId];

              if (perSpeakerPref != null) {
                // Per-speaker preference takes highest priority
                if (perSpeakerPref.isEmpty) {
                  overrideBlocksConsumption = true;
                } else if (perSpeakerPref == normalizedLang) {
                  shouldConsumeForOverride = true;
                } else {
                  overrideBlocksConsumption = true;
                }
              } else if (globalPref != null && globalPref.isNotEmpty) {
                // Global preference: "I want to hear everyone in Twi"
                if (globalPref.toLowerCase() == normalizedLang) {
                  shouldConsumeForGlobal = true;
                } else {
                  overrideBlocksConsumption = true;
                }
              } else if (listenerOverride != null) {
                // Legacy override support
                final wantOriginal =
                    listenerOverride['wantOriginal'] as bool? ?? false;
                final preferredLanguage =
                    listenerOverride['preferredLanguage'] as String?;
                if (wantOriginal) {
                  overrideBlocksConsumption = true;
                } else if (preferredLanguage != null &&
                    preferredLanguage.isNotEmpty) {
                  if (preferredLanguage.toLowerCase() == normalizedLang) {
                    shouldConsumeForOverride = true;
                  } else {
                    overrideBlocksConsumption = true;
                  }
                }
              }

              // CRITICAL FIX: For speaker-controlled translations, we must verify the language matches
              // what the speaker chose. If speakerState is not yet synced, we cannot blindly trust
              // isSpeakerControlledFromMeta because multiple translation producers might exist.
              // Only consume speaker-controlled if:
              // 1. We have local speaker state confirming this exact language, OR
              // 2. This is the ONLY translation for this speaker (no state conflict possible)
              final shouldConsumeForSpeakerControlled =
                  isSpeakerControlledFromMeta &&
                      (!speakerStateEnabled ||
                          speakerStateOutputLanguage?.toLowerCase() ==
                              normalizedLang);

              // If listener has NO preference (no global, no per-speaker), they should only consume
              // speaker-controlled translations - NOT translations requested by other listeners
              final hasNoPreference = perSpeakerPref == null &&
                  globalPref == null &&
                  listenerOverride == null;
              final isListenerInitiated =
                  !isSpeakerControlledFromMeta && !isSpeakerControlledFromState;

              // Block consumption if: listener has no preference AND this is listener-initiated
              // (meaning another listener requested this, not the speaker or this listener)
              final blockBecauseNotRelevant = hasNoPreference &&
                  isListenerInitiated &&
                  !isListenerSubscribed;

              final shouldConsume = !overrideBlocksConsumption &&
                  !shouldSkipBecauseWrongLanguage &&
                  !blockBecauseNotRelevant &&
                  (shouldConsumeForOverride ||
                      shouldConsumeForGlobal ||
                      shouldConsumeForSpeakerControlled ||
                      isSpeakerControlledFromState ||
                      isListenerSubscribed);

              if (!shouldConsume) {
                continue;
              }

              await startConsumingTranslation(StartConsumingTranslationOptions(
                nsock: nsock,
                producerId: remoteProducerId,
                islevel: islevel,
                parameters: parameters,
                translationMeta: translationMeta,
              ));
              continue;
            }

            final signalOptions = SignalNewConsumerTransportOptions(
              nsock: nsock,
              remoteProducerId: remoteProducerId,
              islevel: islevel,
              parameters: parameters,
            );
            await signalNewConsumerTransport(signalOptions);
          }
        }
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error getting piped producers: ${error.toString()}');
    }
    rethrow;
  }
}
