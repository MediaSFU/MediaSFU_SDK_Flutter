### 2.1.4

* Bug fix for event types defaulting to 'chat' for no-UI mode.

### 2.1.3

* Bug fix for 'setState' called after dispose for no-UI mode.
* Bug fix for 'MediasfuConference not supporting no-UI mode.

### 2.1.2

* Bug fix for 'MediasfuGeneric' handling of updateSourceParameters.
* Allowed null source parameters for all default views.

### 2.1.1

* README.md update and types_alt.dart file removal.

### 2.1.0

* Added support for the latest version of the MediaSFU server.
* Added no-UI option for the SDK to enable developers to use the SDK without the default UI components.

### 2.0.1

* Minor fix for initial values.

### 2.0.0

* Major refactor of the SDK to support the latest version of the MediaSFU server.
* Support provided for MediaSFU Community Edition.

### 1.0.0

* Major refactor of the SDK to support the latest version of the MediaSFU server.
* Explicit options declaration/requirement for classes.
* Added support for FHD and QHD video resolutions.

### 0.0.7

* Bug fix for interval updates of loudness.

### 0.0.6

* Mini audio player bug fix.

### 0.0.5

1. **Updated flutter_webrtc support**:
   * Enhanced compatibility and performance with the latest version of `flutter_webrtc`.

2. **General bug fixes**:
   * Resolved various issues to improve overall stability and reliability.

3. **Added Polls support**:
   * Introduced functionality to conduct real-time polls during sessions, allowing for instant feedback and interaction.

4. **Added Breakout rooms support**:
   * Enabled the creation of multiple sub-meetings within a single session to facilitate focused group discussions and collaboration.

### 0.0.4

* Minor update in README.md.

### 0.0.3

* Cleanup of warnings for static analysis pass.

### 0.0.2

#### Changes

* Removed dependence on `permission_handler` to broaden platform support.
* Updated QR code scanning functionality to utilize `mobile_scanner`.
* Moved QR code scanner implementation to `welcome_page_qrcode.dart`.
* Removed the QR code scanner from the default 'welcome page'.

#### Notes

These updates enhance the MediaSFU Flutter SDK's versatility by eliminating dependency on specific permission handling libraries and integrating a more platform-agnostic QR code scanning solution. Developers can now leverage the SDK across a wider range of platforms while maintaining seamless QR code scanning functionality.
To use the QR code scanner pass the `welcome_page_qrcode.dart` as your `PrejoinPage` option for your event room.

Additionally, an example has been added to demonstrate the usage of the SDK's QR code scanning feature.

### 0.0.1

* Initial release of the MediaSFU Flutter SDK.
