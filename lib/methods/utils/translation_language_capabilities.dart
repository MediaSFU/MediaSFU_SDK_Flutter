/// Translation language capabilities.
///
/// GENERATED FILE - do not edit by hand. Regenerated from MediaSFU's translation language
/// measurements (measured 2026-10-20).
///
/// Each language is rated three ways, per managed preset and per measured provider:
/// - speak:    how well a speaker who sets this language is transcribed (speech-to-text)
/// - captions: how well translated captions read in this language (translation model)
/// - voice:    whether translated speech in this language uses a natural voice (text-to-speech)
///
/// Use listenerGroup() to group listener languages, speakerListing() to build speaker lists,
/// and autoDetectLanguages to decide when automatic language detection is reliable.
library;

import 'translation_languages.dart' show TTSSupport, VoiceGender;

/// Speech-to-text quality when the speaker sets the language.
enum SpeakTier { excellent, good, basic, none }

/// Quality of translated captions into the language.
enum CaptionTier { excellent, good, basic, none }

/// Translated speech in the language.
enum VoiceTier { natural, basic, none, unknown }

/// Where a language belongs in a listener (translated language) picker.
enum ListenerGroup { naturalVoice, captionsBasicVoice, captionsOnly, captionsPreview, hidden }

/// Whether a language belongs in a speaker (spoken language) picker.
enum SpeakerListing { yes, beta, no }

/// Provider ids for each stage, e.g. `deepgram:nova-3`, `openai:gpt-4o-mini`, `fish:s2.1-pro`.
class LanguageCapabilityProviders {
  final String stt;
  final String llm;

  /// LLM used for captions in languages where [llm] is below good and this one is good.
  final String? llmFallback;
  final String tts;

  const LanguageCapabilityProviders({
    required this.stt,
    required this.llm,
    this.llmFallback,
    required this.tts,
  });
}

/// A managed preset ('system' or 'demo') or a custom stack of provider ids from [providerCapabilities].
class LanguageCapabilityStack {
  /// 'system' or 'demo' for a managed preset; null for a custom stack.
  final String? preset;
  final String stt;
  final String llm;

  /// Optional LLM that supplies captions where [llm] is below good and this one is good.
  final String? llmFallback;
  final String tts;

  const LanguageCapabilityStack.system()
      : preset = 'system',
        stt = '',
        llm = '',
        llmFallback = null,
        tts = '';
  const LanguageCapabilityStack.demo()
      : preset = 'demo',
        stt = '',
        llm = '',
        llmFallback = null,
        tts = '';
  const LanguageCapabilityStack.custom({
    required this.stt,
    required this.llm,
    this.llmFallback,
    required this.tts,
  }) : preset = null;

  /// Builds a stack from a preset name ('system', 'demo'); unknown names use 'system'.
  factory LanguageCapabilityStack.fromPreset(String? name) => name == 'demo'
      ? const LanguageCapabilityStack.demo()
      : const LanguageCapabilityStack.system();

  bool get isCustom => preset == null;
}

/// Ratings for one language on one provider stack.
class LanguageCapability {
  /// Speech-to-text quality when the speaker sets this language.
  final SpeakTier speak;

  /// Quality of translated captions into this language.
  final CaptionTier captions;

  /// Translated speech in this language.
  final VoiceTier voice;

  /// Voice genders the voice route offers for this language.
  final List<VoiceGender>? voiceGenders;

  /// Providers the rating applies to.
  final LanguageCapabilityProviders providers;

  /// ISO date of the measurement; empty for languages that were not measured.
  final String measuredAt;

  const LanguageCapability({
    required this.speak,
    required this.captions,
    required this.voice,
    this.voiceGenders,
    required this.providers,
    required this.measuredAt,
  });
}

/// Voice rating for one language on one text-to-speech provider.
class VoiceCapability {
  final VoiceTier voice;
  final List<VoiceGender>? genders;

  const VoiceCapability({required this.voice, this.genders});
}

/// Measured tiers per provider id, then language code. Used to rate custom provider stacks.
class ProviderCapabilities {
  final Map<String, Map<String, SpeakTier>> stt;
  final Map<String, Map<String, CaptionTier>> llm;
  final Map<String, Map<String, VoiceCapability>> tts;

  const ProviderCapabilities({
    required this.stt,
    required this.llm,
    required this.tts,
  });
}

/// A listener picker group with its languages.
class ListenerLanguageGroup<T> {
  final ListenerGroup group;
  final String label;
  final String note;
  final List<T> languages;

  const ListenerLanguageGroup({
    required this.group,
    required this.label,
    required this.note,
    required this.languages,
  });
}

const String languageCapabilitiesMeasuredAt = '2026-10-20';

/// Languages covered by the measurement, in table order.
const List<String> measuredLanguageCodes = [
  'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar', 'hi', 'bn',
  'pa', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'ml', 'ne', 'si', 'nl', 'pl', 'tr',
  'cs', 'el', 'hu', 'ro', 'sv', 'da', 'fi', 'no', 'sk', 'uk', 'bg', 'hr', 'et',
  'lt', 'lv', 'sl', 'sr', 'bs', 'mk', 'is', 'ga', 'cy', 'mt', 'lb', 'sq', 'be',
  'he', 'fa', 'ps', 'ku', 'vi', 'th', 'id', 'ms', 'tl', 'km', 'lo', 'my', 'sw',
  'yo', 'ig', 'ha', 'zu', 'xh', 'af', 'st', 'tn', 'sn', 'am', 'so', 'rw', 'mg',
  'ny', 'ee', 'tw', 'gaa', 'ka', 'hy', 'az', 'eu', 'gl', 'ca', 'la', 'eo', 'kk',
  'tg', 'ky', 'tk', 'mn', 'uz',
];

/// Provider stacks behind the managed presets.
const Map<String, LanguageCapabilityProviders> languageCapabilityPresetStacks = {
  'system': LanguageCapabilityProviders(stt: 'deepgram:nova-3', llm: 'groq:openai/gpt-oss-120b:low', llmFallback: 'gemini:gemini-3.5-flash-lite', tts: 'default'),
  'demo': LanguageCapabilityProviders(stt: 'deepgram:nova-3', llm: 'groq:openai/gpt-oss-20b', tts: 'default'),
};

const Map<ListenerGroup, String> listenerGroupLabels = {
  ListenerGroup.naturalVoice: 'Natural voice',
  ListenerGroup.captionsBasicVoice: 'Captions + basic voice',
  ListenerGroup.captionsOnly: 'Captions only',
  ListenerGroup.captionsPreview: 'Captions (preview)',
  ListenerGroup.hidden: 'Not available',
};

const Map<ListenerGroup, String> listenerGroupNotes = {
  ListenerGroup.naturalVoice: 'Translated voice and captions',
  ListenerGroup.captionsBasicVoice: 'Captions, with a simpler voice',
  ListenerGroup.captionsOnly: 'Live captions in your language',
  ListenerGroup.captionsPreview: 'Early caption support',
  ListenerGroup.hidden: '',
};

const Map<String, List<VoiceGender>> _genderSets = {
  'fm': [VoiceGender.female, VoiceGender.male],
  'f': [VoiceGender.female],
  'm': [VoiceGender.male],
  'n': [VoiceGender.neutral],
};

