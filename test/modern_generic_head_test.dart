import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  test('attached head keeps standard sidebar and modal routing', () {
    final genericSource = File(
      'lib/components_modern/mediasfu_components/modern_mediasfu_generic.dart',
    ).readAsStringSync();
    final headSource = File(
      'lib/components_modern/mediasfu_components/modern_mediasfu_generic_head.dart',
    ).readAsStringSync();

    expect(
      genericSource,
      contains(
        'widget.options.returnUI != false || _attachedHeadRenderers > 0',
      ),
    );
    expect(
      headSource,
      contains('engine._buildRoomInterface(forceStandardUi: true)'),
    );
  });

  testWidgets(
    'renders the mounted engine standard tree without a second engine',
    (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final options = ModernMediasfuGenericOptions(
        returnUI: false,
        customComponent: ({required parameters}) =>
            ModernMediasfuGenericHead(parameters: parameters),
      );

      await tester.pumpWidget(
        MaterialApp(home: ModernMediasfuGeneric(options: options)),
      );
      await tester.pump();

      expect(find.byType(ModernMediasfuGeneric), findsOneWidget);
      expect(find.byType(ModernMediasfuGenericHead), findsOneWidget);
      expect(find.byType(ModernWelcomePage), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
