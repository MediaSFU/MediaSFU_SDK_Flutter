# MediaSFU Flutter SDK - Platform Setup Guide

This guide provides detailed platform-specific configuration instructions for the MediaSFU Flutter SDK. Follow the instructions for each platform you're targeting.

---

## 📖 Table of Contents

- [Android Setup](#android-setup)
- [iOS Setup](#ios-setup)
- [macOS Setup](#macos-setup)
- [Web Setup](#web-setup)
- [Windows Setup](#windows-setup)
- [Linux Setup](#linux-setup)
- [Optional Features](#optional-features)
  - [Virtual Backgrounds (Android/iOS)](#virtual-backgrounds-androidios)
  - [Image Picker](#image-picker)
  - [Share Functionality](#share-functionality)

---

## Android Setup

### 1. Update Gradle Configuration

Open `android/app/build.gradle` and configure the SDK versions:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 34
        // ... other configurations
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### 2. AndroidManifest Permissions

Open `android/app/src/main/AndroidManifest.xml` and add the required permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Optional: For audio recording features -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
        android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
        android:maxSdkVersion="32" />
    
    <!-- Optional: Bluetooth for audio devices -->
    <uses-permission android:name="android.permission.BLUETOOTH" 
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <application
        android:label="Your App"
        android:icon="@mipmap/ic_launcher">
        <!-- ... activities and other configurations -->
    </application>
</manifest>
```

### 3. ProGuard Rules (Optional)

If you're using ProGuard/R8 for release builds, add to `android/app/proguard-rules.pro`:

```proguard
# WebRTC
-keep class org.webrtc.** { *; }

# MediaSFU
-keep class com.mediasfu.** { *; }

# ML Kit (if using virtual backgrounds)
-keep class com.google.mlkit.** { *; }
```

---

## iOS Setup

### 1. Minimum iOS Platform Version

Open `ios/Podfile` and update the platform version:

```ruby
platform :ios, '12.0'
```

### 2. Info.plist Configuration

Open `ios/Runner/Info.plist` and add the required entries:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other entries ... -->
    
    <!-- Camera and Microphone Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) needs camera access for video calls</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>$(PRODUCT_NAME) needs microphone access for audio calls</string>
    
    <!-- Optional: Photo Library for image picker -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) needs photo library access to select images</string>
    
    <!-- Optional: For background audio -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>voip</string>
    </array>
</dict>
</plist>
```

### 3. Run Pod Install

After configuration, run:

```bash
cd ios
pod install
cd ..
```

---

## macOS Setup

### 1. Minimum macOS Version

Open `macos/Podfile` and update the platform version:

```ruby
platform :osx, '10.15'
```

### 2. Info.plist Configuration

Open `macos/Runner/Info.plist` and add the required entries:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other entries ... -->
    
    <!-- Camera and Microphone Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Camera access is required for video calls</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Microphone access is required for audio calls</string>
</dict>
</plist>
```

### 3. Entitlements Configuration

#### Debug Entitlements

Open `macos/Runner/DebugProfile.entitlements` and add:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    
    <!-- Network Access -->
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    
    <!-- Camera and Microphone -->
    <key>com.apple.security.device.camera</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    
    <!-- Optional: File access for recordings/images -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

#### Release Entitlements

Create or update `macos/Runner/Release.entitlements` with the same content as above.

### 4. Run Pod Install

```bash
cd macos
pod install
cd ..
```

---

## Web Setup

### 1. Secure Context (HTTPS)

**Important**: Browsers require HTTPS for camera and microphone access in production.

- **Development**: `localhost` is treated as a secure context
- **Production**: Deploy your app over HTTPS

### 2. Browser Permissions

The SDK automatically requests camera and microphone permissions. Ensure your web app:

1. Is served over HTTPS (or localhost for development)
2. Handles permission denial gracefully

### 3. CORS Configuration (Self-Hosted Servers)

If you're self-hosting MediaSFU, ensure your server has proper CORS headers:

```
Access-Control-Allow-Origin: your-domain.com
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

### 4. Web-Specific Features

Some features have platform-specific behavior on web:

| Feature | Web Support | Notes |
|---------|-------------|-------|
| Video/Audio | ✅ | Full support |
| Screen Share | ✅ | Browser-dependent UI |
| Virtual Backgrounds | ⚠️ | Limited (no ML Kit) |
| Recording | ✅ | Server-side |
| File Sharing | ✅ | Via browser APIs |

---

## Windows Setup

### 1. Prerequisites

Ensure you have the Windows desktop development prerequisites:

```bash
flutter doctor
```

### 2. Visual Studio

Install Visual Studio 2019 or later with:
- "Desktop development with C++" workload
- Windows 10/11 SDK

### 3. Running on Windows

```bash
flutter run -d windows
```

### 4. Building for Release

```bash
flutter build windows --release
```

---

## Linux Setup

### 1. Prerequisites

Install the required Linux dependencies:

#### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev libstdc++-12-dev \
    libpulse-dev libasound2-dev
```

#### Fedora

```bash
sudo dnf install -y \
    clang cmake ninja-build pkgconfig \
    gtk3-devel xz-devel \
    pulseaudio-libs-devel alsa-lib-devel
```

### 2. Running on Linux

```bash
flutter run -d linux
```

### 3. Building for Release

```bash
flutter build linux --release
```

---

## Optional Features

### Virtual Backgrounds (Android/iOS)

The SDK supports virtual backgrounds using Google ML Kit Selfie Segmentation. This requires an **optional dependency** that you must add manually:

```yaml
# pubspec.yaml - Add for virtual background support (Android/iOS only)
google_mlkit_selfie_segmentation: ^0.8.0
```

#### Android Configuration

Add to `android/app/build.gradle`:

```gradle
android {
    // ... existing config
    
    aaptOptions {
        noCompress "tflite"
    }
}
```

#### iOS Configuration

No additional configuration required - ML Kit is automatically configured via CocoaPods.

#### Usage

Virtual backgrounds are available in the Media Settings Modal. Users can:
- Apply blur backgrounds
- Select from preset images
- Use custom images (with image picker)

> **Note**: Virtual backgrounds are not available on Web, Windows, or Linux platforms. If you don't add the dependency, the feature will gracefully degrade.

---

### Image Picker

The SDK includes `image_picker` for selecting images (profile pictures, chat attachments, custom backgrounds).

#### Android Configuration

Already covered in the main Android setup with storage permissions.

#### iOS Configuration

Already covered in the main iOS setup with `NSPhotoLibraryUsageDescription`.

---

### Share Functionality

The SDK includes `share_plus` for sharing content (meeting links, QR codes).

#### Android Configuration

No additional configuration required.

#### iOS Configuration

No additional configuration required.

---

## Troubleshooting

### Common Issues

#### Android: Camera/Microphone Not Working

1. Check permissions in `AndroidManifest.xml`
2. Ensure `minSdkVersion` is at least 23
3. Test on a physical device (emulator may have issues)

#### iOS: Build Fails

1. Run `cd ios && pod install && cd ..`
2. Clean the build: `flutter clean && flutter pub get`
3. Check minimum iOS version in Podfile

#### macOS: Sandbox Errors

1. Verify all required entitlements are added
2. Ensure both Debug and Release entitlements are configured

#### Web: No Media Access

1. Ensure you're using HTTPS or localhost
2. Check browser console for permission errors
3. Try a different browser

#### All Platforms: Network Issues

1. Check internet connectivity
2. Verify API credentials
3. Check firewall/proxy settings

---

## Quick Reference

### Minimum Versions

| Platform | Minimum Version |
|----------|-----------------|
| Android SDK | 23 |
| iOS | 12.0 |
| macOS | 10.15 |
| Web | Modern browsers |
| Windows | Windows 10 |
| Linux | Modern distros |

### Required Permissions by Platform

| Permission | Android | iOS | macOS | Web |
|------------|---------|-----|-------|-----|
| Camera | ✅ | ✅ | ✅ | ✅ |
| Microphone | ✅ | ✅ | ✅ | ✅ |
| Internet | ✅ | - | ✅ | - |
| Storage | ⚠️ | ⚠️ | ⚠️ | - |

✅ = Required  
⚠️ = Optional (for specific features)  
`-` = Handled automatically

---

## Additional Resources

- [Flutter Platform-Specific Code](https://docs.flutter.dev/platform-integration/platform-channels)
- [MediaSFU Documentation](https://www.mediasfu.com/flutter/)
- [flutter_webrtc Package](https://pub.dev/packages/flutter_webrtc)
- [ML Kit Documentation](https://developers.google.com/ml-kit/vision/selfie-segmentation)

---

<p align="center">
  <strong>Need help? Visit the <a href="https://www.mediasfu.com/forums">MediaSFU Forums</a></strong>
</p>