const Map<String, Map<String, SpeakTier>> _sttCapabilities = {
  'deepgram:nova-3': {
    'en': SpeakTier.excellent, 'es': SpeakTier.excellent, 'fr': SpeakTier.good,
    'de': SpeakTier.excellent, 'it': SpeakTier.excellent,
    'pt': SpeakTier.excellent, 'ru': SpeakTier.excellent,
    'zh': SpeakTier.excellent, 'ja': SpeakTier.excellent, 'ko': SpeakTier.good,
    'ar': SpeakTier.excellent, 'hi': SpeakTier.excellent, 'bn': SpeakTier.good,
    'pa': SpeakTier.good, 'te': SpeakTier.good, 'mr': SpeakTier.basic,
    'ta': SpeakTier.basic, 'ur': SpeakTier.excellent, 'gu': SpeakTier.excellent,
    'kn': SpeakTier.excellent, 'ml': SpeakTier.none, 'ne': SpeakTier.none,
    'nl': SpeakTier.excellent, 'pl': SpeakTier.excellent,
    'tr': SpeakTier.excellent, 'cs': SpeakTier.excellent, 'el': SpeakTier.good,
    'hu': SpeakTier.excellent, 'ro': SpeakTier.excellent, 'sv': SpeakTier.good,
    'da': SpeakTier.basic, 'fi': SpeakTier.good, 'no': SpeakTier.excellent,
    'sk': SpeakTier.excellent, 'uk': SpeakTier.excellent, 'bg': SpeakTier.good,
    'hr': SpeakTier.excellent, 'et': SpeakTier.excellent, 'lt': SpeakTier.good,
    'lv': SpeakTier.excellent, 'sl': SpeakTier.excellent,
    'sr': SpeakTier.excellent, 'bs': SpeakTier.excellent, 'mk': SpeakTier.basic,
    'is': SpeakTier.none, 'ga': SpeakTier.none, 'cy': SpeakTier.good,
    'mt': SpeakTier.none, 'lb': SpeakTier.none, 'be': SpeakTier.good,
    'he': SpeakTier.basic, 'fa': SpeakTier.good, 'ps': SpeakTier.basic,
    'ku': SpeakTier.none, 'vi': SpeakTier.excellent, 'th': SpeakTier.excellent,
    'id': SpeakTier.excellent, 'ms': SpeakTier.excellent,
    'tl': SpeakTier.excellent, 'km': SpeakTier.none, 'lo': SpeakTier.none,
    'my': SpeakTier.none, 'sw': SpeakTier.good, 'yo': SpeakTier.none,
    'ig': SpeakTier.none, 'ha': SpeakTier.none, 'zu': SpeakTier.none,
    'xh': SpeakTier.none, 'af': SpeakTier.good, 'sn': SpeakTier.none,
    'am': SpeakTier.none, 'so': SpeakTier.none, 'ny': SpeakTier.none,
    'ka': SpeakTier.good, 'hy': SpeakTier.good, 'az': SpeakTier.none,
    'eu': SpeakTier.excellent, 'gl': SpeakTier.excellent, 'ca': SpeakTier.good,
    'kk': SpeakTier.excellent, 'tg': SpeakTier.none, 'ky': SpeakTier.none,
    'mn': SpeakTier.good, 'uz': SpeakTier.none,
  },
  'deepgram:nova-3:auto': {
    'en': SpeakTier.excellent, 'es': SpeakTier.excellent, 'fr': SpeakTier.good,
    'de': SpeakTier.excellent, 'it': SpeakTier.excellent,
    'pt': SpeakTier.excellent, 'ru': SpeakTier.excellent,
    'zh': SpeakTier.excellent, 'ja': SpeakTier.excellent, 'ko': SpeakTier.good,
    'ar': SpeakTier.none, 'hi': SpeakTier.excellent, 'bn': SpeakTier.none,
    'pa': SpeakTier.none, 'te': SpeakTier.none, 'mr': SpeakTier.none,
    'ta': SpeakTier.none, 'ur': SpeakTier.none, 'gu': SpeakTier.none,
    'kn': SpeakTier.none, 'ml': SpeakTier.none, 'ne': SpeakTier.none,
    'nl': SpeakTier.excellent, 'pl': SpeakTier.excellent,
    'tr': SpeakTier.excellent, 'cs': SpeakTier.excellent, 'el': SpeakTier.good,
    'hu': SpeakTier.excellent, 'ro': SpeakTier.none, 'sv': SpeakTier.good,
    'da': SpeakTier.basic, 'fi': SpeakTier.good, 'no': SpeakTier.excellent,
    'sk': SpeakTier.excellent, 'uk': SpeakTier.excellent, 'bg': SpeakTier.good,
    'hr': SpeakTier.none, 'et': SpeakTier.excellent, 'lt': SpeakTier.excellent,
    'lv': SpeakTier.excellent, 'sl': SpeakTier.none, 'sr': SpeakTier.none,
    'bs': SpeakTier.none, 'mk': SpeakTier.none, 'is': SpeakTier.none,
    'ga': SpeakTier.none, 'cy': SpeakTier.none, 'mt': SpeakTier.none,
    'lb': SpeakTier.none, 'be': SpeakTier.none, 'he': SpeakTier.none,
    'fa': SpeakTier.none, 'ps': SpeakTier.none, 'ku': SpeakTier.none,
    'vi': SpeakTier.excellent, 'th': SpeakTier.good, 'id': SpeakTier.excellent,
    'ms': SpeakTier.good, 'tl': SpeakTier.none, 'km': SpeakTier.none,
    'lo': SpeakTier.none, 'my': SpeakTier.none, 'sw': SpeakTier.none,
    'yo': SpeakTier.none, 'ig': SpeakTier.none, 'ha': SpeakTier.none,
    'zu': SpeakTier.none, 'xh': SpeakTier.none, 'af': SpeakTier.none,
    'sn': SpeakTier.none, 'am': SpeakTier.none, 'so': SpeakTier.none,
    'ny': SpeakTier.none, 'ka': SpeakTier.none, 'hy': SpeakTier.none,
    'az': SpeakTier.none, 'eu': SpeakTier.none, 'gl': SpeakTier.basic,
    'ca': SpeakTier.none, 'kk': SpeakTier.none, 'tg': SpeakTier.none,
    'ky': SpeakTier.none, 'mn': SpeakTier.none, 'uz': SpeakTier.none,
  },
  'openai:gpt-4o-transcribe': {
    'en': SpeakTier.excellent, 'es': SpeakTier.excellent, 'fr': SpeakTier.good,
    'de': SpeakTier.excellent, 'it': SpeakTier.excellent,
    'pt': SpeakTier.excellent, 'ru': SpeakTier.excellent,
    'zh': SpeakTier.excellent, 'ja': SpeakTier.excellent,
    'ko': SpeakTier.excellent, 'ar': SpeakTier.excellent, 'hi': SpeakTier.good,
    'bn': SpeakTier.good, 'pa': SpeakTier.good, 'te': SpeakTier.basic,
    'mr': SpeakTier.none, 'ta': SpeakTier.basic, 'ur': SpeakTier.excellent,
    'gu': SpeakTier.excellent, 'kn': SpeakTier.excellent, 'ml': SpeakTier.good,
    'ne': SpeakTier.excellent, 'nl': SpeakTier.excellent,
    'pl': SpeakTier.excellent, 'tr': SpeakTier.excellent,
    'cs': SpeakTier.excellent, 'el': SpeakTier.excellent,
    'hu': SpeakTier.excellent, 'ro': SpeakTier.excellent,
    'sv': SpeakTier.excellent, 'da': SpeakTier.excellent,
    'fi': SpeakTier.excellent, 'no': SpeakTier.excellent,
    'sk': SpeakTier.excellent, 'uk': SpeakTier.excellent,
    'bg': SpeakTier.excellent, 'hr': SpeakTier.excellent,
    'et': SpeakTier.excellent, 'lt': SpeakTier.excellent,
    'lv': SpeakTier.excellent, 'sl': SpeakTier.excellent,
    'sr': SpeakTier.excellent, 'bs': SpeakTier.excellent,
    'mk': SpeakTier.excellent, 'is': SpeakTier.excellent, 'ga': SpeakTier.none,
    'cy': SpeakTier.basic, 'mt': SpeakTier.good, 'lb': SpeakTier.good,
    'be': SpeakTier.excellent, 'he': SpeakTier.good, 'fa': SpeakTier.good,
    'ps': SpeakTier.basic, 'ku': SpeakTier.none, 'vi': SpeakTier.excellent,
    'th': SpeakTier.excellent, 'id': SpeakTier.excellent,
    'ms': SpeakTier.excellent, 'tl': SpeakTier.excellent,
    'km': SpeakTier.excellent, 'lo': SpeakTier.basic, 'my': SpeakTier.basic,
    'sw': SpeakTier.good, 'yo': SpeakTier.none, 'ig': SpeakTier.none,
    'ha': SpeakTier.basic, 'zu': SpeakTier.none, 'xh': SpeakTier.none,
    'af': SpeakTier.excellent, 'sn': SpeakTier.none, 'am': SpeakTier.none,
    'so': SpeakTier.none, 'ny': SpeakTier.none, 'ka': SpeakTier.good,
    'hy': SpeakTier.excellent, 'az': SpeakTier.excellent, 'eu': SpeakTier.basic,
    'gl': SpeakTier.excellent, 'ca': SpeakTier.excellent,
    'kk': SpeakTier.excellent, 'tg': SpeakTier.good, 'ky': SpeakTier.excellent,
    'mn': SpeakTier.basic, 'uz': SpeakTier.none,
  },
};

