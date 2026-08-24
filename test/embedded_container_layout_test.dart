import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/types/types.dart';

void main() {
  testWidgets('all display boundaries use the measured embedded container', (tester) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ComponentSizes? sizes;
    Size? overrideSize;
    var width = 1294.0;

    Widget surface() => MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              height: 700,
              child: MainContainerComponent(
                options: MainContainerComponentOptions(
                  backgroundColor: Colors.black,
                  children: [
                    MainAspectComponent(
                      options: MainAspectComponentOptions(
                        backgroundColor: Colors.black,
                        updateIsWideScreen: (_) {},
                        updateIsMediumScreen: (_) {},
                        updateIsSmallScreen: (_) {},
                        showControls: false,
                        children: [
                          MainScreenComponent(
                            options: MainScreenComponentOptions(
                              mainSize: 0,
                              doStack: false,
                              showControls: false,
                              updateComponentSizes: (value) => sizes = value,
                              containerBuilder: (context, child) {
                                overrideSize = context.dimensions;
                                return child;
                              },
                              children: const [SizedBox.expand()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(surface());
    await tester.pump();
    expect(sizes?.mainWidth, 1294);
    expect(overrideSize?.width, 1294);
    expect(tester.takeException(), isNull);

    width = 1036;
    await tester.pumpWidget(surface());
    await tester.pump();
    expect(sizes?.mainWidth, 1036);
    expect(overrideSize?.width, 1036);
    expect(tester.takeException(), isNull);
  });
}
