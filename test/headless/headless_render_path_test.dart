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
}