const Map<String, Map<String, CaptionTier>> _llmCapabilities = {
  'openai:gpt-4o-mini': {
    'en': CaptionTier.excellent, 'es': CaptionTier.excellent,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.excellent,
    'ru': CaptionTier.excellent, 'zh': CaptionTier.excellent,
    'ja': CaptionTier.excellent, 'ko': CaptionTier.excellent,
    'ar': CaptionTier.excellent, 'hi': CaptionTier.excellent,
    'bn': CaptionTier.good, 'pa': CaptionTier.good, 'te': CaptionTier.good,
    'mr': CaptionTier.excellent, 'ta': CaptionTier.good,
    'ur': CaptionTier.excellent, 'gu': CaptionTier.excellent,
    'kn': CaptionTier.good, 'ml': CaptionTier.excellent, 'ne': CaptionTier.good,
    'si': CaptionTier.good, 'nl': CaptionTier.excellent,
    'pl': CaptionTier.excellent, 'tr': CaptionTier.excellent,
    'cs': CaptionTier.excellent, 'el': CaptionTier.excellent,
    'hu': CaptionTier.excellent, 'ro': CaptionTier.excellent,
    'sv': CaptionTier.excellent, 'da': CaptionTier.excellent,
    'fi': CaptionTier.excellent, 'no': CaptionTier.excellent,
    'sk': CaptionTier.excellent, 'uk': CaptionTier.excellent,
    'bg': CaptionTier.excellent, 'hr': CaptionTier.excellent,
    'et': CaptionTier.good, 'lt': CaptionTier.excellent,
    'lv': CaptionTier.excellent, 'sl': CaptionTier.excellent,
    'sr': CaptionTier.excellent, 'bs': CaptionTier.excellent,
    'mk': CaptionTier.excellent, 'is': CaptionTier.excellent,
    'ga': CaptionTier.basic, 'cy': CaptionTier.excellent,
    'mt': CaptionTier.excellent, 'lb': CaptionTier.good, 'sq': CaptionTier.good,
    'be': CaptionTier.excellent, 'he': CaptionTier.excellent,
    'fa': CaptionTier.excellent, 'ps': CaptionTier.good,
    'ku': CaptionTier.basic, 'vi': CaptionTier.excellent,
    'th': CaptionTier.excellent, 'id': CaptionTier.good,
    'ms': CaptionTier.excellent, 'tl': CaptionTier.excellent,
    'km': CaptionTier.basic, 'lo': CaptionTier.none, 'my': CaptionTier.basic,
    'sw': CaptionTier.excellent, 'yo': CaptionTier.basic,
    'ig': CaptionTier.good, 'ha': CaptionTier.good, 'zu': CaptionTier.basic,
    'xh': CaptionTier.good, 'af': CaptionTier.excellent, 'st': CaptionTier.none,
    'tn': CaptionTier.none, 'sn': CaptionTier.basic, 'am': CaptionTier.none,
    'so': CaptionTier.good, 'rw': CaptionTier.basic, 'mg': CaptionTier.good,
    'ny': CaptionTier.none, 'ee': CaptionTier.none, 'tw': CaptionTier.none,
    'gaa': CaptionTier.none, 'ka': CaptionTier.good, 'hy': CaptionTier.good,
    'az': CaptionTier.excellent, 'eu': CaptionTier.good,
    'gl': CaptionTier.excellent, 'ca': CaptionTier.excellent,
    'la': CaptionTier.good, 'eo': CaptionTier.excellent,
    'kk': CaptionTier.excellent, 'tg': CaptionTier.good,
    'ky': CaptionTier.excellent, 'tk': CaptionTier.good, 'mn': CaptionTier.good,
    'uz': CaptionTier.excellent,
  },
  'groq:openai/gpt-oss-20b': {
    'en': CaptionTier.excellent, 'es': CaptionTier.good,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.good,
    'ru': CaptionTier.excellent, 'zh': CaptionTier.excellent,
    'ja': CaptionTier.good, 'ko': CaptionTier.excellent,
    'ar': CaptionTier.excellent, 'hi': CaptionTier.excellent,
    'bn': CaptionTier.excellent, 'pa': CaptionTier.excellent,
    'te': CaptionTier.excellent, 'mr': CaptionTier.excellent,
    'ta': CaptionTier.good, 'ur': CaptionTier.good, 'gu': CaptionTier.excellent,
    'kn': CaptionTier.excellent, 'ml': CaptionTier.excellent,
    'ne': CaptionTier.excellent, 'si': CaptionTier.good,
    'nl': CaptionTier.excellent, 'pl': CaptionTier.basic,
    'tr': CaptionTier.basic, 'cs': CaptionTier.excellent,
    'el': CaptionTier.excellent, 'hu': CaptionTier.excellent,
    'ro': CaptionTier.excellent, 'sv': CaptionTier.excellent,
    'da': CaptionTier.excellent, 'fi': CaptionTier.excellent,
    'no': CaptionTier.excellent, 'sk': CaptionTier.good,
    'uk': CaptionTier.excellent, 'bg': CaptionTier.excellent,
    'hr': CaptionTier.good, 'et': CaptionTier.basic, 'lt': CaptionTier.good,
    'lv': CaptionTier.basic, 'sl': CaptionTier.excellent,
    'sr': CaptionTier.excellent, 'bs': CaptionTier.excellent,
    'mk': CaptionTier.good, 'is': CaptionTier.excellent, 'ga': CaptionTier.none,
    'cy': CaptionTier.none, 'mt': CaptionTier.basic, 'lb': CaptionTier.none,
    'sq': CaptionTier.good, 'be': CaptionTier.good, 'he': CaptionTier.good,
    'fa': CaptionTier.excellent, 'ps': CaptionTier.good, 'ku': CaptionTier.none,
    'vi': CaptionTier.good, 'th': CaptionTier.good, 'id': CaptionTier.excellent,
    'ms': CaptionTier.excellent, 'tl': CaptionTier.basic,
    'km': CaptionTier.none, 'lo': CaptionTier.none, 'my': CaptionTier.none,
    'sw': CaptionTier.good, 'yo': CaptionTier.basic, 'ig': CaptionTier.good,
    'ha': CaptionTier.none, 'zu': CaptionTier.basic, 'xh': CaptionTier.basic,
    'af': CaptionTier.excellent, 'st': CaptionTier.none, 'tn': CaptionTier.none,
    'sn': CaptionTier.basic, 'am': CaptionTier.none, 'so': CaptionTier.none,
    'rw': CaptionTier.basic, 'mg': CaptionTier.basic, 'ny': CaptionTier.none,
    'ee': CaptionTier.none, 'tw': CaptionTier.none, 'gaa': CaptionTier.none,
    'ka': CaptionTier.good, 'hy': CaptionTier.good, 'az': CaptionTier.good,
    'eu': CaptionTier.good, 'gl': CaptionTier.good, 'ca': CaptionTier.excellent,
    'la': CaptionTier.basic, 'eo': CaptionTier.good,
    'kk': CaptionTier.excellent, 'tg': CaptionTier.none,
    'ky': CaptionTier.excellent, 'tk': CaptionTier.basic,
    'mn': CaptionTier.none, 'uz': CaptionTier.basic,
  },
  'groq:openai/gpt-oss-20b:low': {
    'en': CaptionTier.excellent, 'es': CaptionTier.excellent,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.good, 'ru': CaptionTier.good,
    'zh': CaptionTier.excellent, 'ja': CaptionTier.excellent,
    'ko': CaptionTier.good, 'ar': CaptionTier.good, 'hi': CaptionTier.excellent,
    'bn': CaptionTier.good, 'pa': CaptionTier.good, 'te': CaptionTier.excellent,
    'mr': CaptionTier.excellent, 'ta': CaptionTier.good,
    'ur': CaptionTier.excellent, 'gu': CaptionTier.excellent,
    'kn': CaptionTier.excellent, 'ml': CaptionTier.excellent,
    'ne': CaptionTier.excellent, 'si': CaptionTier.good,
    'nl': CaptionTier.excellent, 'pl': CaptionTier.basic,
    'tr': CaptionTier.basic, 'cs': CaptionTier.excellent,
    'el': CaptionTier.good, 'hu': CaptionTier.excellent, 'ro': CaptionTier.good,
    'sv': CaptionTier.excellent, 'da': CaptionTier.excellent,
    'fi': CaptionTier.good, 'no': CaptionTier.excellent, 'sk': CaptionTier.good,
    'uk': CaptionTier.excellent, 'bg': CaptionTier.excellent,
    'hr': CaptionTier.excellent, 'et': CaptionTier.good, 'lt': CaptionTier.good,
    'lv': CaptionTier.basic, 'sl': CaptionTier.good,
    'sr': CaptionTier.excellent, 'bs': CaptionTier.excellent,
    'mk': CaptionTier.excellent, 'is': CaptionTier.basic,
    'ga': CaptionTier.none, 'cy': CaptionTier.basic, 'mt': CaptionTier.basic,
    'lb': CaptionTier.good, 'sq': CaptionTier.good, 'be': CaptionTier.excellent,
    'he': CaptionTier.good, 'fa': CaptionTier.good, 'ps': CaptionTier.basic,
    'ku': CaptionTier.none, 'vi': CaptionTier.good, 'th': CaptionTier.good,
    'id': CaptionTier.good, 'ms': CaptionTier.excellent,
    'tl': CaptionTier.excellent, 'km': CaptionTier.none, 'lo': CaptionTier.none,
    'my': CaptionTier.none, 'sw': CaptionTier.basic, 'yo': CaptionTier.none,
    'ig': CaptionTier.good, 'ha': CaptionTier.none, 'zu': CaptionTier.basic,
    'xh': CaptionTier.none, 'af': CaptionTier.good, 'st': CaptionTier.none,
    'tn': CaptionTier.none, 'sn': CaptionTier.basic, 'am': CaptionTier.none,
    'so': CaptionTier.basic, 'rw': CaptionTier.none, 'mg': CaptionTier.good,
    'ny': CaptionTier.none, 'ee': CaptionTier.none, 'tw': CaptionTier.none,
    'gaa': CaptionTier.none, 'ka': CaptionTier.basic, 'hy': CaptionTier.good,
    'az': CaptionTier.good, 'eu': CaptionTier.basic, 'gl': CaptionTier.basic,
    'ca': CaptionTier.good, 'la': CaptionTier.none, 'eo': CaptionTier.good,
    'kk': CaptionTier.excellent, 'tg': CaptionTier.none, 'ky': CaptionTier.good,
    'tk': CaptionTier.good, 'mn': CaptionTier.none, 'uz': CaptionTier.good,
  },
  'groq:openai/gpt-oss-120b:low': {
    'en': CaptionTier.excellent, 'es': CaptionTier.excellent,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.excellent,
    'ru': CaptionTier.excellent, 'zh': CaptionTier.good, 'ja': CaptionTier.good,
    'ko': CaptionTier.excellent, 'ar': CaptionTier.excellent,
    'hi': CaptionTier.excellent, 'bn': CaptionTier.excellent,
    'pa': CaptionTier.basic, 'te': CaptionTier.excellent,
    'mr': CaptionTier.excellent, 'ta': CaptionTier.good, 'ur': CaptionTier.good,
    'gu': CaptionTier.excellent, 'kn': CaptionTier.excellent,
    'ml': CaptionTier.excellent, 'ne': CaptionTier.excellent,
    'si': CaptionTier.good, 'nl': CaptionTier.excellent,
    'pl': CaptionTier.excellent, 'tr': CaptionTier.excellent,
    'cs': CaptionTier.excellent, 'el': CaptionTier.excellent,
    'hu': CaptionTier.excellent, 'ro': CaptionTier.good,
    'sv': CaptionTier.excellent, 'da': CaptionTier.excellent,
    'fi': CaptionTier.excellent, 'no': CaptionTier.good,
    'sk': CaptionTier.excellent, 'uk': CaptionTier.excellent,
    'bg': CaptionTier.excellent, 'hr': CaptionTier.excellent,
    'et': CaptionTier.excellent, 'lt': CaptionTier.excellent,
    'lv': CaptionTier.excellent, 'sl': CaptionTier.excellent,
    'sr': CaptionTier.excellent, 'bs': CaptionTier.excellent,
    'mk': CaptionTier.good, 'is': CaptionTier.good, 'ga': CaptionTier.none,
    'cy': CaptionTier.good, 'mt': CaptionTier.good, 'lb': CaptionTier.good,
    'sq': CaptionTier.good, 'be': CaptionTier.good, 'he': CaptionTier.excellent,
    'fa': CaptionTier.excellent, 'ps': CaptionTier.good, 'ku': CaptionTier.none,
    'vi': CaptionTier.basic, 'th': CaptionTier.excellent,
    'id': CaptionTier.excellent, 'ms': CaptionTier.excellent,
    'tl': CaptionTier.basic, 'km': CaptionTier.none, 'lo': CaptionTier.none,
    'my': CaptionTier.none, 'sw': CaptionTier.good, 'yo': CaptionTier.good,
    'ig': CaptionTier.basic, 'ha': CaptionTier.good, 'zu': CaptionTier.basic,
    'xh': CaptionTier.basic, 'af': CaptionTier.excellent,
    'st': CaptionTier.none, 'tn': CaptionTier.none, 'sn': CaptionTier.basic,
    'am': CaptionTier.none, 'so': CaptionTier.basic, 'rw': CaptionTier.good,
    'mg': CaptionTier.basic, 'ny': CaptionTier.none, 'ee': CaptionTier.none,
    'tw': CaptionTier.none, 'gaa': CaptionTier.none, 'ka': CaptionTier.good,
    'hy': CaptionTier.basic, 'az': CaptionTier.excellent,
    'eu': CaptionTier.none, 'gl': CaptionTier.excellent,
    'ca': CaptionTier.excellent, 'la': CaptionTier.good,
    'eo': CaptionTier.excellent, 'kk': CaptionTier.excellent,
    'tg': CaptionTier.basic, 'ky': CaptionTier.good, 'tk': CaptionTier.basic,
    'mn': CaptionTier.good, 'uz': CaptionTier.good,
  },
  'gemini:gemini-2.5-flash-lite': {
    'en': CaptionTier.excellent, 'es': CaptionTier.excellent,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.excellent,
    'ru': CaptionTier.excellent, 'zh': CaptionTier.excellent,
    'ja': CaptionTier.good, 'ko': CaptionTier.excellent,
    'ar': CaptionTier.excellent, 'hi': CaptionTier.excellent,
    'bn': CaptionTier.good, 'pa': CaptionTier.basic, 'te': CaptionTier.good,
    'mr': CaptionTier.excellent, 'ta': CaptionTier.excellent,
    'ur': CaptionTier.good, 'gu': CaptionTier.excellent, 'kn': CaptionTier.good,
    'ml': CaptionTier.good, 'ne': CaptionTier.excellent, 'si': CaptionTier.good,
    'nl': CaptionTier.excellent, 'pl': CaptionTier.excellent,
    'tr': CaptionTier.excellent, 'cs': CaptionTier.excellent,
    'el': CaptionTier.excellent, 'hu': CaptionTier.excellent,
    'ro': CaptionTier.good, 'sv': CaptionTier.excellent,
    'da': CaptionTier.excellent, 'fi': CaptionTier.excellent,
    'no': CaptionTier.excellent, 'sk': CaptionTier.excellent,
    'uk': CaptionTier.excellent, 'bg': CaptionTier.excellent,
    'hr': CaptionTier.excellent, 'et': CaptionTier.good,
    'lt': CaptionTier.excellent, 'lv': CaptionTier.excellent,
    'sl': CaptionTier.good, 'sr': CaptionTier.excellent, 'bs': CaptionTier.good,
    'mk': CaptionTier.excellent, 'is': CaptionTier.good,
    'ga': CaptionTier.excellent, 'cy': CaptionTier.excellent,
    'mt': CaptionTier.excellent, 'lb': CaptionTier.excellent,
    'sq': CaptionTier.excellent, 'be': CaptionTier.excellent,
    'he': CaptionTier.excellent, 'fa': CaptionTier.excellent,
    'ps': CaptionTier.good, 'ku': CaptionTier.good, 'vi': CaptionTier.good,
    'th': CaptionTier.excellent, 'id': CaptionTier.excellent,
    'ms': CaptionTier.good, 'tl': CaptionTier.good, 'km': CaptionTier.good,
    'lo': CaptionTier.good, 'my': CaptionTier.excellent, 'sw': CaptionTier.good,
    'yo': CaptionTier.none, 'ig': CaptionTier.good, 'ha': CaptionTier.excellent,
    'zu': CaptionTier.basic, 'xh': CaptionTier.good,
    'af': CaptionTier.excellent, 'st': CaptionTier.basic,
    'tn': CaptionTier.none, 'sn': CaptionTier.basic, 'am': CaptionTier.basic,
    'so': CaptionTier.basic, 'rw': CaptionTier.basic, 'mg': CaptionTier.good,
    'ny': CaptionTier.none, 'ee': CaptionTier.none, 'tw': CaptionTier.none,
    'gaa': CaptionTier.none, 'ka': CaptionTier.good, 'hy': CaptionTier.good,
    'az': CaptionTier.excellent, 'eu': CaptionTier.basic,
    'gl': CaptionTier.excellent, 'ca': CaptionTier.excellent,
    'la': CaptionTier.excellent, 'eo': CaptionTier.excellent,
    'kk': CaptionTier.excellent, 'tg': CaptionTier.excellent,
    'ky': CaptionTier.excellent, 'tk': CaptionTier.excellent,
    'mn': CaptionTier.excellent, 'uz': CaptionTier.excellent,
  },
  'gemini:gemini-3.5-flash-lite': {
    'en': CaptionTier.excellent, 'es': CaptionTier.excellent,
    'fr': CaptionTier.excellent, 'de': CaptionTier.excellent,
    'it': CaptionTier.excellent, 'pt': CaptionTier.excellent,
    'ru': CaptionTier.excellent, 'zh': CaptionTier.good,
    'ja': CaptionTier.excellent, 'ko': CaptionTier.excellent,
    'ar': CaptionTier.excellent, 'hi': CaptionTier.excellent,
    'bn': CaptionTier.good, 'pa': CaptionTier.excellent,
    'te': CaptionTier.excellent, 'mr': CaptionTier.good, 'ta': CaptionTier.good,
    'ur': CaptionTier.excellent, 'gu': CaptionTier.excellent,
    'kn': CaptionTier.excellent, 'ml': CaptionTier.excellent,
    'ne': CaptionTier.excellent, 'si': CaptionTier.excellent,
    'nl': CaptionTier.excellent, 'pl': CaptionTier.excellent,
    'tr': CaptionTier.excellent, 'cs': CaptionTier.excellent,
    'el': CaptionTier.excellent, 'hu': CaptionTier.excellent,
    'ro': CaptionTier.excellent, 'sv': CaptionTier.excellent,
    'da': CaptionTier.excellent, 'fi': CaptionTier.excellent,
    'no': CaptionTier.excellent, 'sk': CaptionTier.excellent,
    'uk': CaptionTier.excellent, 'bg': CaptionTier.excellent,
    'hr': CaptionTier.excellent, 'et': CaptionTier.excellent,
    'lt': CaptionTier.excellent, 'lv': CaptionTier.excellent,
    'sl': CaptionTier.excellent, 'sr': CaptionTier.excellent,
    'bs': CaptionTier.excellent, 'mk': CaptionTier.excellent,
    'is': CaptionTier.excellent, 'ga': CaptionTier.excellent,
    'cy': CaptionTier.excellent, 'mt': CaptionTier.excellent,
    'lb': CaptionTier.good, 'sq': CaptionTier.excellent,
    'be': CaptionTier.excellent, 'he': CaptionTier.excellent,
    'fa': CaptionTier.excellent, 'ps': CaptionTier.good,
    'ku': CaptionTier.excellent, 'vi': CaptionTier.excellent,
    'th': CaptionTier.good, 'id': CaptionTier.excellent, 'ms': CaptionTier.good,
    'tl': CaptionTier.good, 'km': CaptionTier.good, 'lo': CaptionTier.excellent,
    'my': CaptionTier.excellent, 'sw': CaptionTier.good, 'yo': CaptionTier.good,
    'ig': CaptionTier.good, 'ha': CaptionTier.excellent, 'zu': CaptionTier.good,
    'xh': CaptionTier.excellent, 'af': CaptionTier.excellent,
    'st': CaptionTier.basic, 'tn': CaptionTier.basic,
    'sn': CaptionTier.excellent, 'am': CaptionTier.basic,
    'so': CaptionTier.excellent, 'rw': CaptionTier.basic,
    'mg': CaptionTier.good, 'ny': CaptionTier.good, 'ee': CaptionTier.none,
    'tw': CaptionTier.none, 'gaa': CaptionTier.none,
    'ka': CaptionTier.excellent, 'hy': CaptionTier.excellent,
    'az': CaptionTier.excellent, 'eu': CaptionTier.excellent,
    'gl': CaptionTier.excellent, 'ca': CaptionTier.excellent,
    'la': CaptionTier.excellent, 'eo': CaptionTier.excellent,
    'kk': CaptionTier.excellent, 'tg': CaptionTier.excellent,
    'ky': CaptionTier.good, 'tk': CaptionTier.excellent,
    'mn': CaptionTier.excellent, 'uz': CaptionTier.excellent,
  },
};

