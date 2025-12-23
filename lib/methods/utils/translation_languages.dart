/// Central Language Definitions for Translation Pipeline (Frontend)
///
/// This module provides a single source of truth for all supported languages,
/// language codes, and voice configurations across the Flutter application.
///
/// Language Code Standards:
/// - ISO 639-1: 2-letter codes (e.g., 'en', 'es') - PRIMARY STANDARD
/// - ISO 639-2: 3-letter codes (e.g., 'eng', 'spa') - for extended languages
/// - BCP 47: Language tags with regions (e.g., 'en-US', 'pt-BR')
library;

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

// ============================================================================
// TYPES
// ============================================================================

/// Voice gender type
enum VoiceGender { male, female, neutral }

/// TTS support level
enum TTSSupport { excellent, good, moderate, limited, unknown, notApplicable }

/// Language region classification
enum LanguageRegion {
  global,
  europe,
  asia,
  southAsia,
  mena,
  africa,
  caucasus,
  centralAsia,
  constructed,
  special,
  other
}

/// Language metadata with display names and additional info
class LanguageMetadata {
  final String name;
  final String nativeName;
  final LanguageRegion region;
  final TTSSupport ttsSupport;

  const LanguageMetadata({
    required this.name,
    required this.nativeName,
    required this.region,
    required this.ttsSupport,
  });
}

/// Language option for dropdowns
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final TTSSupport ttsSupport;
  final LanguageRegion region;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.ttsSupport,
    required this.region,
  });

  factory LanguageOption.fromMap(Map<String, dynamic> map) {
    return LanguageOption(
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nativeName: map['nativeName'] as String? ?? '',
      ttsSupport: _parseTTSSupport(map['ttsSupport']),
      region: _parseRegion(map['region']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'ttsSupport': ttsSupport.name,
      'region': region.name,
    };
  }
}

