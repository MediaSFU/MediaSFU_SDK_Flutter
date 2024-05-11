### 0.0.3

* Cleanup of warnings for static analysis pass.

### 0.0.2

#### Changes

- Removed dependence on `permission_handler` to broaden platform support.
- Updated QR code scanning functionality to utilize `mobile_scanner`.
- Moved QR code scanner implementation to `welcome_page_qrcode.dart`.
- Removed the QR code scanner from the default 'welcome page'.

#### Notes

These updates enhance the MediaSFU Flutter SDK's versatility by eliminating dependency on specific permission handling libraries and integrating a more platform-agnostic QR code scanning solution. Developers can now leverage the SDK across a wider range of platforms while maintaining seamless QR code scanning functionality.
To use the QR code scanner pass the `welcome_page_qrcode.dart` as your `PrejoinPage` option for your event room.

Additionally, an example has been added to demonstrate the usage of the SDK's QR code scanning feature.

### 0.0.1

* Initial release of the MediaSFU Flutter SDK.