// Voice rows: tier name, then gender set key (empty when the route lists no genders).
const Map<String, Map<String, List<String>>> _ttsRows = {
  'default': {
    'en': ['natural', 'fm'], 'es': ['natural', 'fm'], 'fr': ['natural', 'fm'],
    'de': ['natural', 'fm'], 'it': ['natural', 'fm'], 'pt': ['natural', 'fm'],
    'ru': ['natural', 'fm'], 'zh': ['natural', 'fm'], 'ja': ['natural', 'fm'],
    'ko': ['natural', 'fm'], 'ar': ['natural', 'fm'], 'hi': ['natural', 'fm'],
    'bn': ['natural', 'fm'], 'pa': ['natural', 'fm'], 'te': ['natural', 'fm'],
    'mr': ['natural', 'fm'], 'ta': ['basic', 'fm'], 'ur': ['natural', 'fm'],
    'gu': ['natural', 'fm'], 'kn': ['natural', 'fm'], 'ml': ['basic', 'f'],
    'ne': ['none', ''], 'si': ['unknown', ''], 'nl': ['natural', 'fm'],
    'pl': ['natural', 'fm'], 'tr': ['natural', 'fm'], 'cs': ['natural', 'fm'],
    'el': ['natural', 'fm'], 'hu': ['natural', 'fm'], 'ro': ['basic', ''],
    'sv': ['natural', 'fm'], 'da': ['natural', 'fm'], 'fi': ['natural', 'fm'],
    'no': ['natural', 'fm'], 'sk': ['natural', 'm'], 'uk': ['none', ''],
    'bg': ['basic', ''], 'hr': ['natural', 'fm'], 'et': ['natural', 'fm'],
    'lt': ['basic', ''], 'lv': ['natural', 'fm'], 'sl': ['basic', ''],
    'sr': ['natural', 'fm'], 'bs': ['basic', ''], 'mk': ['none', ''],
    'is': ['none', ''], 'ga': ['none', ''], 'cy': ['basic', ''],
    'mt': ['none', ''], 'lb': ['none', ''], 'sq': ['basic', ''],
    'be': ['basic', ''], 'he': ['basic', 'fm'], 'fa': ['natural', 'fm'],
    'ps': ['basic', ''], 'ku': ['none', ''], 'vi': ['none', ''],
    'th': ['natural', 'fm'], 'id': ['natural', 'fm'], 'ms': ['natural', 'fm'],
    'tl': ['natural', 'fm'], 'km': ['none', ''], 'lo': ['none', ''],
    'my': ['none', ''], 'sw': ['natural', 'fm'], 'yo': ['basic', ''],
    'ig': ['none', ''], 'ha': ['none', ''], 'zu': ['none', ''],
    'xh': ['none', ''], 'af': ['basic', 'fm'], 'st': ['none', ''],
    'tn': ['none', ''], 'sn': ['basic', ''], 'am': ['none', ''],
    'so': ['none', ''], 'rw': ['none', ''], 'mg': ['none', ''],
    'ny': ['none', ''], 'ee': ['none', ''], 'tw': ['none', ''],
    'gaa': ['none', ''], 'ka': ['basic', ''], 'hy': ['basic', ''],
    'az': ['basic', 'fm'], 'eu': ['basic', ''], 'gl': ['basic', ''],
    'ca': ['natural', 'fm'], 'la': ['basic', ''], 'eo': ['none', ''],
    'kk': ['basic', ''], 'tg': ['none', ''], 'ky': ['none', ''],
    'tk': ['none', ''], 'mn': ['basic', ''], 'uz': ['none', ''],
  },
  'openai:gpt-4o-mini-tts': {
    'en': ['basic', 'fm'], 'es': ['basic', 'fm'], 'fr': ['basic', 'fm'],
    'de': ['basic', 'fm'], 'it': ['basic', 'fm'], 'pt': ['basic', 'fm'],
    'ru': ['basic', 'fm'], 'zh': ['basic', 'fm'], 'ja': ['basic', 'fm'],
    'ko': ['basic', 'fm'], 'ar': ['basic', 'fm'], 'hi': ['basic', 'fm'],
    'bn': ['none', ''], 'pa': ['none', ''], 'te': ['none', ''],
    'mr': ['basic', 'fm'], 'ta': ['basic', 'fm'], 'ur': ['basic', 'fm'],
    'gu': ['none', ''], 'kn': ['basic', 'fm'], 'ml': ['none', ''],
    'ne': ['basic', 'fm'], 'si': ['none', ''], 'nl': ['basic', 'fm'],
    'pl': ['basic', 'fm'], 'tr': ['basic', 'fm'], 'cs': ['basic', 'fm'],
    'el': ['basic', 'fm'], 'hu': ['basic', 'fm'], 'ro': ['basic', 'fm'],
    'sv': ['basic', 'fm'], 'da': ['basic', 'fm'], 'fi': ['basic', 'fm'],
    'no': ['basic', 'fm'], 'sk': ['basic', 'fm'], 'uk': ['basic', 'fm'],
    'bg': ['basic', 'fm'], 'hr': ['basic', 'fm'], 'et': ['basic', 'fm'],
    'lt': ['basic', 'fm'], 'lv': ['basic', 'fm'], 'sl': ['basic', 'fm'],
    'sr': ['basic', 'fm'], 'bs': ['basic', 'fm'], 'mk': ['basic', 'fm'],
    'is': ['basic', 'fm'], 'ga': ['none', ''], 'cy': ['basic', 'fm'],
    'mt': ['none', ''], 'lb': ['none', ''], 'sq': ['none', ''],
    'be': ['none', 'fm'], 'he': ['basic', 'fm'], 'fa': ['basic', 'fm'],
    'ps': ['none', ''], 'ku': ['none', ''], 'vi': ['basic', 'fm'],
    'th': ['basic', 'fm'], 'id': ['basic', 'fm'], 'ms': ['basic', 'fm'],
    'tl': ['basic', 'fm'], 'km': ['none', ''], 'lo': ['none', ''],
    'my': ['none', ''], 'sw': ['basic', 'fm'], 'yo': ['none', ''],
    'ig': ['none', ''], 'ha': ['none', ''], 'zu': ['none', ''],
    'xh': ['none', ''], 'af': ['basic', 'fm'], 'st': ['none', ''],
    'tn': ['none', ''], 'sn': ['none', ''], 'am': ['none', ''],
    'so': ['none', ''], 'rw': ['none', ''], 'mg': ['none', ''],
    'ny': ['none', ''], 'ee': ['none', ''], 'tw': ['none', ''],
    'gaa': ['none', ''], 'ka': ['none', ''], 'hy': ['basic', 'fm'],
    'az': ['basic', 'fm'], 'eu': ['none', ''], 'gl': ['basic', 'fm'],
    'ca': ['basic', 'fm'], 'la': ['none', ''], 'eo': ['none', ''],
    'kk': ['basic', 'fm'], 'tg': ['none', ''], 'ky': ['none', ''],
    'tk': ['none', ''], 'mn': ['none', ''], 'uz': ['none', ''],
  },
  'elevenlabs:eleven_flash_v2_5': {
    'en': ['basic', 'fm'], 'es': ['basic', 'fm'], 'fr': ['basic', 'fm'],
    'de': ['basic', 'fm'], 'it': ['basic', 'fm'], 'pt': ['basic', 'fm'],
    'ru': ['basic', 'fm'], 'zh': ['none', 'fm'], 'ja': ['basic', 'fm'],
    'ko': ['basic', 'fm'], 'ar': ['basic', 'fm'], 'hi': ['basic', 'fm'],
    'bn': ['none', ''], 'pa': ['none', ''], 'te': ['none', ''],
    'mr': ['none', ''], 'ta': ['basic', 'fm'], 'ur': ['none', ''],
    'gu': ['none', ''], 'kn': ['none', ''], 'ml': ['none', ''],
    'ne': ['none', ''], 'si': ['none', ''], 'nl': ['basic', 'fm'],
    'pl': ['basic', 'fm'], 'tr': ['basic', 'fm'], 'cs': ['basic', 'fm'],
    'el': ['basic', 'fm'], 'hu': ['basic', 'fm'], 'ro': ['basic', 'fm'],
    'sv': ['basic', 'fm'], 'da': ['basic', 'fm'], 'fi': ['basic', 'fm'],
    'no': ['basic', 'fm'], 'sk': ['basic', 'fm'], 'uk': ['basic', 'fm'],
    'bg': ['basic', 'fm'], 'hr': ['basic', 'fm'], 'et': ['none', ''],
    'lt': ['none', ''], 'lv': ['none', ''], 'sl': ['none', ''],
    'sr': ['none', ''], 'bs': ['none', ''], 'mk': ['none', ''],
    'is': ['none', ''], 'ga': ['none', ''], 'cy': ['none', ''],
    'mt': ['none', ''], 'lb': ['none', ''], 'sq': ['none', ''],
    'be': ['none', ''], 'he': ['none', ''], 'fa': ['none', ''],
    'ps': ['none', ''], 'ku': ['none', ''], 'vi': ['basic', 'fm'],
    'th': ['none', ''], 'id': ['basic', 'fm'], 'ms': ['basic', 'fm'],
    'tl': ['basic', 'fm'], 'km': ['none', ''], 'lo': ['none', ''],
    'my': ['none', ''], 'sw': ['none', ''], 'yo': ['none', ''],
    'ig': ['none', ''], 'ha': ['none', ''], 'zu': ['none', ''],
    'xh': ['none', ''], 'af': ['none', ''], 'st': ['none', ''],
    'tn': ['none', ''], 'sn': ['none', ''], 'am': ['none', ''],
    'so': ['none', ''], 'rw': ['none', ''], 'mg': ['none', ''],
    'ny': ['none', ''], 'ee': ['none', ''], 'tw': ['none', ''],
    'gaa': ['none', ''], 'ka': ['none', ''], 'hy': ['none', ''],
    'az': ['none', ''], 'eu': ['none', ''], 'gl': ['none', ''],
    'ca': ['none', ''], 'la': ['none', ''], 'eo': ['none', ''],
    'kk': ['none', ''], 'tg': ['none', ''], 'ky': ['none', ''],
    'tk': ['none', ''], 'mn': ['none', ''], 'uz': ['none', ''],
  },
  'google:cloud-tts': {
    'en': ['natural', 'fm'], 'es': ['natural', 'fm'], 'fr': ['natural', 'fm'],
    'de': ['natural', 'fm'], 'it': ['natural', 'fm'], 'pt': ['natural', 'fm'],
    'ru': ['natural', 'fm'], 'zh': ['natural', 'fm'], 'ja': ['natural', 'fm'],
    'ko': ['natural', 'fm'], 'ar': ['natural', 'fm'], 'hi': ['natural', 'fm'],
    'bn': ['natural', 'fm'], 'pa': ['natural', 'fm'], 'te': ['natural', 'fm'],
    'mr': ['natural', 'fm'], 'ta': ['natural', 'fm'], 'ur': ['natural', 'fm'],
    'gu': ['natural', 'fm'], 'kn': ['natural', 'fm'], 'ml': ['natural', 'fm'],
    'ne': ['none', ''], 'si': ['none', ''], 'nl': ['natural', 'fm'],
    'pl': ['natural', 'fm'], 'tr': ['natural', 'fm'], 'cs': ['natural', 'fm'],
    'el': ['natural', 'fm'], 'hu': ['natural', 'fm'], 'ro': ['natural', 'fm'],
    'sv': ['basic', 'fm'], 'da': ['natural', 'fm'], 'fi': ['natural', 'fm'],
    'no': ['natural', 'fm'], 'sk': ['natural', 'fm'], 'uk': ['natural', 'fm'],
    'bg': ['natural', 'fm'], 'hr': ['natural', 'fm'], 'et': ['natural', 'fm'],
    'lt': ['natural', 'fm'], 'lv': ['natural', 'fm'], 'sl': ['natural', 'fm'],
    'sr': ['natural', 'fm'], 'bs': ['none', ''], 'mk': ['none', ''],
    'is': ['natural', 'f'], 'ga': ['none', ''], 'cy': ['none', ''],
    'mt': ['none', ''], 'lb': ['none', ''], 'sq': ['none', ''],
    'be': ['none', ''], 'he': ['natural', 'fm'], 'fa': ['none', ''],
    'ps': ['none', ''], 'ku': ['none', ''], 'vi': ['natural', 'fm'],
    'th': ['natural', 'fm'], 'id': ['natural', 'fm'], 'ms': ['natural', 'fm'],
    'tl': ['natural', 'fm'], 'km': ['none', ''], 'lo': ['none', ''],
    'my': ['none', ''], 'sw': ['natural', 'fm'], 'yo': ['none', ''],
    'ig': ['none', ''], 'ha': ['none', ''], 'zu': ['none', ''],
    'xh': ['none', ''], 'af': ['natural', 'f'], 'st': ['none', ''],
    'tn': ['none', ''], 'sn': ['none', ''], 'am': ['basic', 'fm'],
    'so': ['none', ''], 'rw': ['none', ''], 'mg': ['none', ''],
    'ny': ['none', ''], 'ee': ['none', ''], 'tw': ['none', ''],
    'gaa': ['none', ''], 'ka': ['none', ''], 'hy': ['none', ''],
    'az': ['none', ''], 'eu': ['basic', 'f'], 'gl': ['natural', 'f'],
    'ca': ['natural', 'f'], 'la': ['none', ''], 'eo': ['none', ''],
    'kk': ['none', ''], 'tg': ['none', ''], 'ky': ['none', ''],
    'tk': ['none', ''], 'mn': ['none', ''], 'uz': ['none', ''],
  },
};