/// Voice option for TTS
class VoiceOption {
  final String id;
  final String name;
  final VoiceGender gender;
  final String provider;
  final String language;
  final String? style;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.gender,
    required this.provider,
    required this.language,
    this.style,
  });

  factory VoiceOption.fromMap(Map<String, dynamic> map) {
    return VoiceOption(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      gender: _parseVoiceGender(map['gender']),
      provider: map['provider'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      style: map['style'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender.name,
      'provider': provider,
      'language': language,
      if (style != null) 'style': style,
    };
  }
}

/// Voice configuration for translation
class TranslationVoiceConfig {
  /// Basic Mode: Gender preference (simple selection)
  final VoiceGender? voiceGender;

  /// Advanced Mode: Explicit voice ID from provider
  final String? voiceId;

  /// Voice Cloning configuration (future feature)
  final VoiceCloneConfig? voiceClone;

  /// Pipeline nicknames (for custom STT/LLM/TTS providers)
  final String? sttNickName;
  final String? llmNickName;
  final String? ttsNickName;

  /// Pipeline params (provider-specific settings)
  final Map<String, dynamic>? sttParams;
  final Map<String, dynamic>? llmParams;
  final Map<String, dynamic>? ttsParams;

  const TranslationVoiceConfig({
    this.voiceGender,
    this.voiceId,
    this.voiceClone,
    this.sttNickName,
    this.llmNickName,
    this.ttsNickName,
    this.sttParams,
    this.llmParams,
    this.ttsParams,
  });

  factory TranslationVoiceConfig.fromMap(Map<String, dynamic> map) {
    return TranslationVoiceConfig(
      voiceGender: map['voiceGender'] != null
          ? _parseVoiceGender(map['voiceGender'])
          : null,
      voiceId: map['voiceId'] as String?,
      voiceClone: map['voiceClone'] != null
          ? VoiceCloneConfig.fromMap(map['voiceClone'] as Map<String, dynamic>)
          : null,
      sttNickName: map['sttNickName'] as String?,
      llmNickName: map['llmNickName'] as String?,
      ttsNickName: map['ttsNickName'] as String?,
      sttParams: map['sttParams'] as Map<String, dynamic>?,
      llmParams: map['llmParams'] as Map<String, dynamic>?,
      ttsParams: map['ttsParams'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (voiceGender != null) 'voiceGender': voiceGender!.name,
      if (voiceId != null) 'voiceId': voiceId,
      if (voiceClone != null) 'voiceClone': voiceClone!.toMap(),
      if (sttNickName != null) 'sttNickName': sttNickName,
      if (llmNickName != null) 'llmNickName': llmNickName,
      if (ttsNickName != null) 'ttsNickName': ttsNickName,
      if (sttParams != null) 'sttParams': sttParams,
      if (llmParams != null) 'llmParams': llmParams,
      if (ttsParams != null) 'ttsParams': ttsParams,
    };
  }
}

/// Voice clone configuration
class VoiceCloneConfig {
  final String provider; // 'elevenlabs' | 'playht' | 'coqui'
  final String voiceId;
  final double? stability;
  final double? similarity;

  const VoiceCloneConfig({
    required this.provider,
    required this.voiceId,
    this.stability,
    this.similarity,
  });

  factory VoiceCloneConfig.fromMap(Map<String, dynamic> map) {
    return VoiceCloneConfig(
      provider: map['provider'] as String? ?? 'elevenlabs',
      voiceId: map['voiceId'] as String? ?? '',
      stability: (map['stability'] as num?)?.toDouble(),
      similarity: (map['similarity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'voiceId': voiceId,
      if (stability != null) 'stability': stability,
      if (similarity != null) 'similarity': similarity,
    };
  }
}

/// Language entry with voice config override
class TranslationLanguageEntry {
  final String code;
  final String? nickname;
  final TranslationVoiceConfig? voiceConfig;

  const TranslationLanguageEntry({
    required this.code,
    this.nickname,
    this.voiceConfig,
  });

  factory TranslationLanguageEntry.fromMap(Map<String, dynamic> map) {
    return TranslationLanguageEntry(
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

// ============================================================================
// LANGUAGE DEFINITIONS
// ============================================================================

/// Complete list of supported language codes (ISO 639-1 primarily)
const List<String> supportedLanguageCodes = [
  // Major World Languages
  'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar',

  // South Asian Languages
  'hi', 'bn', 'pa', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'ml', 'ne', 'si',

  // European Languages
  'nl', 'pl', 'tr', 'cs', 'el', 'hu', 'ro', 'sv', 'da', 'fi', 'no', 'sk',
  'uk', 'bg', 'hr', 'et', 'lt', 'lv', 'sl', 'sr', 'bs', 'mk', 'is',
  'ga', 'cy', 'mt', 'lb', 'sq', 'be',

  // Middle Eastern Languages
  'he', 'fa', 'ps', 'ku',

  // Southeast Asian Languages
  'vi', 'th', 'id', 'ms', 'tl', 'km', 'lo', 'my',

  // African Languages
  'sw', 'yo', 'ig', 'ha', 'zu', 'xh', 'af', 'st', 'tn', 'sn', 'am', 'so', 'rw',
  'mg', 'ny',
  'ee', 'tw', 'gaa',

  // Caucasian Languages
  'ka', 'hy', 'az',

  // Regional European Languages
  'eu', 'gl', 'ca', 'la', 'eo',

  // Central Asian
  'kk', 'uz', 'tg', 'ky', 'tk', 'mn',

  // Special
  'auto',
];

/// Language metadata with display names and additional info
const Map<String, LanguageMetadata> languageMetadata = {
  // Major World Languages
  'en': LanguageMetadata(
      name: 'English',
      nativeName: 'English',
      region: LanguageRegion.global,
      ttsSupport: TTSSupport.excellent),
  'es': LanguageMetadata(
      name: 'Spanish',
      nativeName: 'Español',
      region: LanguageRegion.global,
      ttsSupport: TTSSupport.excellent),
  'fr': LanguageMetadata(
      name: 'French',
      nativeName: 'Français',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'de': LanguageMetadata(
      name: 'German',
      nativeName: 'Deutsch',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'it': LanguageMetadata(
      name: 'Italian',
      nativeName: 'Italiano',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'pt': LanguageMetadata(
      name: 'Portuguese',
      nativeName: 'Português',
      region: LanguageRegion.global,
      ttsSupport: TTSSupport.excellent),
  'ru': LanguageMetadata(
      name: 'Russian',
      nativeName: 'Русский',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'zh': LanguageMetadata(
      name: 'Chinese',
      nativeName: '中文',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.excellent),
  'ja': LanguageMetadata(
      name: 'Japanese',
      nativeName: '日本語',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.excellent),
  'ko': LanguageMetadata(
      name: 'Korean',
      nativeName: '한국어',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.excellent),
  'ar': LanguageMetadata(
      name: 'Arabic',
      nativeName: 'العربية',
      region: LanguageRegion.mena,
      ttsSupport: TTSSupport.excellent),

  // South Asian Languages
  'hi': LanguageMetadata(
      name: 'Hindi',
      nativeName: 'हिन्दी',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'bn': LanguageMetadata(
      name: 'Bengali',
      nativeName: 'বাংলা',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'pa': LanguageMetadata(
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.moderate),
  'te': LanguageMetadata(
      name: 'Telugu',
      nativeName: 'తెలుగు',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'mr': LanguageMetadata(
      name: 'Marathi',
      nativeName: 'मराठी',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'ta': LanguageMetadata(
      name: 'Tamil',
      nativeName: 'தமிழ்',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'ur': LanguageMetadata(
      name: 'Urdu',
      nativeName: 'اردو',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.good),
  'gu': LanguageMetadata(
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.moderate),
  'kn': LanguageMetadata(
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.moderate),
  'ml': LanguageMetadata(
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.moderate),
  'ne': LanguageMetadata(
      name: 'Nepali',
      nativeName: 'नेपाली',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.limited),
  'si': LanguageMetadata(
      name: 'Sinhala',
      nativeName: 'සිංහල',
      region: LanguageRegion.southAsia,
      ttsSupport: TTSSupport.limited),

  // European Languages
  'nl': LanguageMetadata(
      name: 'Dutch',
      nativeName: 'Nederlands',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'pl': LanguageMetadata(
      name: 'Polish',
      nativeName: 'Polski',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'tr': LanguageMetadata(
      name: 'Turkish',
      nativeName: 'Türkçe',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'cs': LanguageMetadata(
      name: 'Czech',
      nativeName: 'Čeština',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'el': LanguageMetadata(
      name: 'Greek',
      nativeName: 'Ελληνικά',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'hu': LanguageMetadata(
      name: 'Hungarian',
      nativeName: 'Magyar',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'ro': LanguageMetadata(
      name: 'Romanian',
      nativeName: 'Română',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'sv': LanguageMetadata(
      name: 'Swedish',
      nativeName: 'Svenska',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.excellent),
  'da': LanguageMetadata(
      name: 'Danish',
      nativeName: 'Dansk',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'fi': LanguageMetadata(
      name: 'Finnish',
      nativeName: 'Suomi',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'no': LanguageMetadata(
      name: 'Norwegian',
      nativeName: 'Norsk',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'sk': LanguageMetadata(
      name: 'Slovak',
      nativeName: 'Slovenčina',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'uk': LanguageMetadata(
      name: 'Ukrainian',
      nativeName: 'Українська',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'bg': LanguageMetadata(
      name: 'Bulgarian',
      nativeName: 'Български',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'hr': LanguageMetadata(
      name: 'Croatian',
      nativeName: 'Hrvatski',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'et': LanguageMetadata(
      name: 'Estonian',
      nativeName: 'Eesti',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'lt': LanguageMetadata(
      name: 'Lithuanian',
      nativeName: 'Lietuvių',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'lv': LanguageMetadata(
      name: 'Latvian',
      nativeName: 'Latviešu',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'sl': LanguageMetadata(
      name: 'Slovenian',
      nativeName: 'Slovenščina',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'sr': LanguageMetadata(
      name: 'Serbian',
      nativeName: 'Српски',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'bs': LanguageMetadata(
      name: 'Bosnian',
      nativeName: 'Bosanski',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'mk': LanguageMetadata(
      name: 'Macedonian',
      nativeName: 'Македонски',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'is': LanguageMetadata(
      name: 'Icelandic',
      nativeName: 'Íslenska',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'ga': LanguageMetadata(
      name: 'Irish',
      nativeName: 'Gaeilge',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'cy': LanguageMetadata(
      name: 'Welsh',
      nativeName: 'Cymraeg',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'mt': LanguageMetadata(
      name: 'Maltese',
      nativeName: 'Malti',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'lb': LanguageMetadata(
      name: 'Luxembourgish',
      nativeName: 'Lëtzebuergesch',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'sq': LanguageMetadata(
      name: 'Albanian',
      nativeName: 'Shqip',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'be': LanguageMetadata(
      name: 'Belarusian',
      nativeName: 'Беларуская',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),

  // Middle Eastern Languages
  'he': LanguageMetadata(
      name: 'Hebrew',
      nativeName: 'עברית',
      region: LanguageRegion.mena,
      ttsSupport: TTSSupport.good),
  'fa': LanguageMetadata(
      name: 'Persian',
      nativeName: 'فارسی',
      region: LanguageRegion.mena,
      ttsSupport: TTSSupport.moderate),
  'ps': LanguageMetadata(
      name: 'Pashto',
      nativeName: 'پښتو',
      region: LanguageRegion.mena,
      ttsSupport: TTSSupport.limited),
  'ku': LanguageMetadata(
      name: 'Kurdish',
      nativeName: 'Kurdî',
      region: LanguageRegion.mena,
      ttsSupport: TTSSupport.limited),

  // Southeast Asian Languages
  'vi': LanguageMetadata(
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.good),
  'th': LanguageMetadata(
      name: 'Thai',
      nativeName: 'ไทย',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.good),
  'id': LanguageMetadata(
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.good),
  'ms': LanguageMetadata(
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.good),
  'tl': LanguageMetadata(
      name: 'Filipino',
      nativeName: 'Tagalog',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.moderate),
  'km': LanguageMetadata(
      name: 'Khmer',
      nativeName: 'ខ្មែរ',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.limited),
  'lo': LanguageMetadata(
      name: 'Lao',
      nativeName: 'ລາວ',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.limited),
  'my': LanguageMetadata(
      name: 'Burmese',
      nativeName: 'မြန်မာစာ',
      region: LanguageRegion.asia,
      ttsSupport: TTSSupport.limited),

  // African Languages
  'sw': LanguageMetadata(
      name: 'Swahili',
      nativeName: 'Kiswahili',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.moderate),
  'yo': LanguageMetadata(
      name: 'Yoruba',
      nativeName: 'Yorùbá',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'ig': LanguageMetadata(
      name: 'Igbo',
      nativeName: 'Igbo',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'ha': LanguageMetadata(
      name: 'Hausa',
      nativeName: 'Hausa',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'zu': LanguageMetadata(
      name: 'Zulu',
      nativeName: 'isiZulu',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.moderate),
  'xh': LanguageMetadata(
      name: 'Xhosa',
      nativeName: 'isiXhosa',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'af': LanguageMetadata(
      name: 'Afrikaans',
      nativeName: 'Afrikaans',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.good),
  'st': LanguageMetadata(
      name: 'Sesotho',
      nativeName: 'Sesotho',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'tn': LanguageMetadata(
      name: 'Setswana',
      nativeName: 'Setswana',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'sn': LanguageMetadata(
      name: 'Shona',
      nativeName: 'chiShona',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'am': LanguageMetadata(
      name: 'Amharic',
      nativeName: 'አማርኛ',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.moderate),
  'so': LanguageMetadata(
      name: 'Somali',
      nativeName: 'Soomaali',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'rw': LanguageMetadata(
      name: 'Kinyarwanda',
      nativeName: 'Ikinyarwanda',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'mg': LanguageMetadata(
      name: 'Malagasy',
      nativeName: 'Malagasy',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'ny': LanguageMetadata(
      name: 'Chichewa',
      nativeName: 'Chichewa',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'ee': LanguageMetadata(
      name: 'Ewe',
      nativeName: 'Eʋegbe',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'tw': LanguageMetadata(
      name: 'Twi',
      nativeName: 'Twi',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),
  'gaa': LanguageMetadata(
      name: 'Ga',
      nativeName: 'Gã',
      region: LanguageRegion.africa,
      ttsSupport: TTSSupport.limited),

  // Caucasian Languages
  'ka': LanguageMetadata(
      name: 'Georgian',
      nativeName: 'ქართული',
      region: LanguageRegion.caucasus,
      ttsSupport: TTSSupport.moderate),
  'hy': LanguageMetadata(
      name: 'Armenian',
      nativeName: 'Հdelays',
      region: LanguageRegion.caucasus,
      ttsSupport: TTSSupport.moderate),
  'az': LanguageMetadata(
      name: 'Azerbaijani',
      nativeName: 'Azərbaycanca',
      region: LanguageRegion.caucasus,
      ttsSupport: TTSSupport.moderate),

  // Regional European Languages
  'eu': LanguageMetadata(
      name: 'Basque',
      nativeName: 'Euskara',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'gl': LanguageMetadata(
      name: 'Galician',
      nativeName: 'Galego',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.moderate),
  'ca': LanguageMetadata(
      name: 'Catalan',
      nativeName: 'Català',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.good),
  'la': LanguageMetadata(
      name: 'Latin',
      nativeName: 'Latina',
      region: LanguageRegion.europe,
      ttsSupport: TTSSupport.limited),
  'eo': LanguageMetadata(
      name: 'Esperanto',
      nativeName: 'Esperanto',
      region: LanguageRegion.constructed,
      ttsSupport: TTSSupport.limited),

  // Central Asian
  'kk': LanguageMetadata(
      name: 'Kazakh',
      nativeName: 'Қазақша',
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.moderate),
  'uz': LanguageMetadata(
      name: 'Uzbek',
      nativeName: "O'zbek",
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.moderate),
  'tg': LanguageMetadata(
      name: 'Tajik',
      nativeName: 'Тоҷикӣ',
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.limited),
  'ky': LanguageMetadata(
      name: 'Kyrgyz',
      nativeName: 'Кыргызча',
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.limited),
  'tk': LanguageMetadata(
      name: 'Turkmen',
      nativeName: 'Türkmen',
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.limited),
  'mn': LanguageMetadata(
      name: 'Mongolian',
      nativeName: 'Монгол',
      region: LanguageRegion.centralAsia,
      ttsSupport: TTSSupport.moderate),

  // Special
  'auto': LanguageMetadata(
      name: 'Auto-detect',
      nativeName: 'Auto',
      region: LanguageRegion.special,
      ttsSupport: TTSSupport.notApplicable),
};

// ============================================================================
// VOICE DEFINITIONS
// ============================================================================

/// Default voice gender per language
const Map<String, VoiceGender> defaultVoiceGenders = {
  'en': VoiceGender.female,
  'es': VoiceGender.female,
  'fr': VoiceGender.female,
  'de': VoiceGender.male,
  'it': VoiceGender.female,
  'pt': VoiceGender.female,
  'ru': VoiceGender.female,
  'zh': VoiceGender.female,
  'ja': VoiceGender.female,
  'ko': VoiceGender.female,
  'ar': VoiceGender.male,
};

/// Azure Neural Voice mappings by language and gender
const Map<String, Map<String, List<String>>> azureNeuralVoices = {
  'en': {
    'male': ['en-US-GuyNeural', 'en-US-DavisNeural', 'en-GB-RyanNeural'],
    'female': ['en-US-JennyNeural', 'en-US-AriaNeural', 'en-GB-SoniaNeural'],
  },
  'es': {
    'male': ['es-ES-AlvaroNeural', 'es-MX-JorgeNeural'],
    'female': ['es-ES-ElviraNeural', 'es-MX-DaliaNeural'],
  },
  'fr': {
    'male': ['fr-FR-HenriNeural', 'fr-CA-AntoineNeural'],
    'female': ['fr-FR-DeniseNeural', 'fr-CA-SylvieNeural'],
  },
  'de': {
    'male': ['de-DE-ConradNeural', 'de-DE-KillianNeural'],
    'female': ['de-DE-KatjaNeural', 'de-DE-AmalaNeural'],
  },
  'it': {
    'male': ['it-IT-DiegoNeural', 'it-IT-GiuseppeNeural'],
    'female': ['it-IT-ElsaNeural', 'it-IT-IsabellaNeural'],
  },
  'pt': {
    'male': ['pt-BR-AntonioNeural', 'pt-PT-DuarteNeural'],
    'female': ['pt-BR-FranciscaNeural', 'pt-PT-RaquelNeural'],
  },
  'ru': {
    'male': ['ru-RU-DmitryNeural'],
    'female': ['ru-RU-SvetlanaNeural', 'ru-RU-DariyaNeural'],
  },
  'zh': {
    'male': ['zh-CN-YunxiNeural', 'zh-CN-YunjianNeural'],
    'female': ['zh-CN-XiaoxiaoNeural', 'zh-CN-XiaoyiNeural'],
  },
  'ja': {
    'male': ['ja-JP-KeitaNeural'],
    'female': ['ja-JP-NanamiNeural', 'ja-JP-AoiNeural'],
  },
  'ko': {
    'male': ['ko-KR-InJoonNeural'],
    'female': ['ko-KR-SunHiNeural', 'ko-KR-JiMinNeural'],
  },
  'ar': {
    'male': ['ar-SA-HamedNeural', 'ar-EG-ShakirNeural'],
    'female': ['ar-SA-ZariyahNeural', 'ar-EG-SalmaNeural'],
  },
  'hi': {
    'male': ['hi-IN-MadhurNeural'],
    'female': ['hi-IN-SwaraNeural'],
  },
};

/// Deepgram Aura voice IDs
const Map<String, List<Map<String, String>>> deepgramVoices = {
  'male': [
    {'id': 'aura-orion-en', 'name': 'Orion'},
    {'id': 'aura-arcas-en', 'name': 'Arcas'},
    {'id': 'aura-perseus-en', 'name': 'Perseus'},
    {'id': 'aura-angus-en', 'name': 'Angus'},
    {'id': 'aura-orpheus-en', 'name': 'Orpheus'},
    {'id': 'aura-helios-en', 'name': 'Helios'},
    {'id': 'aura-zeus-en', 'name': 'Zeus'},
  ],
  'female': [
    {'id': 'aura-asteria-en', 'name': 'Asteria'},
    {'id': 'aura-luna-en', 'name': 'Luna'},
    {'id': 'aura-stella-en', 'name': 'Stella'},
    {'id': 'aura-athena-en', 'name': 'Athena'},
    {'id': 'aura-hera-en', 'name': 'Hera'},
  ],
};

/// OpenAI TTS voice IDs
const Map<String, List<Map<String, String>>> openAIVoices = {
  'male': [
    {'id': 'onyx', 'name': 'Onyx'},
    {'id': 'echo', 'name': 'Echo'},
    {'id': 'fable', 'name': 'Fable'},
  ],
  'female': [
    {'id': 'alloy', 'name': 'Alloy'},
    {'id': 'nova', 'name': 'Nova'},
    {'id': 'shimmer', 'name': 'Shimmer'},
  ],
};

/// ElevenLabs pre-made voice IDs
const Map<String, List<Map<String, String>>> elevenLabsVoices = {
  'male': [
    {'id': '29vD33N1CtxCmqQRPOHJ', 'name': 'Drew'},
    {'id': 'TxGEqnHWrfWFTfGW9XjX', 'name': 'Josh'},
    {'id': 'VR6AewLTigWG4xSOukaG', 'name': 'Arnold'},
    {'id': 'pNInz6obpgDQGcFmaJgB', 'name': 'Adam'},
  ],
  'female': [
    {'id': '21m00Tcm4TlvDq8ikWAM', 'name': 'Rachel'},
    {'id': 'EXAVITQu4vr4xnSDxMaL', 'name': 'Bella'},
    {'id': 'MF3mGyEYCl7XYWbV9V6O', 'name': 'Elli'},
    {'id': 'XB0fDUnXU5powFXDhCwa', 'name': 'Charlotte'},
  ],
};

/// Supported TTS providers
enum TTSProvider {
  deepgram,
  openai,
  azure,
  google,
  aws,
  elevenlabs,
  playht,
  cartesia,
  rime,
  kokoro,
  gemini,
  assemblyai
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Check if a language code is supported
bool isLanguageSupported(String code) {
  if (code.isEmpty) return false;
  final normalized = code.toLowerCase().split('-')[0];
  return supportedLanguageCodes.contains(normalized);
}

/// Validate a language code format
bool isValidLanguageCode(String code) {
  if (code.isEmpty) return false;
  final trimmed = code.trim().toLowerCase();
  return RegExp(r'^[a-z]{2,3}(-[a-z]{2,4})?$', caseSensitive: false)
      .hasMatch(trimmed);
}

/// Normalize a language code to ISO 639-1 (2-letter) format
String normalizeLanguageCode(String code) {
  if (code.isEmpty) return 'en';
  return code.trim().toLowerCase().split('-')[0].substring(0, 2);
}

/// Get language display name
String getLanguageName(String code, {String displayLocale = 'en'}) {
  if (code.isEmpty) return 'Unknown';

  final normalized = normalizeLanguageCode(code);
  final metadata = languageMetadata[normalized];
  if (metadata != null) {
    return metadata.name;
  }

  return code.toUpperCase();
}

/// Get native language name
String getLanguageNativeName(String code) {
  if (code.isEmpty) return 'Unknown';
  final normalized = normalizeLanguageCode(code);
  final metadata = languageMetadata[normalized];
  if (metadata != null) {
    return metadata.nativeName;
  }
  return getLanguageName(code);
}

/// Get all supported languages as list of LanguageOption
List<LanguageOption> getSupportedLanguages({String displayLocale = 'en'}) {
  final languages =
      supportedLanguageCodes.where((code) => code != 'auto').map((code) {
    final metadata = languageMetadata[code];
    return LanguageOption(
      code: code,
      name: metadata?.name ?? code.toUpperCase(),
      nativeName: metadata?.nativeName ?? code.toUpperCase(),
      ttsSupport: metadata?.ttsSupport ?? TTSSupport.unknown,
      region: metadata?.region ?? LanguageRegion.other,
    );
  }).toList();

  languages.sort((a, b) => a.name.compareTo(b.name));
  return languages;
}

/// Get languages by region
List<LanguageOption> getLanguagesByRegion(LanguageRegion region) {
  return getSupportedLanguages()
      .where((lang) => lang.region == region)
      .toList();
}

/// Get languages with good TTS support
List<LanguageOption> getLanguagesWithGoodTTS() {
  return getSupportedLanguages().where((lang) {
    return lang.ttsSupport == TTSSupport.excellent ||
        lang.ttsSupport == TTSSupport.good;
  }).toList();
}

/// Get default voice for a language and gender
String? getDefaultVoice(
  String langCode, {
  VoiceGender gender = VoiceGender.female,
  String provider = 'deepgram',
}) {
  final normalized = normalizeLanguageCode(langCode);
  final effectiveGender =
      gender == VoiceGender.neutral ? VoiceGender.female : gender;
  final genderKey = effectiveGender == VoiceGender.male ? 'male' : 'female';

  // Multilingual providers (not language-specific)
  if (provider == 'deepgram') {
    final voices = deepgramVoices[genderKey];
    return voices?.isNotEmpty == true ? voices![0]['id'] : null;
  }

  if (provider == 'openai') {
    final voices = openAIVoices[genderKey];
    return voices?.isNotEmpty == true ? voices![0]['id'] : null;
  }

  if (provider == 'elevenlabs') {
    final voices = elevenLabsVoices[genderKey];
    return voices?.isNotEmpty == true ? voices![0]['id'] : null;
  }

  // Language-specific voice maps
  if (provider == 'azure') {
    final langVoices = azureNeuralVoices[normalized];
    if (langVoices == null) return null;
    final genderVoices = langVoices[genderKey] ?? langVoices['female'];
    return genderVoices?.isNotEmpty == true ? genderVoices![0] : null;
  }

  // Default fallback to Deepgram
  final voices = deepgramVoices[genderKey] ?? deepgramVoices['female'];
  return voices?.isNotEmpty == true ? voices![0]['id'] : null;
}

/// Get the default voice gender for a language
VoiceGender getDefaultVoiceGender(String langCode) {
  final normalized = normalizeLanguageCode(langCode);
  return defaultVoiceGenders[normalized] ?? VoiceGender.female;
}

// ============================================================================
// SOCKET-BASED VOICE FETCHING
// ============================================================================

/// Result from socket voice fetch
class SocketVoiceResponse {
  final String provider;
  final String language;
  final Map<String, List<VoiceOption>> voices;
  final String? error;

  SocketVoiceResponse({
    required this.provider,
    required this.language,
    required this.voices,
    this.error,
  });
}

/// Fetch voices via socket connection (keeps API keys server-side)
Future<SocketVoiceResponse> fetchVoicesViaSocket(
  io.Socket socket,
  String provider,
  String language,
) async {
  final completer = Completer<SocketVoiceResponse>();

  // Set timeout
  final timeout = Timer(const Duration(seconds: 5), () {
    if (!completer.isCompleted) {
      // Return static voices as fallback
      completer.complete(SocketVoiceResponse(
        provider: provider,
        language: language,
        voices: getAvailableVoices(language, provider: provider),
        error: 'Request timed out, using static voices',
      ));
    }
  });

  socket.emitWithAck('translation:getVoices', {
    'provider': provider,
    'language': language,
  }, ack: (response) {
    timeout.cancel();
    if (!completer.isCompleted) {
      if (response is Map<String, dynamic>) {
        final maleVoices = (response['voices']?['male'] as List?)
                ?.map((v) => VoiceOption.fromMap(v as Map<String, dynamic>))
                .toList() ??
            [];
        final femaleVoices = (response['voices']?['female'] as List?)
                ?.map((v) => VoiceOption.fromMap(v as Map<String, dynamic>))
                .toList() ??
            [];

        completer.complete(SocketVoiceResponse(
          provider: response['provider'] as String? ?? provider,
          language: response['language'] as String? ?? language,
          voices: {'male': maleVoices, 'female': femaleVoices},
          error: response['error'] as String?,
        ));
      } else {
        completer.complete(SocketVoiceResponse(
          provider: provider,
          language: language,
          voices: getAvailableVoices(language, provider: provider),
          error: 'Invalid response format',
        ));
      }
    }
  });

  return completer.future;
}

/// Fetch supported languages via socket
Future<List<LanguageOption>> fetchLanguagesViaSocket(
  io.Socket socket, {
  String displayLocale = 'en',
}) async {
  final completer = Completer<List<LanguageOption>>();

  final timeout = Timer(const Duration(seconds: 5), () {
    if (!completer.isCompleted) {
      completer.complete(getSupportedLanguages(displayLocale: displayLocale));
    }
  });

  socket.emitWithAck('translation:getLanguages', {
    'displayLocale': displayLocale,
  }, ack: (response) {
    timeout.cancel();
    if (!completer.isCompleted) {
      if (response is Map<String, dynamic> && response['languages'] is List) {
        final languages = (response['languages'] as List)
            .map((l) => LanguageOption.fromMap(l as Map<String, dynamic>))
            .toList();
        completer.complete(languages);
      } else {
        completer.complete(getSupportedLanguages(displayLocale: displayLocale));
      }
    }
  });

  return completer.future;
}

/// Get all available voices for a language
Map<String, List<VoiceOption>> getAvailableVoices(
  String langCode, {
  String provider = 'deepgram',
}) {
  final normalized = normalizeLanguageCode(langCode);
  final providerLower = provider.toLowerCase();

  if (providerLower == 'azure') {
    final langVoices = azureNeuralVoices[normalized];
    if (langVoices == null) return {'male': [], 'female': []};

    List<VoiceOption> toOptions(List<String>? ids, VoiceGender gender) {
      return ids
              ?.map((id) => VoiceOption(
                    id: id,
                    name: id,
                    gender: gender,
                    provider: 'azure',
                    language: normalized,
                  ))
              .toList() ??
          [];
    }

    return {
      'male': toOptions(langVoices['male'], VoiceGender.male),
      'female': toOptions(langVoices['female'], VoiceGender.female),
    };
  }

  return _getStaticVoices(provider);
}

// ============================================================================
// PRIVATE HELPERS
// ============================================================================

Map<String, List<VoiceOption>> _getStaticVoices(String provider) {
  List<VoiceOption> mapToVoiceOptions(
      List<Map<String, String>>? items, VoiceGender gender, String prov) {
    return items
            ?.map((v) => VoiceOption(
                  id: v['id'] ?? '',
                  name: v['name'] ?? '',
                  gender: gender,
                  provider: prov,
                  language: 'en',
                ))
            .toList() ??
        [];
  }

  switch (provider.toLowerCase()) {
    case 'deepgram':
      return {
        'male': mapToVoiceOptions(
            deepgramVoices['male'], VoiceGender.male, provider),
        'female': mapToVoiceOptions(
            deepgramVoices['female'], VoiceGender.female, provider),
      };
    case 'openai':
      return {
        'male':
            mapToVoiceOptions(openAIVoices['male'], VoiceGender.male, provider),
        'female': mapToVoiceOptions(
            openAIVoices['female'], VoiceGender.female, provider),
      };
    case 'elevenlabs':
      return {
        'male': mapToVoiceOptions(
            elevenLabsVoices['male'], VoiceGender.male, provider),
        'female': mapToVoiceOptions(
            elevenLabsVoices['female'], VoiceGender.female, provider),
      };
    default:
      return {
        'male': mapToVoiceOptions(
            deepgramVoices['male'], VoiceGender.male, provider),
        'female': mapToVoiceOptions(
            deepgramVoices['female'], VoiceGender.female, provider),
      };
  }
}

TTSSupport _parseTTSSupport(dynamic value) {
  if (value is TTSSupport) return value;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'excellent':
        return TTSSupport.excellent;
      case 'good':
        return TTSSupport.good;
      case 'moderate':
        return TTSSupport.moderate;
      case 'limited':
        return TTSSupport.limited;
      case 'n/a':
      case 'notapplicable':
        return TTSSupport.notApplicable;
      default:
        return TTSSupport.unknown;
    }
  }
  return TTSSupport.unknown;
}

LanguageRegion _parseRegion(dynamic value) {
  if (value is LanguageRegion) return value;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'global':
        return LanguageRegion.global;
      case 'europe':
        return LanguageRegion.europe;
      case 'asia':
        return LanguageRegion.asia;
      case 'south-asia':
      case 'southasia':
        return LanguageRegion.southAsia;
      case 'mena':
        return LanguageRegion.mena;
      case 'africa':
        return LanguageRegion.africa;
      case 'caucasus':
        return LanguageRegion.caucasus;
      case 'central-asia':
      case 'centralasia':
        return LanguageRegion.centralAsia;
      case 'constructed':
        return LanguageRegion.constructed;
      case 'special':
        return LanguageRegion.special;
      default:
        return LanguageRegion.other;
    }
  }
  return LanguageRegion.other;
}

VoiceGender _parseVoiceGender(dynamic value) {
  if (value is VoiceGender) return value;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'male':
        return VoiceGender.male;
      case 'female':
        return VoiceGender.female;
      case 'neutral':
        return VoiceGender.neutral;
      default:
        return VoiceGender.female;
    }
  }
  return VoiceGender.female;
}
