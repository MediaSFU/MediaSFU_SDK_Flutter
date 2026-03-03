import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:url_launcher/url_launcher.dart';

import '../../types/types.dart'
    show
        Participant,
        ShowAlert,
        TranslationMeta,
        ListenerTranslationPreferences;
import '../../types/modal_style_options.dart' show ModalRenderMode;
import '../../components_modern/core/theme/mediasfu_colors.dart';
import '../../components_modern/core/theme/mediasfu_spacing.dart';
import '../../components_modern/core/theme/mediasfu_typography.dart';
import '../../components_modern/core/theme/mediasfu_borders.dart';
import '../../components_modern/core/widgets/glassmorphic_container.dart';
import '../../components_modern/core/widgets/premium_button.dart';
import '../../methods/utils/translation_languages.dart';

// ============================================================================
// Types
// ============================================================================

enum VoiceSelectionMode { basic, advanced, clone }

enum LanguageMode { allowlist, blocklist, any }

class VoiceCloneConfig {
  final String provider; // 'elevenlabs' | 'playht' | 'coqui'
  final String voiceId;
  final double? stability; // 0-1, ElevenLabs
  final double? similarity; // 0-1, ElevenLabs

  VoiceCloneConfig({
    required this.provider,
    required this.voiceId,
    this.stability,
    this.similarity,
  });

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'voiceId': voiceId,
      if (stability != null) 'stability': stability,
      if (similarity != null) 'similarity': similarity,
    };
  }
}

class TranslationVoiceConfig {
  final String? sttNickName;
  final String? llmNickName;
  final String? ttsNickName;
  final Map<String, dynamic>? sttParams;
  final Map<String, dynamic>? llmParams;
  final Map<String, dynamic>? ttsParams;

  TranslationVoiceConfig({
    this.sttNickName,
    this.llmNickName,
    this.ttsNickName,
    this.sttParams,
    this.llmParams,
    this.ttsParams,
  });

  factory TranslationVoiceConfig.fromMap(Map<String, dynamic> map) {
    return TranslationVoiceConfig(
      sttNickName: map['sttNickName'],
      llmNickName: map['llmNickName'],
      ttsNickName: map['ttsNickName'],
      sttParams: map['sttParams'],
      llmParams: map['llmParams'],
      ttsParams: map['ttsParams'],
    );
  }
}

class LanguageEntry {
  final String code;
  final String? nickname;
  final TranslationVoiceConfig? voiceConfig;

  LanguageEntry({
    required this.code,
    this.nickname,
    this.voiceConfig,
  });

  factory LanguageEntry.fromMap(Map<String, dynamic> map) {
    return LanguageEntry(
      code: map['code'],
      nickname: map['nickname'],
      voiceConfig: map['voiceConfig'] != null
          ? TranslationVoiceConfig.fromMap(map['voiceConfig'])
          : null,
    );
  }
}

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

  TranslationRoomConfig({
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
      supportTranslation: map['supportTranslation'] ?? false,
      spokenLanguageMode: _parseLanguageMode(map['spokenLanguageMode']),
      allowedSpokenLanguages: map['allowedSpokenLanguages'] != null
          ? (map['allowedSpokenLanguages'] as List)
              .map((e) => LanguageEntry.fromMap(e))
              .toList()
          : null,
      blockedSpokenLanguages: map['blockedSpokenLanguages'] != null
          ? List<String>.from(map['blockedSpokenLanguages'])
          : null,
      listenLanguageMode: _parseLanguageMode(map['listenLanguageMode']),
      allowedListenLanguages: map['allowedListenLanguages'] != null
          ? (map['allowedListenLanguages'] as List)
              .map((e) => LanguageEntry.fromMap(e))
              .toList()
          : null,
      blockedListenLanguages: map['blockedListenLanguages'] != null
          ? List<String>.from(map['blockedListenLanguages'])
          : null,
      maxActiveChannelsPerSpeaker: map['maxActiveChannelsPerSpeaker'] ?? 1,
      autoDetectSpokenLanguage: map['autoDetectSpokenLanguage'] ?? false,
      allowSpokenLanguageChange: map['allowSpokenLanguageChange'],
      allowListenLanguageChange: map['allowListenLanguageChange'],
      translationVoiceConfig: map['translationVoiceConfig'] != null
          ? TranslationVoiceConfig.fromMap(map['translationVoiceConfig'])
          : null,
    );
  }

  static LanguageMode _parseLanguageMode(String? mode) {
    switch (mode) {
      case 'allowlist':
        return LanguageMode.allowlist;
      case 'blocklist':
        return LanguageMode.blocklist;
      default:
        return LanguageMode.any;
    }
  }
}

class TranslationSettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final TranslationRoomConfig? translationConfig;
  final String member;
  final String islevel;
  final String? audioProducerId;
  final List<Participant> participants;

  final ListenerTranslationPreferences? listenerTranslationPreferences;
  final Map<String, String>? listenerTranslationOverrides;
  final Map<String, TranslationMeta>? translationProducerMap;
  final Map<String, dynamic>? speakerTranslationStates;
  final Set<String>? translationSubscriptions;
  final Function(ListenerTranslationPreferences)
      updateListenerTranslationPreferences;
  final Function(Map<String, String>) updateListenerTranslationOverrides;
  final Function(Map<String, TranslationMeta>) updateTranslationProducerMap;
  final Function(Map<String, dynamic>) updateSpeakerTranslationStates;

  final io.Socket? socket;
  final String roomName;
  final ShowAlert? showAlert;

  // Convenience getters/setters for the UI
  final String? mySpokenLanguage;
  final bool? mySpokenLanguageEnabled;
  final String? myDefaultOutputLanguage;
  final String? myDefaultListenLanguage;
  final Map<String, String>? listenPreferences;

  final Function(String)? updateMySpokenLanguage;
  final Function(bool)? updateMySpokenLanguageEnabled;
  final Function(String)? updateMyDefaultOutputLanguage;
  final Function(String?)? updateMyDefaultListenLanguage;
  final Function(Map<String, String>)? updateListenPreferences;

  // Live subtitles on video cards
  final bool? showSubtitlesOnCards;
  final Function(bool)? updateShowSubtitlesOnCards;

  /// True when translation is billed from the user's personal credits
  final bool isPersonalTranslation;

  /// User's voice clones passed from the app level.
  /// Each clone is a map with keys: id, voiceId, name, provider, isDefault.
  final List<Map<String, dynamic>>? userVoiceClones;

  /// Render mode: modal (overlay) or sidebar (inline, no backdrop/rounded corners).
  final ModalRenderMode renderMode;

  TranslationSettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.translationConfig,
    required this.member,
    required this.islevel,
    this.audioProducerId,
    required this.participants,
    required this.listenerTranslationPreferences,
    required this.listenerTranslationOverrides,
    required this.translationProducerMap,
    required this.speakerTranslationStates,
    this.translationSubscriptions,
    required this.updateListenerTranslationPreferences,
    required this.updateListenerTranslationOverrides,
    required this.updateTranslationProducerMap,
    required this.updateSpeakerTranslationStates,
    this.socket,
    required this.roomName,
    this.showAlert,
    this.mySpokenLanguage,
    this.mySpokenLanguageEnabled,
    this.myDefaultOutputLanguage,
    this.myDefaultListenLanguage,
    this.listenPreferences,
    this.updateMySpokenLanguage,
    this.updateMySpokenLanguageEnabled,
    this.updateMyDefaultOutputLanguage,
    this.updateMyDefaultListenLanguage,
    this.updateListenPreferences,
    this.showSubtitlesOnCards,
    this.updateShowSubtitlesOnCards,
    this.isPersonalTranslation = false,
    this.userVoiceClones,
    this.renderMode = ModalRenderMode.modal,
  });
}