/// Languages that automatic language detection recognises reliably (rated good or better).
const List<String> autoDetectLanguages = [
  'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'hi', 'nl', 'pl',
  'tr', 'cs', 'el', 'hu', 'sv', 'fi', 'no', 'sk', 'uk', 'bg', 'et', 'lt', 'lv',
  'vi', 'th', 'id', 'ms',
];

const Map<String, Map<String, String>> _providerAliases = {
  'stt': {'deepgram': 'deepgram:nova-3', 'nova-3': 'deepgram:nova-3', 'gpt-4o-transcribe': 'openai:gpt-4o-transcribe'},
  'llm': {'gpt-4o-mini': 'openai:gpt-4o-mini', 'gpt-oss-20b': 'groq:openai/gpt-oss-20b', 'openai/gpt-oss-20b': 'groq:openai/gpt-oss-20b', 'gemini-3.5-flash-lite': 'gemini:gemini-3.5-flash-lite', 'gemini-2.5-flash-lite': 'gemini:gemini-2.5-flash-lite'},
  'tts': {'system': 'default', 'mediasfu': 'default', 'gpt-4o-mini-tts': 'openai:gpt-4o-mini-tts', 'eleven_flash_v2_5': 'elevenlabs:eleven_flash_v2_5'},
};

const String _presetTtsRouteDefault = 'fish:s2.1-pro';
const Map<String, String> _presetTtsRoutes = {
  'en': 'deepgram:aura-2', 'es': 'deepgram:aura-2', 'fr': 'deepgram:aura-2',
  'de': 'deepgram:aura-2', 'it': 'deepgram:aura-2', 'ja': 'deepgram:aura-2',
  'nl': 'deepgram:aura-2',
};

