import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../consumers/signal_new_consumer_transport.dart'
    show signalNewConsumerTransport;
import '../../consumers/start_consuming_translation.dart'
    show
        startConsumingTranslation,
        StartConsumingTranslationOptions,
        StartConsumingTranslationParameters;
import '../../types/types.dart'
    show
        ShowAlert,
        SignalNewConsumerTransportOptions,
        ReorderStreamsParameters,
        SignalNewConsumerTransportParameters,
        ConnectRecvTransportParameters,
        ConnectRecvTransportType,
        ReorderStreamsType,
        TranslationMeta,
        ListenerTranslationPreferences;

/// Interface for [NewPipeProducerParameters], extending other parameters.
abstract class NewPipeProducerParameters
    implements
        ReorderStreamsParameters,
        SignalNewConsumerTransportParameters,
        ConnectRecvTransportParameters,
        StartConsumingTranslationParameters {
  bool get firstRound;
  bool get shareScreenStarted;
  bool get shared;
  bool get landScaped;
  bool get isWideScreen;
  Device? get device;
  List<String> get consumingTransports;
  bool get lockScreen;

  ShowAlert? get showAlert;

  // Translation params
  ListenerTranslationPreferences? get listenerTranslationPreferences;
  Map<String, dynamic>? get listenerTranslationOverrides;
  Map<String, dynamic>? get translationProducerMap;
  Map<String, dynamic>? get speakerTranslationStates;
  Set<String>? get translationSubscriptions;

  void Function(bool) get updateFirstRound;
  void Function(bool) get updateLandScaped;
  void Function(List<String>) get updateConsumingTransports;

  // Properties as getters
  ConnectRecvTransportType get connectRecvTransport;
  ReorderStreamsType get reorderStreams;

  NewPipeProducerParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the [newPipeProducer] function.
class NewPipeProducerOptions {
  final String producerId;
  final String islevel;
  final io.Socket nsock;
  final NewPipeProducerParameters parameters;
  final TranslationMeta? translationMeta;

  NewPipeProducerOptions({
    required this.producerId,
    required this.islevel,
    required this.nsock,
    required this.parameters,
    this.translationMeta,
  });
}

typedef NewPipeProducerType = Future<void> Function(
    NewPipeProducerOptions options);

/// Initiates a new pipe producer by signaling a new consumer transport and updating display settings as needed.
///
/// This function performs the following steps:
/// 1. Signals the creation of a new consumer transport for the specified `producerId`.
/// 2. Updates the `firstRound` and `landScaped` display parameters based on sharing mode and device orientation.
/// 3. Optionally, triggers an alert to prompt the user to rotate their device for optimal viewing if screen sharing is active and the device is not in landscape mode.
///
/// ### Parameters:
///
/// - `options` (`NewPipeProducerOptions`): Contains the required data for handling the new pipe producer:
///   - `producerId` (`String`): The ID of the producer to be consumed.
///   - `islevel` (`String`): The level status of the participant.
///   - `nsock` (`io.Socket`): The socket instance for managing real-time communication.
///   - `parameters` (`NewPipeProducerParameters`): Additional parameters to set up the producer:
///       - `firstRound` (`bool`): Flag indicating if this is the first operation round.
///       - `shareScreenStarted` (`bool`): Whether screen sharing has started.
///       - `shared` (`bool`): Whether sharing is currently active.
///       - `landScaped` (`bool`): Indicates if the device is in landscape orientation.
///       - `isWideScreen` (`bool`): Indicates if the device has a widescreen layout.
///       - `showAlert` (`ShowAlert?`): An optional callback to display alerts to the user.
///       - `updateFirstRound` (`Function`): Callback to update `firstRound` status.
///       - `updateLandScaped` (`Function`): Callback to update landscape orientation status.
///
/// ### Returns:
///
/// A `Future<void>` that completes once the consumer transport setup and parameter updates are finished.
///
/// ### Throws:
///
/// Throws an error if signaling the new consumer transport fails.
///
/// ### Example:
///
/// ```dart
/// import 'package:socket_io_client/socket_io_client.dart' as io;
/// import 'new_pipe_producer.dart';
/// import 'new_pipe_producer.options.dart';
///
/// final socket = io.io("http://localhost:3000", <String, dynamic>{
///   "transports": ["websocket"],
/// });
///
/// final parameters = NewPipeProducerParametersMock(
///   firstRound: true,
///   shareScreenStarted: true,
///   shared: false,
///   landScaped: false,
///   isWideScreen: false,
///   showAlert: (alert) => print(alert['message']),
///   updateFirstRound: (firstRound) => print("First Round Updated: $firstRound"),
///   updateLandScaped: (landScaped) => print("Landscape Updated: $landScaped"),
/// );
///
/// final options = NewPipeProducerOptions(
///   producerId: 'producer-123',
///   islevel: '2',
///   nsock: socket,
///   parameters: parameters,
/// );
///
/// try {
///   await newPipeProducer(options);
///   print("New pipe producer created successfully");
/// } catch (error) {
///   print("Error creating new pipe producer: $error");
/// }
/// ```

Future<void> newPipeProducer(NewPipeProducerOptions options) async {
  final producerId = options.producerId;
  final islevel = options.islevel;
  final nsock = options.nsock;
  final parameters = options.parameters;
  final translationMeta = options.translationMeta;

  if (translationMeta != null) {
    final listenerTranslationPreferences =
        parameters.listenerTranslationPreferences;
    final speakerTranslationStates = parameters.speakerTranslationStates;
    final translationSubscriptions = parameters.translationSubscriptions;
    final listenerTranslationOverrides =
        parameters.listenerTranslationOverrides;

    final normalizedLang = translationMeta.language.toLowerCase();

    // 1. SPEAKER-CONTROLLED (from metadata): Speaker set output language for everyone
    final isSpeakerControlledFromMeta =
        translationMeta.isSpeakerControlled == true;

    // 2. Fallback: Check local state - this tells us WHICH language the speaker chose
    final speakerState = speakerTranslationStates?[translationMeta.speakerId];
    final speakerStateOutputLanguage =
        speakerState?['outputLanguage'] as String?;
    final speakerStateEnabled = speakerState?['enabled'] as bool? ?? false;

    // For speaker-controlled translations, we should ONLY consume the language the speaker chose
    // isSpeakerControlledFromMeta just tells us the speaker is in control mode
    // isSpeakerControlledFromState tells us this specific language matches what the speaker chose
    final isSpeakerControlledFromState = speakerStateEnabled &&
        speakerStateOutputLanguage?.toLowerCase() == normalizedLang;

    // If speaker-controlled mode but we don't have state yet OR language doesn't match, skip
    // This prevents consuming ALL translations when speaker only chose ONE language
    final shouldSkipBecauseWrongLanguage = isSpeakerControlledFromMeta &&
        speakerStateEnabled &&
        speakerStateOutputLanguage?.toLowerCase() != normalizedLang;

    // 3. LISTENER SUBSCRIPTION: Listener explicitly chose this language
    final subscriptionKey = '${translationMeta.speakerId}_$normalizedLang';
    final isListenerSubscribed =
        translationSubscriptions?.contains(subscriptionKey) ?? false;

    // 4. CHECK LISTENER PREFERENCES (server-synced, includes global preference)
    bool overrideBlocksConsumption = false;
    bool shouldConsumeForOverride = false;
    bool shouldConsumeForGlobal = false;

    // Check per-speaker preference first (higher priority than global)
    final perSpeakerPref =
        listenerTranslationPreferences?.perSpeaker[translationMeta.speakerId];
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
      final wantOriginal = listenerOverride['wantOriginal'] as bool? ?? false;
      final preferredLanguage =
          listenerOverride['preferredLanguage'] as String?;
      if (wantOriginal) {
        overrideBlocksConsumption = true;
      } else if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
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
    final shouldConsumeForSpeakerControlled = isSpeakerControlledFromMeta &&
        (!speakerStateEnabled ||
            speakerStateOutputLanguage?.toLowerCase() == normalizedLang);

    // If listener has NO preference (no global, no per-speaker), they should only consume
    // speaker-controlled translations - NOT translations requested by other listeners
    final hasNoPreference = perSpeakerPref == null &&
        globalPref == null &&
        listenerOverride == null;
    final isListenerInitiated =
        !isSpeakerControlledFromMeta && !isSpeakerControlledFromState;

    // Block consumption if: listener has no preference AND this is listener-initiated
    // (meaning another listener requested this, not the speaker or this listener)
    final blockBecauseNotRelevant =
        hasNoPreference && isListenerInitiated && !isListenerSubscribed;

    final shouldConsume = !overrideBlocksConsumption &&
        !shouldSkipBecauseWrongLanguage &&
        !blockBecauseNotRelevant &&
        (shouldConsumeForOverride ||
            shouldConsumeForGlobal ||
            shouldConsumeForSpeakerControlled ||
            isSpeakerControlledFromState ||
            isListenerSubscribed);

    if (shouldConsume) {
      await startConsumingTranslation(StartConsumingTranslationOptions(
        nsock: nsock,
        producerId: producerId,
        islevel: islevel,
        parameters: parameters,
        translationMeta: translationMeta,
      ));
    }
    return;
  }

  bool firstRound = parameters.firstRound;
  final bool shareScreenStarted = parameters.shareScreenStarted;
  final bool shared = parameters.shared;
  bool landScaped = parameters.landScaped;
  final bool isWideScreen = parameters.isWideScreen;
  final ShowAlert? showAlert = parameters.showAlert;

  // Call the signalNewConsumerTransport function
  final optionsSignal = SignalNewConsumerTransportOptions(
    remoteProducerId: producerId,
    islevel: islevel,
    nsock: nsock,
    parameters: parameters,
  );
  await signalNewConsumerTransport(
    optionsSignal,
  );

  // Modify firstRound and landscape status
  firstRound = false;
  if (shareScreenStarted || shared) {
    if (!isWideScreen && !landScaped) {
      showAlert!(
        message:
            'Please rotate your device to landscape mode for better experience',
        type: 'success',
        duration: 3000,
      );
      landScaped = true;
      parameters.updateLandScaped(landScaped);
    }
    firstRound = true;
    parameters.updateFirstRound(firstRound);
  }
}
