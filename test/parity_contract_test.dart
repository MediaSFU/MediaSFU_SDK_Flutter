import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  const roomComponents = <String>[
    'lib/components/mediasfu_components/mediasfu_generic.dart',
    'lib/components/mediasfu_components/mediasfu_broadcast.dart',
    'lib/components/mediasfu_components/mediasfu_chat.dart',
    'lib/components/mediasfu_components/mediasfu_conference.dart',
    'lib/components/mediasfu_components/mediasfu_webinar.dart',
    'lib/components_modern/mediasfu_components/modern_mediasfu_generic.dart',
  ];

  test('all parameter bags expose the pure getter', () {
    for (final path in roomComponents) {
      expect(_source(path), contains('getCurrentParams:'), reason: path);
    }
  });

  test(
    'source publication is deferred and coalesced in every room component',
    () {
      for (final path in roomComponents) {
        final source = _source(path);
        expect(source, contains('_sourcePublishQueued'), reason: path);
        expect(
          source,
          contains('Future<void>.delayed(Duration.zero'),
          reason: path,
        );
        expect(
          RegExp(
            r'updateSpecificState[\s\S]*?_sourcePublishQueued = true;[\s\S]*?Future<void>\.delayed\(Duration\.zero',
          ).hasMatch(source),
          isTrue,
          reason: path,
        );
      }
    },
  );

  test(
    'send transport callbacks re-read and guard the current device twice',
    () {
      final source = _source('lib/consumers/create_send_transport.dart');
      expect(
        RegExp(
          r'device = parameters\.getCurrentParams\(\)\.device;',
        ).allMatches(source).length,
        2,
      );
      expect(
        RegExp(r'if \(device == null\) return;').allMatches(source).length,
        2,
      );
    },
  );

  test('mobile layout corrections survive public/private reconciliation', () {
    final source = _source(
      'lib/components_modern/mediasfu_components/modern_mediasfu_generic.dart',
    );

    expect(
      source,
      contains(
        'final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;',
      ),
    );
    expect(
      RegExp(
        r'color: isIOS\s*\? Colors\.black\.withOpacity\(0\.5\)\s*:\s*Colors\.transparent',
      ).hasMatch(source),
      isTrue,
    );
    expect(
      source,
      contains('final previousWideScreen = this.isWideScreen.value;'),
    );
    expect(
      source,
      contains('onScreenChanges('),
    );
    expect(
      RegExp(
        r'updateWhiteboardEnded[\s\S]*?if \(value && !screenShareActive\)[\s\S]*?updateMainHeightWidth\(0\)',
      ).hasMatch(source),
      isTrue,
    );
    expect(source, contains('whiteboardToolbarOffset'));
  });
}
