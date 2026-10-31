import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  test('headless branches bypass the full room build methods', () {
    final classicSource = File(
      'lib/components/mediasfu_components/mediasfu_generic.dart',
    ).readAsStringSync();
    final modernSource = File(
      'lib/components_modern/mediasfu_components/modern_mediasfu_generic.dart',
    ).readAsStringSync();

    expect(
      classicSource,
      contains(
        "if (widget.options.returnUI == false) {\n"
        '      if (!validated) return _headlessPreJoin();\n'
        '      return const SizedBox.shrink();',
      ),
    );
    expect(
      modernSource,
      contains(
        "if (!forceStandardUi && widget.options.returnUI == false) {\n"
        '      // Do not enter buildEventRoom for an engine-only mount.',
      ),
    );
  });

  testWidgets('classic headless engine mounts without a room UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediasfuGeneric(
          options: MediasfuGenericOptions(
            returnUI: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MediasfuGeneric), findsOneWidget);
    expect(find.byType(MainContainerComponent), findsNothing);
  });

  testWidgets('modern headless engine mounts without a room UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ModernMediasfuGeneric(
          options: ModernMediasfuGenericOptions(
            returnUI: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ModernMediasfuGeneric), findsOneWidget);
    expect(find.byType(MainContainerComponent), findsNothing);
  });

  // Headless mode has no UI to reach the pre-join page, so the engine must
  // still mount it until the room is validated: it is the only caller of the
  // room callbacks. Without it a backend-proxied headless room never joins.
  final placeholders = Credentials(
    apiUserName: 'client00',
    apiKey: '0000000000000000000000000000000000000000000000000000000000000000',
  );
  JoinMediaSFURoomOptions join() => JoinMediaSFURoomOptions(
        action: 'join',
        meetingID: 's1234567',
        userName: 'host12',
      );
  Future<CreateJoinRoomResult> refuse(void Function() count) async {
    count();
    return CreateJoinRoomResult(
      success: false,
      data: CreateJoinRoomError(error: 'stopped in test'),
    );
  }

  testWidgets('classic headless engine runs the join callback', (
    tester,
  ) async {
    var joins = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediasfuGeneric(
          options: MediasfuGenericOptions(
            returnUI: false,
            credentials: placeholders,
            noUIPreJoinOptionsJoin: join(),
            joinMediaSFURoom: (_) => refuse(() => joins++),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(joins, 1);
    expect(find.byType(MainContainerComponent), findsNothing);
  });

  testWidgets('modern headless engine runs the join callback', (
    tester,
  ) async {
    var joins = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ModernMediasfuGeneric(
          options: ModernMediasfuGenericOptions(
            returnUI: false,
            credentials: placeholders,
            noUIPreJoinOptionsJoin: join(),
            joinMediaSFURoom: (_) => refuse(() => joins++),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(joins, 1);
    expect(find.byType(MainContainerComponent), findsNothing);
  });
}
