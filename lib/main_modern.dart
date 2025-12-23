// ignore_for_file: unused_import, unused_local_variable, dead_code

import 'package:flutter/material.dart';

import 'components/misc_components/prejoin_page.dart'
    show Credentials, PreJoinPageOptions;
import 'components_modern/components_modern.dart';
import 'methods/utils/create_room_on_media_sfu.dart' show createRoomOnMediaSFU;
import 'methods/utils/generate_random_messages.dart'
    show GenerateRandomMessagesOptions, generateRandomMessages;
import 'methods/utils/generate_random_participants.dart'
    show GenerateRandomParticipantsOptions, generateRandomParticipants;
import 'methods/utils/generate_random_request_list.dart'
    show GenerateRandomRequestListOptions, generateRandomRequestList;
import 'methods/utils/generate_random_waiting_room_list.dart'
    show generateRandomWaitingRoomList;
import 'methods/utils/join_room_on_media_sfu.dart' show joinRoomOnMediaSFU;
import 'types/types.dart'
    show
        ClickVideoOptions,
        CreateMediaSFURoomOptions,
        EventType,
        MediasfuParameters;

void main() {
  runApp(const MediasfuModernApp());
}

Widget modernCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: GradientCard(
        title: 'Welcome back, ${credentials.apiUserName}',
        subtitle: 'Tap continue to enter the modern experience.',
        child: ElevatedButton(
          onPressed: () => options?.parameters.updateValidated(true),
          child: const Text('Continue'),
        ),
      ),
    ),
  );
}

class MediasfuModernApp extends StatefulWidget {
  const MediasfuModernApp({super.key});

  @override
  State<MediasfuModernApp> createState() => _MediasfuModernAppState();
}

class _MediasfuModernAppState extends State<MediasfuModernApp> {
  final ValueNotifier<MediasfuParameters?> sourceParameters =
      ValueNotifier(null);
  final MediasfuThemeModeNotifier themeNotifier = MediasfuThemeModeNotifier();

  @override
  void initState() {
    super.initState();
    sourceParameters.addListener(_handleSourceParametersChanged);
  }

  @override
  void dispose() {
    sourceParameters.removeListener(_handleSourceParametersChanged);
    sourceParameters.dispose();
    themeNotifier.dispose();
    super.dispose();
  }

  void _handleSourceParametersChanged() {
    _onSourceParametersChanged(sourceParameters.value);
  }

  void _onSourceParametersChanged(MediasfuParameters? parameters) {
    if (parameters == null) return;
    // Reserved for future custom UI bindings.
  }

  void triggerClickVideo() {
    Future.delayed(const Duration(seconds: 5), () {
      sourceParameters.value
          ?.clickVideo(ClickVideoOptions(parameters: sourceParameters.value!));
    });
  }

  @override
  Widget build(BuildContext context) {
    final credentials = Credentials(
      apiUserName: 'yourDevUser',
      apiKey:
          'yourDevApiKey1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    );
    const localLink = 'http://localhost:3000';
    const connectMediaSFU = false;

    final CreateMediaSFURoomOptions noUIPreJoinOptionsCreate =
        CreateMediaSFURoomOptions(
      action: 'create',
      capacity: 10,
      duration: 15,
      eventType: EventType.broadcast,
      userName: 'Prince',
    );

    const bool returnUI = true;

    final ModernMediasfuGenericOptions options = ModernMediasfuGenericOptions(
      credentials: credentials,
      connectMediaSFU: connectMediaSFU,
      localLink: localLink,
      returnUI: returnUI,
      noUIPreJoinOptionsCreate: !returnUI ? noUIPreJoinOptionsCreate : null,
      sourceParameters: !returnUI ? sourceParameters.value : null,
      updateSourceParameters: !returnUI ? _updateSourceParameters : null,
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,
    );

    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'MediaSFU Modern',
          debugShowCheckedModeBanner: false,
          theme: MediasfuTheme.light(),
          darkTheme: MediasfuTheme.dark(),
          themeMode: themeNotifier.mode,
          home: MediasfuModernShell(
            options: options,
            themeNotifier: themeNotifier,
          ),
        );
      },
    );
  }

  void _updateSourceParameters(MediasfuParameters? parameters) {
    sourceParameters.value = parameters;
  }
}

class MediasfuModernShell extends StatelessWidget {
  const MediasfuModernShell({
    super.key,
    required this.options,
    required this.themeNotifier,
  });

  final ModernMediasfuGenericOptions options;
  final MediasfuThemeModeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        final brightness = themeNotifier.mode == ThemeMode.system
            ? MediaQuery.of(context).platformBrightness
            : (themeNotifier.mode == ThemeMode.dark
                ? Brightness.dark
                : Brightness.light);
        final bool isDark = brightness == Brightness.dark;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)]
                  : const [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ModernMediasfuGeneric(options: options),
              ),
              Positioned(
                right: 24,
                top: 24,
                child: GlassmorphicContainer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedIconButton(
                        icon: Icons.auto_mode_rounded,
                        isActive: themeNotifier.mode == ThemeMode.system,
                        tooltip: 'System default',
                        onPressed: () =>
                            themeNotifier.setMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 12),
                      AnimatedIconButton(
                        icon: Icons.light_mode_rounded,
                        isActive: themeNotifier.mode == ThemeMode.light,
                        tooltip: 'Light mode',
                        onPressed: () => themeNotifier.setMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 12),
                      AnimatedIconButton(
                        icon: Icons.dark_mode_rounded,
                        isActive: themeNotifier.mode == ThemeMode.dark,
                        tooltip: 'Dark mode',
                        onPressed: () => themeNotifier.setMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 24,
                child: GradientCard(
                  title: 'Modern UI Layer',
                  subtitle: 'Business logic preserved. Visual layer evolving.',
                  child: Text(
                    'Preview build • Theme synced: '
                    '${themeNotifier.mode.name.toUpperCase()}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