// Preset values that differ from composing the preset stack (normally empty).
// Keys: speak, captions, voice (tier names), genders (gender set key).
const Map<String, Map<String, Map<String, String>>> _presetOverrides = {
  'system': {},
  'demo': {},
};

Map<String, VoiceCapability> _voiceRows(Map<String, List<String>> rows) {
  final out = <String, VoiceCapability>{};
  rows.forEach((code, row) {
    final tier = VoiceTier.values.firstWhere((v) => v.name == row[0],
        orElse: () => VoiceTier.unknown);
    final genders = row.length > 1 ? _genderSets[row[1]] : null;
    out[code] = VoiceCapability(voice: tier, genders: genders);
  });
  return out;
}

/// Measured tiers per provider id, then language code.
final ProviderCapabilities providerCapabilities = ProviderCapabilities(
  stt: _sttCapabilities,
  llm: _llmCapabilities,
  tts: _ttsRows.map((id, rows) => MapEntry(id, _voiceRows(rows))),
);

String _normalizeCapabilityCode(String code) =>
    code.trim().toLowerCase().split(RegExp(r'[-_]')).first;

String? _resolveProviderId(String stage, String id, Iterable<String> known) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return null;
  if (known.contains(trimmed)) return trimmed;
  final alias = _providerAliases[stage]?[trimmed.toLowerCase()];
  return alias != null && known.contains(alias) ? alias : null;
}

