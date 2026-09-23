import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/consumers/add_videos_grid.dart';

void main() {
  test('single side-panel tile contains during screen sharing', () {
    expect(
      resolveSidePanelForceFullDisplay(
        forceFullDisplay: true,
        screenShareActive: true,
        itemCount: 1,
      ),
      isFalse,
    );
    expect(
      resolveSidePanelForceFullDisplay(
        forceFullDisplay: true,
        screenShareActive: true,
        itemCount: 2,
      ),
      isTrue,
    );
    expect(
      resolveSidePanelForceFullDisplay(
        forceFullDisplay: true,
        screenShareActive: false,
        itemCount: 1,
      ),
      isTrue,
    );
  });
}
