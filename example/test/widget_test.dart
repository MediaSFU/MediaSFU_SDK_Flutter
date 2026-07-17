import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/components_modern/core/theme/mediasfu_theme.dart';

void main() {
  testWidgets('MediaSFU theme renders Material content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MediasfuTheme.light(),
        home: const Scaffold(body: Text('MediaSFU')),
      ),
    );

    expect(find.text('MediaSFU'), findsOneWidget);
  });
}