LanguageCapability _unmeasuredCapability(LanguageCapabilityProviders providers) =>
    LanguageCapability(
      speak: SpeakTier.none,
      captions: CaptionTier.none,
      voice: VoiceTier.unknown,
      providers: providers,
      measuredAt: '',
    );

bool _isGoodCaptions(CaptionTier? tier) =>
    tier == CaptionTier.excellent || tier == CaptionTier.good;

/// Main LLM captions, unless they are below good and the fallback LLM's are good.
CaptionTier _withCaptionFallback(CaptionTier main, CaptionTier? fallback) =>
    !_isGoodCaptions(main) && _isGoodCaptions(fallback) ? fallback! : main;

Map<String, LanguageCapability> _buildPreset(String preset) {
  final stack = languageCapabilityPresetStacks[preset]!;
  final overrides = _presetOverrides[preset] ?? const {};
  final out = <String, LanguageCapability>{};
  for (final code in measuredLanguageCodes) {
    final voice = providerCapabilities.tts[stack.tts]?[code];
    final o = overrides[code] ?? const <String, String>{};
    final speak = o['speak'] != null
        ? SpeakTier.values.firstWhere((v) => v.name == o['speak'], orElse: () => SpeakTier.none)
        : (providerCapabilities.stt[stack.stt]?[code] ?? SpeakTier.none);
    final captions = o['captions'] != null
        ? CaptionTier.values.firstWhere((v) => v.name == o['captions'], orElse: () => CaptionTier.none)
        : _withCaptionFallback(
            providerCapabilities.llm[stack.llm]?[code] ?? CaptionTier.none,
            stack.llmFallback == null
                ? null
                : (providerCapabilities.llm[stack.llmFallback!]?[code]),
          );
    final voiceTier = o['voice'] != null
        ? VoiceTier.values.firstWhere((v) => v.name == o['voice'], orElse: () => VoiceTier.unknown)
        : (voice?.voice ?? VoiceTier.unknown);
    final genders = o.containsKey('genders') ? _genderSets[o['genders']] : voice?.genders;
    out[code] = LanguageCapability(
      speak: speak,
      captions: captions,
      voice: voiceTier,
      voiceGenders: (genders == null || genders.isEmpty) ? null : genders,
      providers: LanguageCapabilityProviders(
        stt: stack.stt,
        llm: stack.llm,
        llmFallback: stack.llmFallback,
        tts: _presetTtsRoutes[code] ?? _presetTtsRouteDefault,
      ),
      measuredAt: languageCapabilitiesMeasuredAt,
    );
  }
  return out;
}

