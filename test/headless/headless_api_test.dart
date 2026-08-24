import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/components_modern/mediasfu_components/modern_mediasfu_generic.dart';
import 'package:mediasfu_sdk/components/display_components/main_container_component.dart';
import 'package:mediasfu_sdk/methods/utils/headless/headless.dart';
import 'package:mediasfu_sdk/types/types.dart' show Participant;
import 'package:mediasfu_sdk/types/ui_overrides.dart'
    show ContainerStyleOptions;

class _PermissionParams implements MediaPermissionsParameters {
  @override
  String islevel = '1';
  @override
  String member = 'Ada';
  @override
  bool audioOnlyRoom = false;
  @override
  bool recordStarted = false;
  @override
  bool recordResumed = false;
  @override
  bool recordPaused = false;
  @override
  bool recordStopped = false;
  @override
  String recordingMediaOptions = 'video';
  @override
  bool adminRestrictSetting = false;
  @override
  bool panelistsFocused = false;
  @override
  List<Participant> panelists = const [];
  @override
  bool muteOthersMic = false;
  @override
  bool muteOthersCamera = false;
  @override
  String audioSetting = 'allow';
  @override
  String videoSetting = 'allow';
  @override
  String screenshareSetting = 'allow';
}

void main() {
  group('headless permissions', () {
    test('approval is allowed but explicitly marked as requiring approval', () {
      final params = _PermissionParams()..audioSetting = 'approval';
      final permissions = getMediaPermissions(params);
      expect(permissions.microphone.allowed, isTrue);
      expect(permissions.microphone.needsApproval, isTrue);
      expect(permissions.camera.needsApproval, isFalse);
    });

    test('focus mode blocks non-panelist media according to host controls', () {
      final params = _PermissionParams()
        ..panelistsFocused = true
        ..muteOthersMic = true
        ..muteOthersCamera = true;
      final permissions = getMediaPermissions(params);
      expect(permissions.focusModeBlocked, isTrue);
      expect(permissions.microphone.allowed, isFalse);
      expect(permissions.camera.allowed, isFalse);
      expect(permissions.screenShare.allowed, isTrue);
    });

    test('host recording lock applies only to the recorded media kind', () {
      final params = _PermissionParams()
        ..islevel = '2'
        ..recordStarted = true
        ..recordingMediaOptions = 'video';
      final permissions = getMediaPermissions(params);
      expect(permissions.camera.allowed, isFalse);
      expect(permissions.microphone.allowed, isTrue);
    });
  });

  group('container fractions', () {
    test('default to full container', () {
      final options = ModernMediasfuGenericOptions();
      expect(options.containerWidthFraction, 1);
      expect(options.containerHeightFraction, 1);
    });

    test('preserve the old containerStyle API and allow explicit override', () {
      final options = ModernMediasfuGenericOptions(
        containerStyle: ContainerStyleOptions(
          widthFraction: 0.6,
          heightFraction: 0.7,
        ),
        containerWidthFraction: 0.8,
      );
      expect(options.containerWidthFraction, 0.8);
      expect(options.containerHeightFraction, 0.7);
    });

    testWidgets('measure the embedded root against the viewport fractions', (
      tester,
    ) async {
      const evidenceKey = Key('container-fraction-evidence');
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: evidenceKey,
            child: ColoredBox(
              color: Color(0xFFF1F5F9),
              child: Stack(
                children: [
                  MainContainerComponent(
                    options: MainContainerComponentOptions(
                      backgroundColor: Color(0xFF12355B),
                      containerWidthFraction: 0.6,
                      containerHeightFraction: 0.7,
                      children: [],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 440,
                    width: 480,
                    height: 3,
                    child: ColoredBox(color: Color(0xFF0F172A)),
                  ),
                  Positioned(
                    left: 0,
                    top: 430,
                    width: 3,
                    height: 23,
                    child: ColoredBox(color: Color(0xFF0F172A)),
                  ),
                  Positioned(
                    left: 477,
                    top: 430,
                    width: 3,
                    height: 23,
                    child: ColoredBox(color: Color(0xFF0F172A)),
                  ),
                  Positioned(
                    left: 500,
                    top: 0,
                    width: 3,
                    height: 420,
                    child: ColoredBox(color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(MainContainerComponent)),
        const Size(480, 420),
      );
      await expectLater(
        find.byKey(evidenceKey),
        matchesGoldenFile('goldens/container_fractions_800x600.png'),
      );
    });
  });

  group('viewer session', () {
    test(
      'stays outside the room until promotion and releases on stop',
      () async {
        var promoted = false;
        var left = false;
        final viewer = createViewerSession(
          roomName: 'demo-room',
          provider: ViewerSessionProvider(
            join: (roomName, displayName) async => ViewerSessionIdentity(
              viewerId: 'viewer-1',
              roomName: roomName,
              playbackUrl: 'https://example.test/live.m3u8',
            ),
            requestPromotion: (_) async => promoted = true,
            leave: (_) async => left = true,
          ),
        );

        expect((await viewer.start()).phase, ViewerSessionPhase.watching);
        expect(viewer.snapshot.session?.viewerId, 'viewer-1');
        expect(
          (await viewer.requestPromotion()).phase,
          ViewerSessionPhase.requested,
        );
        expect(promoted, isTrue);
        await viewer.stop();
        expect(viewer.snapshot.phase, ViewerSessionPhase.left);
        expect(left, isTrue);
      },
    );

    test('rejects a provider response without a viewer id', () async {
      final viewer = createViewerSession(
        roomName: 'demo-room',
        provider: ViewerSessionProvider(
          join: (roomName, displayName) async =>
              ViewerSessionIdentity(viewerId: '', roomName: roomName),
        ),
      );
      expect((await viewer.start()).phase, ViewerSessionPhase.error);
      expect(viewer.snapshot.error, contains('viewerId'));
    });
  });

  test('read paths do not call the publishing getter', () {
    const readPaths = <String>[
      'lib/components_modern/display_components/modern_pagination.dart',
      'lib/components/display_components/audio_card.dart',
      'lib/components_modern/display_components/modern_audio_card.dart',
      'lib/components/display_components/audio_decibel_check.dart',
      'lib/components_modern/display_components/modern_audio_decibel_check.dart',
    ];
    for (final path in readPaths) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('getUpdatedAllParams()')), reason: path);
      expect(source, contains('getCurrentParams()'), reason: path);
    }
  });
}
