/// Translation Socket Receive Methods
///
/// Handler implementations for translation-related socket events.
///
/// Listens for:
/// - translation:roomConfig - Room-level translation configuration
/// - translation:configUpdated - Host updated room config
/// - translation:languageSet - Confirmation of spoken language set
/// - translation:subscribed - Confirmation of translation subscription
/// - translation:unsubscribed - Confirmation of translation unsubscription
/// - translation:producerReady - Translation producer is available for consumption
/// - translation:producerClosed - Translation producer was closed
/// - translation:channelsAvailable - Channels available from a speaker
/// - translation:memberState - Another member's translation state
/// - translation:error - Translation operation error
/// - translation:transcript - Live transcription text
/// - translation:speakerOutputChanged - Speaker changed output language
library;


import '../../types/types.dart' show ShowAlert;
import '../../methods/utils/translation_languages.dart'
    show TranslationVoiceConfig, getLanguageName;

// ============================================================================
// Types
// ============================================================================

/// Language mode for allowlist/blocklist filtering
enum LanguageMode { allowlist, blocklist, any }

/// Language entry with optional per-language voice config
class LanguageEntry {
  final String code;
  final String? nickname;
  final TranslationVoiceConfig? voiceConfig;

  const LanguageEntry({
    required this.code,
    this.nickname,
    this.voiceConfig,
  });