// ============================================================================
// Sub-Components
// ============================================================================

class LanguageDropdown extends StatefulWidget {
  final String? value;
  final Function(String) onChange;
  final List<LanguageOption> languages;
  final String placeholder;
  final bool disabled;
  final bool isDarkMode;
  final bool includeOriginal;
  final bool includeAuto;
  final bool includeSpeakerOutput;

  const LanguageDropdown({
    super.key,
    this.value,
    required this.onChange,
    required this.languages,
    this.placeholder = 'Select language',
    this.disabled = false,
    this.isDarkMode = true,
    this.includeOriginal = false,
    this.includeAuto = false,
    this.includeSpeakerOutput = false,
  });

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  bool _isOpen = false;

  String get _selectedLabel {
    if (widget.value == 'speakerOutput') return "Speaker's Output";
    if (widget.value == null && widget.includeSpeakerOutput) {
      return "Speaker's Output";
    }
    if (widget.value == null) return widget.placeholder;
    if (widget.value == 'original') return 'Raw Microphone Audio';
    if (widget.value == 'auto') return 'Auto-Detect';
    return getLanguageName(widget.value!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.disabled
              ? null
              : () {
                  setState(() {
                    _isOpen = !_isOpen;
                  });
                },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.surfaceElevatedDark
                  : MediasfuColors.surfaceElevated,
              border: Border.all(
                color: widget.isDarkMode
                    ? MediasfuColors.glassBorder(darkMode: true)
                    : MediasfuColors.divider,
              ),
              borderRadius: BorderRadius.circular(MediasfuBorders.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? MediasfuColors.textPrimaryDark
                          : MediasfuColors.textPrimary,
                      fontSize: MediasfuTypography.bodyMedium.fontSize,
                    ),
                  ),
                ),
                Icon(
                  _isOpen
                      ? FontAwesomeIcons.chevronUp
                      : FontAwesomeIcons.chevronDown,
                  size: 12,
                  color: widget.isDarkMode
                      ? MediasfuColors.textPrimaryDark
                      : MediasfuColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.surfaceDark
                  : MediasfuColors.surface,
              border: Border.all(
                color: widget.isDarkMode
                    ? MediasfuColors.glassBorder(darkMode: true)
                    : MediasfuColors.divider,
              ),
              borderRadius: BorderRadius.circular(MediasfuBorders.md),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.includeSpeakerOutput)
                    _buildOption(
                      'speakerOutput',
                      "Speaker's Output (Default)",
                      isSelected: widget.value == 'speakerOutput' ||
                          widget.value == null,
                    ),
                  if (widget.includeOriginal)
                    _buildOption(
                      'original',
                      'Raw Microphone Audio (Host Only)',
                      isSelected: widget.value == 'original',
                    ),
                  if (widget.includeAuto)
                    _buildOption(
                      'auto',
                      'Auto-Detect',
                      isSelected: widget.value == 'auto',
                      icon: FontAwesomeIcons.wandMagicSparkles,
                    ),
                  if ((widget.includeSpeakerOutput ||
                          widget.includeOriginal ||
                          widget.includeAuto) &&
                      widget.languages.isNotEmpty)
                    Divider(
                      height: 1,
                      color: widget.isDarkMode
                          ? MediasfuColors.glassBorder(darkMode: true)
                          : MediasfuColors.divider,
                    ),
                  ...widget.languages.map(
                    (lang) => _buildOption(
                      lang.code,
                      lang.name,
                      isSelected: widget.value == lang.code,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(String value, String label,
      {bool isSelected = false, IconData? icon}) {
    return InkWell(
      onTap: () {
        widget.onChange(value);
        setState(() {
          _isOpen = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.sm,
        ),
        color: isSelected
            ? (widget.isDarkMode
                ? MediasfuColors.primaryDark
                : MediasfuColors.primary)
            : Colors.transparent,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected
                    ? Colors.white
                    : (widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary),
                fontSize: MediasfuTypography.bodyMedium.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeakerLanguageRow extends StatelessWidget {
  final Participant speaker;
  final String? selectedLanguage;
  final Function(String, String) onChange;
  final List<LanguageOption> availableLanguages;
  final bool isDarkMode;
  final bool isHost;

  const SpeakerLanguageRow({
    super.key,
    required this.speaker,
    this.selectedLanguage,
    required this.onChange,
    required this.availableLanguages,
    this.isDarkMode = true,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediasfuSpacing.sm),
      padding: EdgeInsets.all(MediasfuSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? MediasfuColors.surfaceElevatedDark.withOpacity(0.5)
            : MediasfuColors.surfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(MediasfuBorders.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.user,
                  size: 14,
                  color: isDarkMode
                      ? MediasfuColors.textMutedDark
                      : MediasfuColors.textMuted,
                ),
                SizedBox(width: MediasfuSpacing.sm),
                Expanded(
                  child: Text(
                    speaker.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode
                          ? MediasfuColors.textPrimaryDark
                          : MediasfuColors.textPrimary,
                      fontSize: MediasfuTypography.bodyMedium.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 180,
            child: LanguageDropdown(
              value:
                  selectedLanguage ?? (isHost ? 'original' : 'speakerOutput'),
              onChange: (lang) => onChange(speaker.name, lang),
              languages: availableLanguages,
              isDarkMode: isDarkMode,
              includeOriginal: isHost,
              includeSpeakerOutput: true,
              placeholder: "Speaker's Output",
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Main Component
// ============================================================================

class TranslationSettingsModal extends StatefulWidget {
  final TranslationSettingsModalOptions options;
  final bool isDarkMode;
  final bool enableGlassmorphism;
  final bool enableGlow;

  const TranslationSettingsModal({
    super.key,
    required this.options,
    this.isDarkMode = true,
    this.enableGlassmorphism = true,
    this.enableGlow = true,
  });

  @override
  State<TranslationSettingsModal> createState() =>
      _TranslationSettingsModalState();
}

class _TranslationSettingsModalState extends State<TranslationSettingsModal> {
  bool _isMounted = false;
  bool _isSaving = false;
  String _activeTab = 'speaking'; // 'speaking' | 'listening'
  bool _perSpeakerMode = false;

  // Local state
  late String _localSpokenLanguage;
  late bool _localSpokenEnabled;
  String? _localDefaultOutputLang;
  String? _localDefaultListen;
  late Map<String, String> _localListenPrefs;
  late bool _localShowSubtitles;

  // Rate limiting
  static const int RATE_LIMIT_MS = 30000;
  int _lastSpokenChange = 0;
  int _lastListenChange = 0;
  int _spokenCooldown = 0;
  int _listenCooldown = 0;
  Timer? _cooldownTimer;

  // Voice selection
  VoiceSelectionMode _voiceSelectionMode = VoiceSelectionMode.basic;
  String _selectedVoiceGender = 'female'; // 'female' | 'male' | 'neutral'
  String? _selectedVoiceId;
  String _selectedTTSProvider = 'deepgram';

  // Voice cloning
  VoiceCloneConfig? _voiceCloneConfig;
  List<Map<String, dynamic>> _fetchedClones = [];
  String _cloneVoiceId = '';
  String _cloneProvider = 'cartesia';
  double _cloneStability = 0.5;
  double _cloneSimilarity = 0.75;
  bool _showManualCloneEntry = false;

  // Fetched data
  Map<String, List<VoiceOption>>? _availableVoices;
  List<LanguageOption>? _dynamicLanguages;
  bool _voicesFetched = false;
  bool _voicesLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _fetchVoices();
    _startCooldownTimer();

    // Mount animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _isMounted = true);
    });
  }

  void _initializeState() {
    final prefs = widget.options.listenerTranslationPreferences;
    _localListenPrefs = prefs != null ? Map.from(prefs.perSpeaker) : {};
    _localDefaultListen = prefs?.globalLanguage;
    _perSpeakerMode = _localListenPrefs.isNotEmpty;

    final speakerState =
        widget.options.speakerTranslationStates?[widget.options.member];
    if (speakerState != null) {
      _localSpokenLanguage = speakerState['inputLanguage'] ?? 'en';
      _localSpokenEnabled = speakerState['enabled'] ?? false;
      _localDefaultOutputLang = speakerState['outputLanguage'];
    } else {
      _localSpokenLanguage = widget.options.mySpokenLanguage ?? 'en';
      _localSpokenEnabled = widget.options.mySpokenLanguageEnabled ?? false;
      _localDefaultOutputLang = widget.options.myDefaultOutputLanguage;
    }

    _localShowSubtitles = widget.options.showSubtitlesOnCards ?? false;

    // Initialize voice clones from props (passed from app level)
    _fetchedClones = widget.options.userVoiceClones ?? [];

    // Default to clone mode if user has clones
    if (_fetchedClones.isNotEmpty) {
      _voiceSelectionMode = VoiceSelectionMode.clone;
      // Auto-select the default clone, or the first one
      final defaultClone = _fetchedClones.firstWhere(
        (c) => c['isDefault'] == true,
        orElse: () => _fetchedClones.first,
      );
      final cloneId = defaultClone['providerVoiceId']?.toString() ??
          defaultClone['voiceId']?.toString() ??
          defaultClone['id']?.toString() ??
          '';
      final cloneProv = defaultClone['provider']?.toString() ?? 'cartesia';
      if (cloneId.isNotEmpty) {
        _voiceCloneConfig = VoiceCloneConfig(
          provider: cloneProv,
          voiceId: cloneId,
        );
      }
    }

    if (widget.options.translationConfig?.translationVoiceConfig?.ttsNickName !=
        null) {
      _selectedTTSProvider = widget
          .options.translationConfig!.translationVoiceConfig!.ttsNickName!;
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now().millisecondsSinceEpoch;

      if (_lastSpokenChange > 0) {
        final elapsed = now - _lastSpokenChange;
        final remaining = (RATE_LIMIT_MS - elapsed) / 1000 > 0
            ? ((RATE_LIMIT_MS - elapsed) / 1000).ceil()
            : 0;
        if (remaining != _spokenCooldown) {
          setState(() => _spokenCooldown = remaining);
        }
      }

      if (_lastListenChange > 0) {
        final elapsed = now - _lastListenChange;
        final remaining = (RATE_LIMIT_MS - elapsed) / 1000 > 0
            ? ((RATE_LIMIT_MS - elapsed) / 1000).ceil()
            : 0;
        if (remaining != _listenCooldown) {
          setState(() => _listenCooldown = remaining);
        }
      }
    });
  }

  Future<void> _fetchVoices() async {
    if (!_voicesFetched &&
        widget.options.socket != null &&
        widget.options.roomName.isNotEmpty) {
      setState(() => _voicesLoading = true);

      try {
        // Fetch voices
        final voicesFuture = fetchVoicesViaSocket(
          widget.options.socket!,
          _selectedTTSProvider,
          _localSpokenLanguage.isNotEmpty ? _localSpokenLanguage : 'en',
        );

        // Fetch languages
        final languagesFuture = fetchLanguagesViaSocket(
          widget.options.socket!,
          displayLocale: 'en',
        );

        final results = await Future.wait([
          voicesFuture,
          languagesFuture,
        ]);

        final voiceResponse = results[0] as SocketVoiceResponse;
        final languages = results[1] as List<LanguageOption>;

        if (mounted) {
          setState(() {
            _availableVoices = voiceResponse.voices;

            if (voiceResponse.provider.isNotEmpty &&
                voiceResponse.provider != _selectedTTSProvider) {
              _selectedTTSProvider = voiceResponse.provider;
            }

            if (languages.isNotEmpty) {
              _dynamicLanguages = languages;
            }

            _voicesFetched = true;
            _voicesLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _voicesLoading = false;
            // Fallback to static voices
            _availableVoices = getAvailableVoices(
              _localSpokenLanguage.isNotEmpty ? _localSpokenLanguage : 'en',
              provider: _selectedTTSProvider,
            );
            _voicesFetched = true;
          });
        }
      }
    }
  }

  List<LanguageOption> get _availableSpokenLanguages {
    final base = _dynamicLanguages ?? getSupportedLanguages();
    final config = widget.options.translationConfig;

    if (config == null) return base;

    if (config.spokenLanguageMode == LanguageMode.allowlist) {
      final allowedCodes =
          config.allowedSpokenLanguages?.map((e) => e.code).toList() ?? [];
      return base.where((l) => allowedCodes.contains(l.code)).toList();
    }

    if (config.spokenLanguageMode == LanguageMode.blocklist) {
      final blockedCodes = config.blockedSpokenLanguages ?? [];
      return base.where((l) => !blockedCodes.contains(l.code)).toList();
    }

    return base;
  }

  List<LanguageOption> get _availableListenLanguages {
    final base = _dynamicLanguages ?? getSupportedLanguages();
    final config = widget.options.translationConfig;

    if (config == null) return base;

    if (config.listenLanguageMode == LanguageMode.allowlist) {
      final allowedCodes =
          config.allowedListenLanguages?.map((e) => e.code).toList() ?? [];
      return base.where((l) => allowedCodes.contains(l.code)).toList();
    }

    if (config.listenLanguageMode == LanguageMode.blocklist) {
      final blockedCodes = config.blockedListenLanguages ?? [];
      return base.where((l) => !blockedCodes.contains(l.code)).toList();
    }

    return base;
  }

  List<Participant> get _otherParticipants {
    return widget.options.participants
        .where((p) => p.name != widget.options.member)
        .toList();
  }

  bool _areMapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map2[key] != map1[key]) return false;
    }
    return true;
  }

  Future<void> _handleApply() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final spokenChanged =
        _localSpokenLanguage != widget.options.mySpokenLanguage ||
            _localSpokenEnabled != widget.options.mySpokenLanguageEnabled ||
            _localDefaultOutputLang != widget.options.myDefaultOutputLanguage;

    final listenChanged = !_perSpeakerMode
        ? _localDefaultListen != widget.options.myDefaultListenLanguage
        : !_areMapsEqual(
            _localListenPrefs, widget.options.listenPreferences ?? {});

    // Rate limiting checks
    if (spokenChanged && _lastSpokenChange > 0) {
      final elapsed = now - _lastSpokenChange;
      if (elapsed < RATE_LIMIT_MS) {
        final remaining = ((RATE_LIMIT_MS - elapsed) / 1000).ceil();
        widget.options.showAlert?.call(
          message:
              'Please wait $remaining seconds before changing spoken language',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
    }

    if (listenChanged && _lastListenChange > 0) {
      final elapsed = now - _lastListenChange;
      if (elapsed < RATE_LIMIT_MS) {
        final remaining = ((RATE_LIMIT_MS - elapsed) / 1000).ceil();
        widget.options.showAlert?.call(
          message:
              'Please wait $remaining seconds before changing listen language',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      // Build voice config
      final Map<String, dynamic> voiceConfig = {};

      if (_voiceSelectionMode == VoiceSelectionMode.clone &&
          _voiceCloneConfig != null) {
        voiceConfig['voiceClone'] = _voiceCloneConfig!.toMap();
      } else if (_voiceSelectionMode == VoiceSelectionMode.advanced &&
          _selectedVoiceId != null) {
        voiceConfig['voiceId'] = _selectedVoiceId;
        voiceConfig['ttsProvider'] = _selectedTTSProvider;
      } else {
        voiceConfig['voiceGender'] = _selectedVoiceGender;
      }

      // Update spoken language
      if (spokenChanged || _localSpokenEnabled) {
        widget.options.socket?.emit('translation:setMyLanguage', {
          'roomName': widget.options.roomName,
          'language': _localSpokenLanguage,
          'defaultOutputLanguage': _localDefaultOutputLang,
          'enabled': _localSpokenEnabled,
          'producerId': widget.options.audioProducerId,
          'voiceConfig': _localSpokenEnabled ? voiceConfig : null,
        });

        widget.options.updateMySpokenLanguage?.call(_localSpokenLanguage);
        if (_localDefaultOutputLang != null) {
          widget.options.updateMyDefaultOutputLanguage
              ?.call(_localDefaultOutputLang!);
        }
        widget.options.updateMySpokenLanguageEnabled?.call(_localSpokenEnabled);
        _lastSpokenChange = now;
        setState(() => _spokenCooldown = 30);
      }

      // Update listening preferences
      if (!_perSpeakerMode) {
        if (_localDefaultListen != widget.options.myDefaultListenLanguage) {
          widget.options.socket?.emit('translation:setDefaultListenLanguage', {
            'roomName': widget.options.roomName,
            'language': _localDefaultListen,
          });
          widget.options.updateMyDefaultListenLanguage
              ?.call(_localDefaultListen);
          widget.options.updateListenPreferences?.call({});
          _lastListenChange = now;
          setState(() => _listenCooldown = 30);
        }
      } else {
        widget.options.updateMyDefaultListenLanguage?.call(null);
        widget.options.updateListenPreferences?.call(_localListenPrefs);

        // Emit individual changes
        for (final entry in _localListenPrefs.entries) {
          final speakerId = entry.key;
          final language = entry.value;
          final prevLang = widget.options.listenPreferences?[speakerId];

          if (prevLang != language) {
            if (prevLang != null) {
              widget.options.socket?.emit('translation:unsubscribe', {
                'roomName': widget.options.roomName,
                'speakerId': speakerId,
                'language': prevLang,
              });
            }
            widget.options.socket?.emit('translation:subscribe', {
              'roomName': widget.options.roomName,
              'speakerId': speakerId,
              'language': language,
            });
          }
        }

        // Unsubscribe removed
        for (final entry in (widget.options.listenPreferences ?? {}).entries) {
          if (!_localListenPrefs.containsKey(entry.key)) {
            widget.options.socket?.emit('translation:unsubscribe', {
              'roomName': widget.options.roomName,
              'speakerId': entry.key,
              'language': entry.value,
            });
          }
        }

        if (listenChanged) {
          _lastListenChange = now;
          setState(() => _listenCooldown = 30);
        }
      }

      widget.options.showAlert?.call(
        message: 'Translation settings saved',
        type: 'success',
        duration: 2000,
      );
      widget.options.onClose();
    } catch (_) {
      widget.options.showAlert?.call(
        message: 'Failed to save settings',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.isVisible) return const SizedBox.shrink();

    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: widget.options.onClose,
          child: Container(
            color: MediasfuColors.alertBackdrop(darkMode: widget.isDarkMode),
          ),
        ),

        // Modal
        Center(
          child: AnimatedOpacity(
            opacity: _isMounted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.85,
              child: GlassmorphicContainer(
                borderRadius: MediasfuBorders.xl,
                blur: widget.enableGlassmorphism ? 20 : 0,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTabs(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(MediasfuSpacing.md),
                        child: _activeTab == 'speaking'
                            ? _buildSpeakingTab()
                            : _buildListeningTab(),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sidebar/inline rendering: no backdrop, no Center wrapper, no rounded corners,
  /// no glassmorphism — just plain content filling the sidebar container.
  Widget _buildSidebarContent() {
    return Container(
      color: widget.isDarkMode
          ? MediasfuColors.surfaceDark
          : MediasfuColors.surface,
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(MediasfuSpacing.md),
              child: _activeTab == 'speaking'
                  ? _buildSpeakingTab()
                  : _buildListeningTab(),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MediasfuColors.glassBorder(darkMode: widget.isDarkMode),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.globe,
                color: widget.isDarkMode
                    ? MediasfuColors.accentDark
                    : MediasfuColors.accent,
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Translation Settings',
                style: MediasfuTypography.getTitleMedium(widget.isDarkMode),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: widget.options.onClose,
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MediasfuColors.glassBorder(darkMode: widget.isDarkMode),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(
              'speaking', FontAwesomeIcons.microphone, 'My Voice Output'),
          _buildTabButton(
              'listening', FontAwesomeIcons.headphones, 'Listen To'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String id, IconData icon, String label) {
    final isActive = _activeTab == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: EdgeInsets.all(MediasfuSpacing.md),
          decoration: BoxDecoration(
            color: isActive
                ? (widget.isDarkMode
                    ? MediasfuColors.primaryDark.withOpacity(0.2)
                    : MediasfuColors.primary.withOpacity(0.1))
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? (widget.isDarkMode
                        ? MediasfuColors.primaryDark
                        : MediasfuColors.primary)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? (widget.isDarkMode
                        ? MediasfuColors.primaryDark
                        : MediasfuColors.primary)
                    : (widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted),
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? (widget.isDarkMode
                          ? MediasfuColors.primaryDark
                          : MediasfuColors.primary)
                      : (widget.isDarkMode
                          ? MediasfuColors.textMutedDark
                          : MediasfuColors.textMuted),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optionally specify your spoken language (helps auto-detection). Then choose an output language to have your voice translated for everyone.',
          style: TextStyle(
            color: widget.isDarkMode
                ? MediasfuColors.textMutedDark
                : MediasfuColors.textMuted,
            fontSize: MediasfuTypography.bodySmall.fontSize,
          ),
        ),
        SizedBox(height: MediasfuSpacing.md),
        if (_spokenCooldown > 0)
          Container(
            margin: EdgeInsets.only(bottom: MediasfuSpacing.md),
            padding: EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.warning.withOpacity(0.15)
                  : MediasfuColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MediasfuBorders.sm),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.clock,
                    size: 14, color: MediasfuColors.warning),
                SizedBox(width: MediasfuSpacing.sm),
                Text(
                  'Wait ${_spokenCooldown}s before changing spoken language',
                  style: TextStyle(
                    color: MediasfuColors.warning,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Spoken Language',
          style: TextStyle(
            color: widget.isDarkMode
                ? MediasfuColors.textPrimaryDark
                : MediasfuColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediasfuSpacing.sm),
        LanguageDropdown(
          value: _localSpokenLanguage,
          onChange: (val) => setState(() => _localSpokenLanguage = val),
          languages: _availableSpokenLanguages,
          isDarkMode: widget.isDarkMode,
          includeAuto:
              widget.options.translationConfig?.autoDetectSpokenLanguage ??
                  false,
        ),
        SizedBox(height: MediasfuSpacing.lg),
        Container(
          padding: EdgeInsets.all(MediasfuSpacing.md),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? MediasfuColors.surfaceElevatedDark.withOpacity(0.5)
                : MediasfuColors.surfaceElevated.withOpacity(0.5),
            borderRadius: BorderRadius.circular(MediasfuBorders.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Speak in a different language (translate my voice)',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: _localSpokenEnabled,
                onChanged: (val) => setState(() => _localSpokenEnabled = val),
                activeColor: const Color(0xFF22C55E),
                activeTrackColor: const Color(0xFF22C55E).withOpacity(0.5),
                inactiveThumbColor: widget.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
                inactiveTrackColor: widget.isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
            ],
          ),
        ),
        if (widget.options.isPersonalTranslation)
          Padding(
            padding: EdgeInsets.only(top: MediasfuSpacing.sm),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? const Color(0xFFEAB308).withOpacity(0.08)
                    : const Color(0xFFEAB308).withOpacity(0.06),
                borderRadius: BorderRadius.circular(MediasfuBorders.sm),
                border: Border.all(
                  color: widget.isDarkMode
                      ? const Color(0xFFEAB308).withOpacity(0.2)
                      : const Color(0xFFEAB308).withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: widget.isDarkMode
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                  SizedBox(width: MediasfuSpacing.sm),
                  Expanded(
                    child: Text(
                      'Translation is billed from your personal credits',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_localSpokenEnabled) ...[
          SizedBox(height: MediasfuSpacing.lg),
          Text(
            'Output Language (Everyone Hears)',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textPrimaryDark
                  : MediasfuColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: MediasfuSpacing.sm),
          LanguageDropdown(
            value: _localDefaultOutputLang,
            onChange: (val) => setState(() => _localDefaultOutputLang = val),
            languages: _availableSpokenLanguages
                .where((l) => l.code != _localSpokenLanguage)
                .toList(),
            isDarkMode: widget.isDarkMode,
            placeholder: 'No translation (speak in my original language)',
          ),
          if (_localDefaultOutputLang != null) _buildVoiceSettings(),
        ],
        // Subtitles toggle - also on speaking tab
        SizedBox(height: MediasfuSpacing.lg),
        _buildSubtitlesToggle(),
      ],
    );
  }

  Widget _buildVoiceSettings() {
    return Container(
      margin: EdgeInsets.only(top: MediasfuSpacing.xl),
      padding: EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? MediasfuColors.surfaceElevatedDark.withOpacity(0.5)
            : MediasfuColors.surfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(MediasfuBorders.lg),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.wandMagicSparkles,
                color: widget.isDarkMode
                    ? MediasfuColors.accentDark
                    : MediasfuColors.accent,
                size: 16,
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Voice Settings',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? MediasfuColors.textPrimaryDark
                      : MediasfuColors.textPrimary,
                  fontSize: MediasfuTypography.bodyLarge.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: MediasfuSpacing.md),

          // Voice Mode Selection
          Row(
            children: [
              _buildVoiceModeButton(VoiceSelectionMode.basic, '✨ Basic'),
              SizedBox(width: MediasfuSpacing.xs),
              _buildVoiceModeButton(VoiceSelectionMode.advanced, '⚙️ Advanced'),
              SizedBox(width: MediasfuSpacing.xs),
              _buildVoiceModeButton(VoiceSelectionMode.clone, '🎤 Clone'),
            ],
          ),
          SizedBox(height: MediasfuSpacing.md),

          if (_voiceSelectionMode == VoiceSelectionMode.basic)
            _buildBasicVoiceSettings(),
          if (_voiceSelectionMode == VoiceSelectionMode.advanced)
            _buildAdvancedVoiceSettings(),
          if (_voiceSelectionMode == VoiceSelectionMode.clone)
            _buildCloneVoiceSettings(),
        ],
      ),
    );
  }

  Widget _buildVoiceModeButton(VoiceSelectionMode mode, String label) {
    final isSelected = _voiceSelectionMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _voiceSelectionMode = mode);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediasfuSpacing.sm,
            horizontal: MediasfuSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDarkMode
                    ? MediasfuColors.primaryDark
                    : MediasfuColors.primary)
                : (widget.isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(MediasfuBorders.sm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (widget.isDarkMode
                      ? MediasfuColors.textMutedDark
                      : MediasfuColors.textMuted),
              fontSize: MediasfuTypography.bodySmall.fontSize,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicVoiceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Gender Preference',
          style: TextStyle(
            color: widget.isDarkMode
                ? MediasfuColors.textMutedDark
                : MediasfuColors.textMuted,
            fontSize: MediasfuTypography.bodySmall.fontSize,
          ),
        ),
        SizedBox(height: MediasfuSpacing.sm),
        Row(
          children: [
            _buildGenderButton('female', '👩 Female'),
            SizedBox(width: MediasfuSpacing.sm),
            _buildGenderButton('male', '👨 Male'),
            SizedBox(width: MediasfuSpacing.sm),
            _buildGenderButton('neutral', '🧑 Neutral'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, String label) {
    final isSelected = _selectedVoiceGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedVoiceGender = gender;
          _selectedVoiceId = null;
        }),
        child: Container(
          padding: EdgeInsets.all(MediasfuSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDarkMode
                    ? MediasfuColors.primaryDark.withOpacity(0.3)
                    : MediasfuColors.primary.withOpacity(0.15))
                : (widget.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03)),
            border: Border.all(
              color: isSelected
                  ? (widget.isDarkMode
                      ? MediasfuColors.primaryDark
                      : MediasfuColors.primary)
                  : (widget.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(MediasfuBorders.md),
          ),
          child: Column(
            children: [
              Text(
                label.split(' ')[0],
                style: const TextStyle(fontSize: 24),
              ),
              SizedBox(height: MediasfuSpacing.xs),
              Text(
                label.split(' ')[1],
                style: TextStyle(
                  color: widget.isDarkMode
                      ? MediasfuColors.textPrimaryDark
                      : MediasfuColors.textPrimary,
                ),
              ),
              if (isSelected)
                Icon(
                  FontAwesomeIcons.check,
                  size: 12,
                  color: MediasfuColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedVoiceSettings() {
    if (_voicesLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(MediasfuSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: MediasfuSpacing.sm),
              Text(
                'Loading voices...',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? MediasfuColors.textMutedDark
                      : MediasfuColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_availableVoices == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(MediasfuSpacing.md),
          child: Text(
            'No voices available',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_availableVoices!['female']?.isNotEmpty ?? false) ...[
          Text(
            '👩 Female Voices',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
            ),
          ),
          SizedBox(height: MediasfuSpacing.xs),
          Wrap(
            spacing: MediasfuSpacing.xs,
            runSpacing: MediasfuSpacing.xs,
            children: _availableVoices!['female']!
                .take(6)
                .map((v) => _buildVoiceChip(v))
                .toList(),
          ),
          SizedBox(height: MediasfuSpacing.md),
        ],
        if (_availableVoices!['male']?.isNotEmpty ?? false) ...[
          Text(
            '👨 Male Voices',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
            ),
          ),
          SizedBox(height: MediasfuSpacing.xs),
          Wrap(
            spacing: MediasfuSpacing.xs,
            runSpacing: MediasfuSpacing.xs,
            children: _availableVoices!['male']!
                .take(6)
                .map((v) => _buildVoiceChip(v))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceChip(VoiceOption voice) {
    final isSelected = _selectedVoiceId == voice.id;
    return InkWell(
      onTap: () => setState(() => _selectedVoiceId = voice.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isDarkMode
                  ? MediasfuColors.primaryDark
                  : MediasfuColors.primary)
              : (widget.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(MediasfuBorders.sm),
        ),
        child: Text(
          voice.name,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (widget.isDarkMode
                    ? MediasfuColors.textPrimaryDark
                    : MediasfuColors.textPrimary),
            fontSize: MediasfuTypography.bodySmall.fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildCloneVoiceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: EdgeInsets.all(MediasfuSpacing.sm),
          margin: EdgeInsets.only(bottom: MediasfuSpacing.md),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? MediasfuColors.info.withOpacity(0.1)
                : MediasfuColors.info.withOpacity(0.05),
            borderRadius: BorderRadius.circular(MediasfuBorders.sm),
          ),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.circleInfo,
                  size: 14,
                  color: widget.isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF2563EB)),
              SizedBox(width: MediasfuSpacing.sm),
              Expanded(
                child: Text(
                  'Select a cloned voice or enter a voice ID manually.',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Clones display (passed from app level)
        if (_fetchedClones.isNotEmpty) ...[
          Text(
            'Your Cloned Voices',
            style: TextStyle(
              fontSize: MediasfuTypography.bodySmall.fontSize,
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
            ),
          ),
          SizedBox(height: MediasfuSpacing.sm),
          Wrap(
            spacing: MediasfuSpacing.sm,
            runSpacing: MediasfuSpacing.sm,
            children: _fetchedClones.map((clone) {
              final cloneId = clone['providerVoiceId']?.toString() ??
                  clone['voiceId']?.toString() ??
                  clone['id']?.toString() ??
                  '';
              final cloneName = clone['name']?.toString() ?? 'Clone';
              final cloneProviderVal =
                  clone['provider']?.toString() ?? 'cartesia';
              final isDefault = clone['isDefault'] == true;
              final isSelected = _voiceCloneConfig?.voiceId == cloneId;

              return InkWell(
                onTap: () {
                  setState(() {
                    _voiceCloneConfig = VoiceCloneConfig(
                      provider: cloneProviderVal,
                      voiceId: cloneId,
                    );
                  });
                  widget.options.showAlert?.call(
                    message: 'Voice clone "$cloneName" selected!',
                    type: 'success',
                    duration: 2000,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediasfuSpacing.md,
                    vertical: MediasfuSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (widget.isDarkMode
                            ? MediasfuColors.primaryDark
                            : MediasfuColors.primary)
                        : (widget.isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05)),
                    border: Border.all(
                      color: isSelected
                          ? (widget.isDarkMode
                              ? MediasfuColors.primaryDark
                              : MediasfuColors.primary)
                          : (widget.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1)),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(MediasfuBorders.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎤',
                        style: const TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: MediasfuSpacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cloneName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (widget.isDarkMode
                                      ? MediasfuColors.textPrimaryDark
                                      : MediasfuColors.textPrimary),
                              fontSize: MediasfuTypography.bodySmall.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            cloneProviderVal,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : (widget.isDarkMode
                                      ? MediasfuColors.textMutedDark
                                      : MediasfuColors.textMuted),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      if (isDefault) ...[
                        SizedBox(width: MediasfuSpacing.xs),
                        Icon(FontAwesomeIcons.star,
                            size: 10, color: MediasfuColors.warning),
                      ],
                      if (isSelected) ...[
                        SizedBox(width: MediasfuSpacing.xs),
                        Icon(FontAwesomeIcons.check,
                            size: 12, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: MediasfuSpacing.md),
        ],

        // No clones available
        if (_fetchedClones.isEmpty)
          Container(
            padding: EdgeInsets.all(MediasfuSpacing.md),
            margin: EdgeInsets.only(bottom: MediasfuSpacing.md),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(MediasfuBorders.md),
            ),
            child: Column(
              children: [
                Text(
                  '🎤',
                  style: const TextStyle(fontSize: 32),
                ),
                SizedBox(height: MediasfuSpacing.sm),
                Text(
                  'No cloned voices found',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MediasfuSpacing.xs),
                Text(
                  'Create a voice clone on the web dashboard, then select it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
                SizedBox(height: MediasfuSpacing.md),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse('https://mediasfu.com/lite/voice-clone'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediasfuSpacing.lg,
                      vertical: MediasfuSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? MediasfuColors.accentDark
                          : MediasfuColors.accent,
                      borderRadius: BorderRadius.circular(MediasfuBorders.md),
                    ),
                    child: Text(
                      '🌐 Create Clone on Web',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediasfuTypography.bodySmall.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Manual entry toggle (hidden for now)
        if (false)
          InkWell(
            onTap: () =>
                setState(() => _showManualCloneEntry = !_showManualCloneEntry),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    _showManualCloneEntry
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.chevronDown,
                    size: 12,
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                  ),
                  SizedBox(width: MediasfuSpacing.sm),
                  Text(
                    'Enter voice ID manually',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? MediasfuColors.textMutedDark
                          : MediasfuColors.textMuted,
                      fontSize: MediasfuTypography.bodySmall.fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Manual clone entry form (hidden for now)
        if (false && _showManualCloneEntry) ...[
          SizedBox(height: MediasfuSpacing.sm),

          // Provider selector
          Text(
            'Voice Clone Provider',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
              fontSize: MediasfuTypography.bodySmall.fontSize,
            ),
          ),
          SizedBox(height: MediasfuSpacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.surfaceElevatedDark
                  : MediasfuColors.surfaceElevated,
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
              ),
              borderRadius: BorderRadius.circular(MediasfuBorders.md),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _cloneProvider,
                isExpanded: true,
                dropdownColor: widget.isDarkMode
                    ? MediasfuColors.surfaceElevatedDark
                    : MediasfuColors.surfaceElevated,
                style: TextStyle(
                  color: widget.isDarkMode
                      ? MediasfuColors.textPrimaryDark
                      : MediasfuColors.textPrimary,
                  fontSize: MediasfuTypography.bodyMedium.fontSize,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'cartesia',
                      child: Text('Cartesia (System Default)')),
                  DropdownMenuItem(
                      value: 'elevenlabs', child: Text('ElevenLabs')),
                  DropdownMenuItem(value: 'playht', child: Text('PlayHT')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _cloneProvider = v);
                },
              ),
            ),
          ),
          SizedBox(height: MediasfuSpacing.md),

          // Voice ID input
          Text(
            'Cloned Voice ID',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textMutedDark
                  : MediasfuColors.textMuted,
              fontSize: MediasfuTypography.bodySmall.fontSize,
            ),
          ),
          SizedBox(height: MediasfuSpacing.xs),
          TextField(
            onChanged: (v) => _cloneVoiceId = v,
            decoration: InputDecoration(
              hintText: 'Enter your cloned voice ID',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? MediasfuColors.textMutedDark
                    : MediasfuColors.textMuted,
                fontSize: MediasfuTypography.bodySmall.fontSize,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediasfuSpacing.md,
                vertical: MediasfuSpacing.sm,
              ),
              filled: true,
              fillColor: widget.isDarkMode
                  ? MediasfuColors.surfaceElevatedDark
                  : MediasfuColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediasfuBorders.md),
                borderSide: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediasfuBorders.md),
                borderSide: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.15),
                ),
              ),
            ),
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textPrimaryDark
                  : MediasfuColors.textPrimary,
              fontSize: MediasfuTypography.bodyMedium.fontSize,
            ),
          ),
          SizedBox(height: MediasfuSpacing.md),

          // ElevenLabs-specific sliders
          if (_cloneProvider == 'elevenlabs') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stability',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
                Text(
                  '${(_cloneStability * 100).round()}%',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ],
            ),
            Slider(
              value: _cloneStability,
              min: 0,
              max: 1,
              divisions: 20,
              activeColor: widget.isDarkMode
                  ? MediasfuColors.primaryDark
                  : MediasfuColors.primary,
              onChanged: (v) => setState(() => _cloneStability = v),
            ),
            Text(
              'Higher = more consistent, Lower = more expressive',
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            SizedBox(height: MediasfuSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Similarity Boost',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
                Text(
                  '${(_cloneSimilarity * 100).round()}%',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ],
            ),
            Slider(
              value: _cloneSimilarity,
              min: 0,
              max: 1,
              divisions: 20,
              activeColor: widget.isDarkMode
                  ? MediasfuColors.primaryDark
                  : MediasfuColors.primary,
              onChanged: (v) => setState(() => _cloneSimilarity = v),
            ),
            Text(
              'Higher = closer to original voice',
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            SizedBox(height: MediasfuSpacing.md),
          ],

          // Apply manual clone button
          InkWell(
            onTap: () {
              if (_cloneVoiceId.trim().isNotEmpty) {
                setState(() {
                  _voiceCloneConfig = VoiceCloneConfig(
                    provider: _cloneProvider,
                    voiceId: _cloneVoiceId.trim(),
                    stability:
                        _cloneProvider == 'elevenlabs' ? _cloneStability : null,
                    similarity: _cloneProvider == 'elevenlabs'
                        ? _cloneSimilarity
                        : null,
                  );
                });
                widget.options.showAlert?.call(
                  message: 'Voice clone configured!',
                  type: 'success',
                  duration: 2000,
                );
              } else {
                widget.options.showAlert?.call(
                  message: 'Please enter a cloned voice ID',
                  type: 'danger',
                  duration: 2000,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(MediasfuSpacing.md),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? MediasfuColors.accentDark
                    : MediasfuColors.accent,
                borderRadius: BorderRadius.circular(MediasfuBorders.md),
              ),
              child: Text(
                '🎤 Apply Voice Clone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediasfuTypography.bodyMedium.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        // Current clone summary
        if (_voiceCloneConfig != null)
          Container(
            margin: EdgeInsets.only(top: MediasfuSpacing.md),
            padding: EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.success.withOpacity(0.1)
                  : MediasfuColors.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(MediasfuBorders.sm),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.check,
                    size: 12, color: MediasfuColors.success),
                SizedBox(width: MediasfuSpacing.sm),
                Expanded(
                  child: Text(
                    'Clone active: ${_voiceCloneConfig!.provider} / ${_voiceCloneConfig!.voiceId.length > 12 ? '${_voiceCloneConfig!.voiceId.substring(0, 12)}...' : _voiceCloneConfig!.voiceId}',
                    style: TextStyle(
                      color: MediasfuColors.success,
                      fontSize: MediasfuTypography.bodySmall.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildListeningTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose which language to hear translations in. You can set a default or configure per speaker.',
          style: TextStyle(
            color: widget.isDarkMode
                ? MediasfuColors.textMutedDark
                : MediasfuColors.textMuted,
            fontSize: MediasfuTypography.bodySmall.fontSize,
          ),
        ),
        SizedBox(height: MediasfuSpacing.md),
        if (_listenCooldown > 0)
          Container(
            margin: EdgeInsets.only(bottom: MediasfuSpacing.md),
            padding: EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? MediasfuColors.warning.withOpacity(0.15)
                  : MediasfuColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MediasfuBorders.sm),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.clock,
                    size: 14, color: MediasfuColors.warning),
                SizedBox(width: MediasfuSpacing.sm),
                Text(
                  'Wait ${_listenCooldown}s before changing listen language',
                  style: TextStyle(
                    color: MediasfuColors.warning,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _buildModeButton(
                  false, FontAwesomeIcons.users, 'Same for All'),
            ),
            SizedBox(width: MediasfuSpacing.sm),
            Expanded(
              child: _buildModeButton(
                  true, FontAwesomeIcons.sliders, 'Per Speaker'),
            ),
          ],
        ),
        SizedBox(height: MediasfuSpacing.lg),
        if (!_perSpeakerMode) ...[
          Text(
            'Default Language for All Speakers',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textPrimaryDark
                  : MediasfuColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: MediasfuSpacing.sm),
          LanguageDropdown(
            value: _localDefaultListen ??
                (widget.options.islevel == '2' ? 'original' : 'speakerOutput'),
            onChange: (lang) => setState(() => _localDefaultListen =
                (lang == 'original' || lang == 'speakerOutput') ? null : lang),
            languages: _availableListenLanguages,
            isDarkMode: widget.isDarkMode,
            includeOriginal: widget.options.islevel == '2',
            includeSpeakerOutput: true,
            placeholder: "Speaker's Output",
          ),
        ] else ...[
          Text(
            'Configure Per Speaker',
            style: TextStyle(
              color: widget.isDarkMode
                  ? MediasfuColors.textPrimaryDark
                  : MediasfuColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: MediasfuSpacing.md),
          if (_otherParticipants.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(MediasfuSpacing.lg),
                child: Text(
                  'No other participants in the meeting yet.',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ..._otherParticipants.map((p) => SpeakerLanguageRow(
                  speaker: p,
                  selectedLanguage: _localListenPrefs[p.name],
                  onChange: (speakerId, lang) {
                    setState(() {
                      if (lang == 'original' || lang == 'speakerOutput') {
                        _localListenPrefs.remove(speakerId);
                      } else {
                        _localListenPrefs[speakerId] = lang;
                      }
                    });
                  },
                  availableLanguages: _availableListenLanguages,
                  isDarkMode: widget.isDarkMode,
                  isHost: widget.options.islevel == '2',
                )),
        ],

        // Live Subtitles Toggle
        SizedBox(height: MediasfuSpacing.xl),
        Divider(
          color: MediasfuColors.glassBorder(darkMode: widget.isDarkMode),
        ),
        SizedBox(height: MediasfuSpacing.md),
        _buildSubtitlesToggle(),
      ],
    );
  }

  /// Builds the subtitle toggle for showing live captions on video cards
  Widget _buildSubtitlesToggle() {
    return Container(
      padding: EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? MediasfuColors.surfaceElevatedDark
            : MediasfuColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MediasfuBorders.md),
        border: Border.all(
          color: MediasfuColors.glassBorder(darkMode: widget.isDarkMode),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.closedCaptioning,
            size: 20,
            color: _localShowSubtitles
                ? (widget.isDarkMode
                    ? MediasfuColors.accentDark
                    : MediasfuColors.accent)
                : (widget.isDarkMode
                    ? MediasfuColors.textMutedDark
                    : MediasfuColors.textMuted),
          ),
          SizedBox(width: MediasfuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show Subtitles on Video',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: MediasfuTypography.bodyMedium.fontSize,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Display live captions on participant video cards',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? MediasfuColors.textMutedDark
                        : MediasfuColors.textMuted,
                    fontSize: MediasfuTypography.bodySmall.fontSize,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _localShowSubtitles,
            onChanged: (value) {
              setState(() => _localShowSubtitles = value);
              widget.options.updateShowSubtitlesOnCards?.call(value);
            },
            activeColor: widget.isDarkMode
                ? MediasfuColors.accentDark
                : MediasfuColors.accent,
            activeTrackColor: (widget.isDarkMode
                    ? MediasfuColors.accentDark
                    : MediasfuColors.accent)
                .withOpacity(0.5),
            inactiveThumbColor:
                widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            inactiveTrackColor:
                widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(bool isPerSpeaker, IconData icon, String label) {
    final isSelected = _perSpeakerMode == isPerSpeaker;
    return InkWell(
      onTap: () => setState(() => _perSpeakerMode = isPerSpeaker),
      child: Container(
        padding: EdgeInsets.all(MediasfuSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isDarkMode
                  ? MediasfuColors.primaryDark
                  : MediasfuColors.primary)
              : (widget.isDarkMode
                  ? MediasfuColors.surfaceElevatedDark
                  : MediasfuColors.surfaceElevated),
          borderRadius: BorderRadius.circular(MediasfuBorders.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (widget.isDarkMode
                      ? MediasfuColors.textPrimaryDark
                      : MediasfuColors.textPrimary),
            ),
            SizedBox(width: MediasfuSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (widget.isDarkMode
                        ? MediasfuColors.textPrimaryDark
                        : MediasfuColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: MediasfuColors.glassBorder(darkMode: widget.isDarkMode),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PremiumButton(
            label: 'Cancel',
            variant: PremiumButtonVariant.outlined,
            onPressed: widget.options.onClose,
          ),
          SizedBox(width: MediasfuSpacing.md),
          PremiumButton(
            label: _isSaving ? 'Saving...' : 'Apply Changes',
            variant: PremiumButtonVariant.filled,
            onPressed: _isSaving ? null : _handleApply,
            leadingIcon: _isSaving ? null : FontAwesomeIcons.check,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