/// Ratings per managed preset ('system', 'demo'), then language code.
final Map<String, Map<String, LanguageCapability>> languageCapabilities = {
  'system': _buildPreset('system'),
  'demo': _buildPreset('demo'),
};

/// True when the language was part of the measurement.
bool isLanguageMeasured(String code) =>
    languageCapabilities['system']!.containsKey(_normalizeCapabilityCode(code));

/// Rating for a language on a managed preset (system by default) or on a custom provider stack.
/// For a custom stack, each stage uses the measured provider when known and the system preset otherwise.
/// An optional llmFallback supplies captions where the main LLM is below good and the fallback is good.
LanguageCapability getLanguageCapability(String code,
    [LanguageCapabilityStack stack = const LanguageCapabilityStack.system()]) {
  final normalized = _normalizeCapabilityCode(code);
  if (!stack.isCustom) {
    final preset = stack.preset == 'demo' ? 'demo' : 'system';
    return languageCapabilities[preset]![normalized] ??
        _unmeasuredCapability(languageCapabilityPresetStacks[preset]!);
  }
  final base = languageCapabilities['system']![normalized] ??
      _unmeasuredCapability(languageCapabilityPresetStacks['system']!);
  final stt = _resolveProviderId('stt', stack.stt, providerCapabilities.stt.keys);
  final llm = _resolveProviderId('llm', stack.llm, providerCapabilities.llm.keys);
  final llmFallback = stack.llmFallback != null
      ? _resolveProviderId('llm', stack.llmFallback!, providerCapabilities.llm.keys)
      : null;
  final tts = _resolveProviderId('tts', stack.tts, providerCapabilities.tts.keys);
  final speak = stt != null ? providerCapabilities.stt[stt]![normalized] : null;
  final mainCaptions = llm != null ? providerCapabilities.llm[llm]![normalized] : null;
  final fallbackCaptions =
      llmFallback != null ? providerCapabilities.llm[llmFallback]![normalized] : null;
  final voice = tts != null ? providerCapabilities.tts[tts]![normalized] : null;
  final genders = voice != null ? voice.genders : base.voiceGenders;
  final fallbackLabel = llmFallback != null
      ? stack.llmFallback
      : (mainCaptions != null ? null : base.providers.llmFallback);
  return LanguageCapability(
    speak: speak ?? base.speak,
    captions: _withCaptionFallback(mainCaptions ?? base.captions, fallbackCaptions),
    voice: voice?.voice ?? base.voice,
    voiceGenders: (genders == null || genders.isEmpty) ? null : genders,
    providers: LanguageCapabilityProviders(
      stt: speak != null ? stack.stt : base.providers.stt,
      llm: mainCaptions != null ? stack.llm : base.providers.llm,
      llmFallback: fallbackLabel,
      tts: voice != null ? stack.tts : base.providers.tts,
    ),
    measuredAt: base.measuredAt,
  );
}

/// Where a language belongs in a listener (translated language) picker.
ListenerGroup listenerGroup(LanguageCapability c) {
  if (c.captions == CaptionTier.excellent || c.captions == CaptionTier.good) {
    if (c.voice == VoiceTier.natural) return ListenerGroup.naturalVoice;
    if (c.voice == VoiceTier.basic) return ListenerGroup.captionsBasicVoice;
    return ListenerGroup.captionsOnly;
  }
  if (c.captions == CaptionTier.basic) return ListenerGroup.captionsPreview;
  return ListenerGroup.hidden;
}

/// Whether a language belongs in a speaker picker; [SpeakerListing.beta] languages are listed with a label.
SpeakerListing speakerListing(LanguageCapability c) {
  if (c.speak == SpeakTier.excellent || c.speak == SpeakTier.good) return SpeakerListing.yes;
  if (c.speak == SpeakTier.basic) return SpeakerListing.beta;
  return SpeakerListing.no;
}

/// True when automatic language detection recognises this language reliably.
bool supportsAutoDetect(String code) =>
    autoDetectLanguages.contains(_normalizeCapabilityCode(code));

/// Legacy single rating derived from a capability (matches languageMetadata ttsSupport for the system preset).
TTSSupport capabilityTtsSupport(LanguageCapability c) {
  switch (listenerGroup(c)) {
    case ListenerGroup.naturalVoice:
      return c.captions == CaptionTier.excellent ? TTSSupport.excellent : TTSSupport.good;
    case ListenerGroup.captionsBasicVoice:
      return TTSSupport.moderate;
    case ListenerGroup.captionsOnly:
      return TTSSupport.limited;
    default:
      return TTSSupport.unknown;
  }
}

const List<ListenerGroup> _listenerGroupOrder = [
  ListenerGroup.naturalVoice,
  ListenerGroup.captionsBasicVoice,
  ListenerGroup.captionsOnly,
  ListenerGroup.captionsPreview,
];

/// Groups listener languages in display order: natural voice, captions + basic voice, captions only, then
/// preview. Languages without usable captions are left out; languages outside the measurement go to preview.
List<ListenerLanguageGroup<T>> groupListenerLanguages<T>(
  List<T> languages,
  String Function(T) codeOf, [
  LanguageCapabilityStack stack = const LanguageCapabilityStack.system(),
]) {
  final buckets = <ListenerGroup, List<T>>{};
  for (final lang in languages) {
    final code = codeOf(lang);
    if (code == 'auto') continue;
    final group = isLanguageMeasured(code)
        ? listenerGroup(getLanguageCapability(code, stack))
        : ListenerGroup.captionsPreview;
    if (group == ListenerGroup.hidden) continue;
    buckets.putIfAbsent(group, () => <T>[]).add(lang);
  }
  return [
    for (final group in _listenerGroupOrder)
      if (buckets.containsKey(group))
        ListenerLanguageGroup<T>(
          group: group,
          label: listenerGroupLabels[group]!,
          note: listenerGroupNotes[group]!,
          languages: buckets[group]!,
        ),
  ];
}

/// Speaker listing for each language that transcribes well enough to list
/// ([SpeakerListing.yes] or [SpeakerListing.beta]); languages outside the measurement are marked beta.
List<MapEntry<T, SpeakerListing>> filterSpeakerLanguages<T>(
  List<T> languages,
  String Function(T) codeOf, [
  LanguageCapabilityStack stack = const LanguageCapabilityStack.system(),
]) {
  final out = <MapEntry<T, SpeakerListing>>[];
  for (final lang in languages) {
    final code = codeOf(lang);
    if (code == 'auto') continue;
    final listing = isLanguageMeasured(code)
        ? speakerListing(getLanguageCapability(code, stack))
        : SpeakerListing.beta;
    if (listing == SpeakerListing.no) continue;
    out.add(MapEntry(lang, listing));
  }
  return out;
}