  factory LanguageEntry.fromMap(Map<String, dynamic> map) {
    return LanguageEntry(
      code: map['code'] as String? ?? '',
      nickname: map['nickname'] as String?,
      voiceConfig: map['voiceConfig'] != null
          ? TranslationVoiceConfig.fromMap(
              map['voiceConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      if (nickname != null) 'nickname': nickname,
      if (voiceConfig != null) 'voiceConfig': voiceConfig!.toMap(),
    };
  }
}

/// Room-level translation configuration
class TranslationRoomConfig {
  final bool supportTranslation;
  final LanguageMode spokenLanguageMode;
  final List<LanguageEntry>? allowedSpokenLanguages;
  final List<String>? blockedSpokenLanguages;
  final LanguageMode listenLanguageMode;
  final List<LanguageEntry>? allowedListenLanguages;
  final List<String>? blockedListenLanguages;
  final int maxActiveChannelsPerSpeaker;
  final bool autoDetectSpokenLanguage;
  final bool? allowSpokenLanguageChange;
  final bool? allowListenLanguageChange;
  final TranslationVoiceConfig? translationVoiceConfig;

  const TranslationRoomConfig({
    required this.supportTranslation,
    required this.spokenLanguageMode,
    this.allowedSpokenLanguages,
    this.blockedSpokenLanguages,
    required this.listenLanguageMode,
    this.allowedListenLanguages,
    this.blockedListenLanguages,
    required this.maxActiveChannelsPerSpeaker,
    required this.autoDetectSpokenLanguage,
    this.allowSpokenLanguageChange,
    this.allowListenLanguageChange,
    this.translationVoiceConfig,
  });

  factory TranslationRoomConfig.fromMap(Map<String, dynamic> map) {
    return TranslationRoomConfig(
      supportTranslation: map['supportTranslation'] as bool? ?? false,
      spokenLanguageMode: _parseLanguageMode(map['spokenLanguageMode']),
      allowedSpokenLanguages: (map['allowedSpokenLanguages'] as List?)
          ?.map((e) => LanguageEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      blockedSpokenLanguages:
          (map['blockedSpokenLanguages'] as List?)?.cast<String>(),
      listenLanguageMode: _parseLanguageMode(map['listenLanguageMode']),
      allowedListenLanguages: (map['allowedListenLanguages'] as List?)
          ?.map((e) => LanguageEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      blockedListenLanguages:
          (map['blockedListenLanguages'] as List?)?.cast<String>(),
      maxActiveChannelsPerSpeaker:
          map['maxActiveChannelsPerSpeaker'] as int? ?? 5,
      autoDetectSpokenLanguage:
          map['autoDetectSpokenLanguage'] as bool? ?? false,
      allowSpokenLanguageChange: map['allowSpokenLanguageChange'] as bool?,
      allowListenLanguageChange: map['allowListenLanguageChange'] as bool?,
      translationVoiceConfig: map['translationVoiceConfig'] != null
          ? TranslationVoiceConfig.fromMap(
              map['translationVoiceConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supportTranslation': supportTranslation,
      'spokenLanguageMode': spokenLanguageMode.name,
      if (allowedSpokenLanguages != null)
        'allowedSpokenLanguages':
            allowedSpokenLanguages!.map((e) => e.toMap()).toList(),
      if (blockedSpokenLanguages != null)
        'blockedSpokenLanguages': blockedSpokenLanguages,
      'listenLanguageMode': listenLanguageMode.name,
      if (allowedListenLanguages != null)
        'allowedListenLanguages':
            allowedListenLanguages!.map((e) => e.toMap()).toList(),
      if (blockedListenLanguages != null)
        'blockedListenLanguages': blockedListenLanguages,
      'maxActiveChannelsPerSpeaker': maxActiveChannelsPerSpeaker,
      'autoDetectSpokenLanguage': autoDetectSpokenLanguage,
      if (allowSpokenLanguageChange != null)
        'allowSpokenLanguageChange': allowSpokenLanguageChange,
      if (allowListenLanguageChange != null)
        'allowListenLanguageChange': allowListenLanguageChange,
      if (translationVoiceConfig != null)
        'translationVoiceConfig': translationVoiceConfig!.toMap(),
    };
  }
}

// ============================================================================
// Event Data Types
// ============================================================================

class TranslationRoomConfigData {
  final TranslationRoomConfig config;

  TranslationRoomConfigData({required this.config});

  factory TranslationRoomConfigData.fromMap(Map<String, dynamic> map) {
    return TranslationRoomConfigData(
      config:
          TranslationRoomConfig.fromMap(map['config'] as Map<String, dynamic>),
    );
  }
}

class TranslationConfigUpdatedData {
  final TranslationRoomConfig config;

  TranslationConfigUpdatedData({required this.config});

  factory TranslationConfigUpdatedData.fromMap(Map<String, dynamic> map) {
    return TranslationConfigUpdatedData(
      config:
          TranslationRoomConfig.fromMap(map['config'] as Map<String, dynamic>),
    );
  }
}

class TranslationLanguageSetData {
  final bool success;
  final String language;
  final bool enabled;
  final String? error;

  TranslationLanguageSetData({
    required this.success,
    required this.language,
    required this.enabled,
    this.error,
  });

  factory TranslationLanguageSetData.fromMap(Map<String, dynamic> map) {
    return TranslationLanguageSetData(
      success: map['success'] as bool? ?? false,
      language: map['language'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? false,
      error: map['error'] as String?,
    );
  }
}

class TranslationSubscribedData {
  final String speakerId;
  final String? speakerName;
  final String language;
  final bool channelCreated;
  final String? producerId;
  final String? originalProducerId;

  TranslationSubscribedData({
    required this.speakerId,
    this.speakerName,
    required this.language,
    required this.channelCreated,
    this.producerId,
    this.originalProducerId,
  });

  factory TranslationSubscribedData.fromMap(Map<String, dynamic> map) {
    return TranslationSubscribedData(
      speakerId: map['speakerId'] as String? ?? '',
      speakerName: map['speakerName'] as String?,
      language: map['language'] as String? ?? '',
      channelCreated: map['channelCreated'] as bool? ?? false,
      producerId: map['producerId'] as String?,
      originalProducerId: map['originalProducerId'] as String?,
    );
  }
}

class TranslationUnsubscribedData {
  final String speakerId;
  final String language;
  final bool channelClosed;

  TranslationUnsubscribedData({
    required this.speakerId,
    required this.language,
    required this.channelClosed,
  });

  factory TranslationUnsubscribedData.fromMap(Map<String, dynamic> map) {
    return TranslationUnsubscribedData(
      speakerId: map['speakerId'] as String? ?? '',
      language: map['language'] as String? ?? '',
      channelClosed: map['channelClosed'] as bool? ?? false,
    );
  }
}

class TranslationProducerReadyData {
  final String speakerId;
  final String? speakerName;
  final String language;
  final String producerId;
  final String originalProducerId;

  TranslationProducerReadyData({
    required this.speakerId,
    this.speakerName,
    required this.language,
    required this.producerId,
    required this.originalProducerId,
  });

  factory TranslationProducerReadyData.fromMap(Map<String, dynamic> map) {
    return TranslationProducerReadyData(
      speakerId: map['speakerId'] as String? ?? '',
      speakerName: map['speakerName'] as String?,
      language: map['language'] as String? ?? '',
      producerId: map['producerId'] as String? ?? '',
      originalProducerId: map['originalProducerId'] as String? ?? '',
    );
  }
}

class TranslationProducerClosedData {
  final String speakerId;
  final String language;
  final String producerId;
  final String? reason;

  TranslationProducerClosedData({
    required this.speakerId,
    required this.language,
    required this.producerId,
    this.reason,
  });

  factory TranslationProducerClosedData.fromMap(Map<String, dynamic> map) {
    return TranslationProducerClosedData(
      speakerId: map['speakerId'] as String? ?? '',
      language: map['language'] as String? ?? '',
      producerId: map['producerId'] as String? ?? '',
      reason: map['reason'] as String?,
    );
  }
}

class TranslationChannelsAvailableData {
  final String speakerId;
  final String? speakerName;
  final List<String> languages;
  final String originalProducerId;

  TranslationChannelsAvailableData({
    required this.speakerId,
    this.speakerName,
    required this.languages,
    required this.originalProducerId,
  });

  factory TranslationChannelsAvailableData.fromMap(Map<String, dynamic> map) {
    return TranslationChannelsAvailableData(
      speakerId: map['speakerId'] as String? ?? '',
      speakerName: map['speakerName'] as String?,
      languages: (map['languages'] as List?)?.cast<String>() ?? [],
      originalProducerId: map['originalProducerId'] as String? ?? '',
    );
  }
}

class TranslationMemberStateData {
  final String memberId;
  final String? memberName;
  final Map<String, dynamic> state;

  TranslationMemberStateData({
    required this.memberId,
    this.memberName,
    required this.state,
  });

  factory TranslationMemberStateData.fromMap(Map<String, dynamic> map) {
    return TranslationMemberStateData(
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String?,
      state: map['state'] as Map<String, dynamic>? ?? {},
    );
  }
}

class TranslationErrorData {
  final String error;
  final String? code;
  final dynamic details;
  final List<String>? availableChannels;
  final int? maxChannels;
  final String? message;

  TranslationErrorData({
    required this.error,
    this.code,
    this.details,
    this.availableChannels,
    this.maxChannels,
    this.message,
  });

  factory TranslationErrorData.fromMap(Map<String, dynamic> map) {
    return TranslationErrorData(
      error: map['error'] as String? ?? '',
      code: map['code'] as String?,
      details: map['details'],
      availableChannels: (map['availableChannels'] as List?)?.cast<String>(),
      maxChannels: map['maxChannels'] as int?,
      message: map['message'] as String?,
    );
  }
}

class TranslationSpeakerOutputChangedData {
  final String speakerId;
  final String speakerName;
  final String inputLanguage;
  final String? outputLanguage;
  final String originalProducerId;
  final bool enabled;

  TranslationSpeakerOutputChangedData({
    required this.speakerId,
    required this.speakerName,
    required this.inputLanguage,
    this.outputLanguage,
    required this.originalProducerId,
    required this.enabled,
  });

  factory TranslationSpeakerOutputChangedData.fromMap(
      Map<String, dynamic> map) {
    return TranslationSpeakerOutputChangedData(
      speakerId: map['speakerId'] as String? ?? '',
      speakerName: map['speakerName'] as String? ?? '',
      inputLanguage: map['inputLanguage'] as String? ?? '',
      outputLanguage: map['outputLanguage'] as String?,
      originalProducerId: map['originalProducerId'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? false,
    );
  }
}

class TranslationTranscriptData {
  final String speakerId;
  final String speakerName;
  final String language;
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String? detectedLanguage;
  final int timestamp;

  TranslationTranscriptData({
    required this.speakerId,
    required this.speakerName,
    required this.language,
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    this.detectedLanguage,
    required this.timestamp,
  });

  factory TranslationTranscriptData.fromMap(Map<String, dynamic> map) {
    return TranslationTranscriptData(
      speakerId: map['speakerId'] as String? ?? '',
      speakerName: map['speakerName'] as String? ?? '',
      language: map['language'] as String? ?? '',
      originalText: map['originalText'] as String? ?? '',
      translatedText: map['translatedText'] as String? ?? '',
      sourceLang: map['sourceLang'] as String? ?? '',
      detectedLanguage: map['detectedLanguage'] as String?,
      timestamp: map['timestamp'] as int? ?? 0,
    );
  }
}

/// Translation producer map type
/// Maps originalProducerId -> { languageCode: translationProducerId }
typedef TranslationProducerMap = Map<String, Map<String, String>>;

// ============================================================================
// Options Interfaces
// ============================================================================

class TranslationRoomConfigOptions {
  final TranslationRoomConfigData data;
  final void Function(TranslationRoomConfig)? updateTranslationConfig;
  final void Function(bool)? updateTranslationSupported;

  TranslationRoomConfigOptions({
    required this.data,
    this.updateTranslationConfig,
    this.updateTranslationSupported,
  });
}

class TranslationConfigUpdatedOptions {
  final TranslationConfigUpdatedData data;
  final void Function(TranslationRoomConfig)? updateTranslationConfig;
  final ShowAlert? showAlert;

  TranslationConfigUpdatedOptions({
    required this.data,
    this.updateTranslationConfig,
    this.showAlert,
  });
}

class TranslationLanguageSetOptions {
  final TranslationLanguageSetData data;
  final void Function(String)? updateMySpokenLanguage;
  final void Function(bool)? updateMySpokenLanguageEnabled;
  final ShowAlert? showAlert;

  TranslationLanguageSetOptions({
    required this.data,
    this.updateMySpokenLanguage,
    this.updateMySpokenLanguageEnabled,
    this.showAlert,
  });
}

class TranslationSubscribedOptions {
  final TranslationSubscribedData data;
  final void Function(Map<String, String> Function(Map<String, String>))?
      updateListenPreferences;
  final void Function(TranslationProducerMap Function(TranslationProducerMap))?
      updateTranslationProducerMap;
  final Future<void> Function(String producerId, String speakerId,
      String language, String originalProducerId)? startConsumingTranslation;
  final ShowAlert? showAlert;

  TranslationSubscribedOptions({
    required this.data,
    this.updateListenPreferences,
    this.updateTranslationProducerMap,
    this.startConsumingTranslation,
    this.showAlert,
  });
}

class TranslationUnsubscribedOptions {
  final TranslationUnsubscribedData data;
  final void Function(Map<String, String> Function(Map<String, String>))?
      updateListenPreferences;
  final Future<void> Function(String speakerId, String language)?
      stopConsumingTranslation;

  TranslationUnsubscribedOptions({
    required this.data,
    this.updateListenPreferences,
    this.stopConsumingTranslation,
  });
}

class TranslationProducerReadyOptions {
  final TranslationProducerReadyData data;
  final void Function(TranslationProducerMap Function(TranslationProducerMap))?
      updateTranslationProducerMap;
  final Future<void> Function(String originalProducerId)? pauseOriginalProducer;
  final ShowAlert? showAlert;

  TranslationProducerReadyOptions({
    required this.data,
    this.updateTranslationProducerMap,
    this.pauseOriginalProducer,
    this.showAlert,
  });
}

class TranslationProducerClosedOptions {
  final TranslationProducerClosedData data;
  final void Function(TranslationProducerMap Function(TranslationProducerMap))?
      updateTranslationProducerMap;
  final Future<void> Function(String producerId)? stopConsumingTranslation;
  final Future<void> Function(String speakerId)? resumeOriginalProducer;
  final ShowAlert? showAlert;

  TranslationProducerClosedOptions({
    required this.data,
    this.updateTranslationProducerMap,
    this.stopConsumingTranslation,
    this.resumeOriginalProducer,
    this.showAlert,
  });
}

class TranslationChannelsAvailableOptions {
  final TranslationChannelsAvailableData data;
  final void Function(
          String speakerId, List<String> languages, String originalProducerId)?
      updateAvailableTranslationChannels;
  final String? myDefaultListenLanguage;
  final dynamic socket;
  final String? roomName;

  TranslationChannelsAvailableOptions({
    required this.data,
    this.updateAvailableTranslationChannels,
    this.myDefaultListenLanguage,
    this.socket,
    this.roomName,
  });
}

class TranslationMemberStateOptions {
  final TranslationMemberStateData data;
  final void Function(String memberId, Map<String, dynamic> state)?
      updateParticipantTranslationState;

  TranslationMemberStateOptions({
    required this.data,
    this.updateParticipantTranslationState,
  });
}

class TranslationErrorOptions {
  final TranslationErrorData data;
  final ShowAlert? showAlert;

  TranslationErrorOptions({
    required this.data,
    this.showAlert,
  });
}

class TranslationTranscriptOptions {
  final TranslationTranscriptData data;
  final void Function(
      List<TranslationTranscriptData> Function(
          List<TranslationTranscriptData>))? updateTranscripts;
  final void Function(TranslationTranscriptData)? onTranscriptReceived;
  final int maxTranscripts;

  TranslationTranscriptOptions({
    required this.data,
    this.updateTranscripts,
    this.onTranscriptReceived,
    this.maxTranscripts = 100,
  });
}

/// Listener override for speaker output
class ListenerOverride {
  final String speakerId;
  final bool wantOriginal;
  final String? preferredLanguage;

  ListenerOverride({
    required this.speakerId,
    required this.wantOriginal,
    this.preferredLanguage,
  });
}

class TranslationSpeakerOutputChangedOptions {
  final TranslationSpeakerOutputChangedData data;
  final Future<void> Function(String originalProducerId, String speakerId)?
      pauseOriginalProducer;
  final Future<void> Function(String originalProducerId, String speakerId)?
      resumeOriginalProducer;
  final Future<void> Function(String speakerId)?
      stopConsumingTranslationForSpeaker;
  final void Function(
          String speakerId, String? outputLanguage, String originalProducerId)?
      updateSpeakerTranslationState;
  final ShowAlert? showAlert;
  final ListenerOverride? listenerOverride;

  TranslationSpeakerOutputChangedOptions({
    required this.data,
    this.pauseOriginalProducer,
    this.resumeOriginalProducer,
    this.stopConsumingTranslationForSpeaker,
    this.updateSpeakerTranslationState,
    this.showAlert,
    this.listenerOverride,
  });
}

// ============================================================================
// Type Exports
// ============================================================================

typedef TranslationRoomConfigType = Future<void> Function(
    TranslationRoomConfigOptions options);
typedef TranslationConfigUpdatedType = Future<void> Function(
    TranslationConfigUpdatedOptions options);
typedef TranslationLanguageSetType = Future<void> Function(
    TranslationLanguageSetOptions options);
typedef TranslationSubscribedType = Future<void> Function(
    TranslationSubscribedOptions options);
typedef TranslationUnsubscribedType = Future<void> Function(
    TranslationUnsubscribedOptions options);
typedef TranslationProducerReadyType = Future<void> Function(
    TranslationProducerReadyOptions options);
typedef TranslationProducerClosedType = Future<void> Function(
    TranslationProducerClosedOptions options);
typedef TranslationChannelsAvailableType = Future<void> Function(
    TranslationChannelsAvailableOptions options);
typedef TranslationMemberStateType = Future<void> Function(
    TranslationMemberStateOptions options);
typedef TranslationErrorType = Future<void> Function(
    TranslationErrorOptions options);
typedef TranslationTranscriptType = Future<void> Function(
    TranslationTranscriptOptions options);
typedef TranslationSpeakerOutputChangedType = Future<void> Function(
    TranslationSpeakerOutputChangedOptions options);

// ============================================================================
// Handlers
// ============================================================================

/// Handles the translation:roomConfig socket event.
/// Called when joining a room to receive room-level translation configuration.
Future<void> translationRoomConfig(TranslationRoomConfigOptions options) async {
  try {
    final config = options.data.config;

    options.updateTranslationSupported?.call(config.supportTranslation);

    if (config.supportTranslation) {
      options.updateTranslationConfig?.call(config);
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:configUpdated socket event.
/// Called when the host changes room translation settings.
Future<void> translationConfigUpdated(
    TranslationConfigUpdatedOptions options) async {
  try {
    final config = options.data.config;

    options.updateTranslationConfig?.call(config);

    options.showAlert?.call(
      message: 'Translation settings updated by host',
      type: 'info',
      duration: 2000,
    );
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:languageSet socket event.
/// Called when the user's spoken language is confirmed.
Future<void> translationLanguageSet(
    TranslationLanguageSetOptions options) async {
  try {
    final data = options.data;

    if (data.success) {
      options.updateMySpokenLanguage?.call(data.language);
      options.updateMySpokenLanguageEnabled?.call(data.enabled);
    } else if (data.error != null) {
      options.showAlert?.call(
        message: data.error!,
        type: 'danger',
        duration: 3000,
      );
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:subscribed socket event.
/// Called when successfully subscribed to a translation channel.
Future<void> translationSubscribed(TranslationSubscribedOptions options) async {
  try {
    final data = options.data;

    // Update listen preferences
    options.updateListenPreferences?.call((prev) {
      final next = Map<String, String>.from(prev);
      next[data.speakerId] = data.language;
      return next;
    });

    // Update producer map if we have a producer ID
    if (data.producerId != null && data.originalProducerId != null) {
      options.updateTranslationProducerMap?.call((prev) {
        final next = Map<String, Map<String, String>>.from(prev);
        next[data.originalProducerId!] = {
          ...(next[data.originalProducerId!] ?? {}),
          data.language: data.producerId!,
        };
        return next;
      });
    }

    // Start consuming if producer is ready
    if (data.producerId != null && options.startConsumingTranslation != null) {
      await options.startConsumingTranslation!(data.producerId!, data.speakerId,
          data.language, data.originalProducerId ?? '');
    }

    if (data.channelCreated) {
      options.showAlert?.call(
        message:
            'Translation channel created for ${getLanguageName(data.language)}',
        type: 'success',
        duration: 2000,
      );
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:unsubscribed socket event.
/// Called when unsubscribed from a translation channel.
Future<void> translationUnsubscribed(
    TranslationUnsubscribedOptions options) async {
  try {
    final data = options.data;

    // Update listen preferences
    options.updateListenPreferences?.call((prev) {
      final next = Map<String, String>.from(prev);
      next.remove(data.speakerId);
      return next;
    });

    // Stop consuming
    if (options.stopConsumingTranslation != null) {
      await options.stopConsumingTranslation!(data.speakerId, data.language);
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:producerReady socket event.
/// Called when a translation producer is ready for consumption.
Future<void> translationProducerReady(
    TranslationProducerReadyOptions options) async {
  try {
    final data = options.data;

    // Update producer map
    options.updateTranslationProducerMap?.call((prev) {
      final next = Map<String, Map<String, String>>.from(prev);
      next[data.originalProducerId] = {
        ...(next[data.originalProducerId] ?? {}),
        data.language: data.producerId,
      };
      return next;
    });

    // Pause original producer to save bandwidth
    if (options.pauseOriginalProducer != null) {
      await options.pauseOriginalProducer!(data.originalProducerId);
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:producerClosed socket event.
/// Called when a translation producer is closed.
Future<void> translationProducerClosed(
    TranslationProducerClosedOptions options) async {
  try {
    final data = options.data;

    // Remove from producer map
    options.updateTranslationProducerMap?.call((prev) {
      final next = Map<String, Map<String, String>>.from(prev);
      for (final entry in next.entries.toList()) {
        final langMap = entry.value;
        if (langMap[data.language] == data.producerId) {
          langMap.remove(data.language);
          if (langMap.isEmpty) {
            next.remove(entry.key);
          }
        }
      }
      return next;
    });

    // Stop consuming
    if (options.stopConsumingTranslation != null) {
      await options.stopConsumingTranslation!(data.producerId);
    }

    // Resume original producer
    if (options.resumeOriginalProducer != null) {
      await options.resumeOriginalProducer!(data.speakerId);
    }

    if (data.reason != null) {
      options.showAlert?.call(
        message: 'Translation stopped: ${data.reason}',
        type: 'info',
        duration: 2000,
      );
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:channelsAvailable socket event.
/// Called when a speaker has translation channels available.
Future<void> translationChannelsAvailable(
    TranslationChannelsAvailableOptions options) async {
  try {
    final data = options.data;

    options.updateAvailableTranslationChannels?.call(
      data.speakerId,
      data.languages,
      data.originalProducerId,
    );

    // Auto-subscribe if user has a default listen language
    final myDefaultListenLanguage = options.myDefaultListenLanguage;
    if (myDefaultListenLanguage != null &&
        data.languages.contains(myDefaultListenLanguage) &&
        options.socket != null &&
        options.roomName != null) {
      options.socket.emit('translation:subscribe', {
        'roomName': options.roomName,
        'speakerId': data.speakerId,
        'language': myDefaultListenLanguage,
        'originalProducerId': data.originalProducerId,
      });
    }
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:memberState socket event.
/// Called when another member's translation state changes.
Future<void> translationMemberState(
    TranslationMemberStateOptions options) async {
  try {
    final data = options.data;

    options.updateParticipantTranslationState?.call(data.memberId, data.state);
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:error socket event.
/// Called when a translation operation fails.
Future<void> translationError(TranslationErrorOptions options) async {
  try {
    final data = options.data;
    String message = data.error;

    // Provide user-friendly messages for known error codes
    switch (data.code) {
      case 'max_channels':
        if (data.availableChannels != null &&
            data.availableChannels!.isNotEmpty) {
          message =
              'Maximum ${data.maxChannels ?? 5} translation channels reached. Available: ${data.availableChannels!.join(', ')}';
        } else {
          message = data.message ??
              'Maximum translation channels reached. Please wait for a slot to open.';
        }
        break;
      case 'speaker_not_found':
        message = 'Speaker not found or has left the meeting.';
        break;
      case 'language_not_allowed':
        message =
            'This language is not available for translation in this room.';
        break;
      default:
        message =
            data.error.isNotEmpty ? data.error : 'Translation error occurred';
    }

    options.showAlert?.call(
      message: message,
      type: 'danger',
      duration: 5000,
    );
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:transcript socket event.
/// Called when a translation transcript (text) is available for display.
Future<void> translationTranscript(TranslationTranscriptOptions options) async {
  try {
    final data = options.data;

    // Update transcript state
    options.updateTranscripts?.call((prev) {
      final next = [...prev, data];
      // Keep only last N transcripts
      if (next.length > options.maxTranscripts) {
        return next.sublist(next.length - options.maxTranscripts);
      }
      return next;
    });

    // Call custom callback
    options.onTranscriptReceived?.call(data);
  } catch (e) {
    // Handle error silently
  }
}

/// Handles the translation:speakerOutputChanged socket event.
/// Called when a speaker changes their output language.
Future<void> translationSpeakerOutputChanged(
    TranslationSpeakerOutputChangedOptions options) async {
  try {
    final data = options.data;

    // Update local tracking state
    options.updateSpeakerTranslationState?.call(
      data.speakerId,
      data.outputLanguage,
      data.originalProducerId,
    );

    // Check if listener has an override
    final listenerWantsOriginal =
        options.listenerOverride?.wantOriginal == true;
    final listenerWantsDifferentLanguage =
        options.listenerOverride?.preferredLanguage != null &&
            options.listenerOverride!.preferredLanguage!.toLowerCase() !=
                data.outputLanguage?.toLowerCase();

    // If listener wants original audio, don't pause
    if (listenerWantsOriginal) {
      options.showAlert?.call(
        message:
            '${data.speakerName} is speaking in ${data.outputLanguage != null ? getLanguageName(data.outputLanguage!) : 'translated'} but you\'re hearing original',
        type: 'info',
        duration: 3000,
      );
      return;
    }

    // If listener wants a different language, still pause original
    if (listenerWantsDifferentLanguage) {
      if (options.pauseOriginalProducer != null) {
        await options.pauseOriginalProducer!(
            data.originalProducerId, data.speakerId);
      }
      return;
    }

    if (data.enabled && data.outputLanguage != null) {
      // Speaker has enabled translation output - pause original audio
      if (options.pauseOriginalProducer != null) {
        await options.pauseOriginalProducer!(
            data.originalProducerId, data.speakerId);
      }

      options.showAlert?.call(
        message:
            '${data.speakerName} is now speaking in ${getLanguageName(data.outputLanguage!)}',
        type: 'info',
        duration: 3000,
      );
    } else {
      // Speaker disabled translation - stop consuming and resume original
      if (options.stopConsumingTranslationForSpeaker != null) {
        await options.stopConsumingTranslationForSpeaker!(data.speakerId);
      }

      if (options.resumeOriginalProducer != null) {
        await options.resumeOriginalProducer!(
            data.originalProducerId, data.speakerId);
      }

      if (!data.enabled) {
        options.showAlert?.call(
          message: '${data.speakerName} returned to original language',
          type: 'info',
          duration: 3000,
        );
      }
    }
  } catch (e) {
    // Handle error silently
  }
}

// ============================================================================
// Private Helpers
// ============================================================================

LanguageMode _parseLanguageMode(dynamic value) {
  if (value is LanguageMode) return value;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'allowlist':
        return LanguageMode.allowlist;
      case 'blocklist':
        return LanguageMode.blocklist;
      case 'any':
        return LanguageMode.any;
      default:
        return LanguageMode.any;
    }
  }
  return LanguageMode.any;
}
