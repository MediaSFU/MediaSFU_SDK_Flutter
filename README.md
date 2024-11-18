<p align="center">
  <img src="https://www.mediasfu.com/logo192.png" width="100" alt="MediaSFU Logo">
</p>

<p align="center">
  <a href="https://twitter.com/media_sfu">
    <img src="https://img.icons8.com/color/48/000000/twitter--v1.png" alt="Twitter" style="margin-right: 10px;">
  </a>
  <a href="https://www.mediasfu.com/forums">
    <img src="https://img.icons8.com/color/48/000000/communication--v1.png" alt="Community Forum" style="margin-right: 10px;">
  </a>
  <a href="https://github.com/MediaSFU">
    <img src="https://img.icons8.com/fluent/48/000000/github.png" alt="Github" style="margin-right: 10px;">
  </a>
  <a href="https://www.mediasfu.com/">
    <img src="https://img.icons8.com/color/48/000000/domain--v1.png" alt="Website" style="margin-right: 10px;">
  </a>
  <a href="https://www.youtube.com/channel/UCELghZRPKMgjih5qrmXLtqw">
    <img src="https://img.icons8.com/color/48/000000/youtube--v1.png" alt="Youtube" style="margin-right: 10px;">
  </a>
</p>

MediaSFU offers a cutting-edge streaming experience that empowers users to customize their recordings and engage their audience with high-quality streams. Whether you're a content creator, educator, or business professional, MediaSFU provides the tools you need to elevate your streaming game.

---

# MediaSFU Flutter Package Documentation

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Basic Usage Guide](#basic-usage-guide)
- [Intermediate Usage Guide](#intermediate-usage-guide)
- [Advanced Usage Guide](#advanced-usage-guide)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

# Features <a name="features"></a>

MediaSFU's Flutter SDK comes with a host of powerful features out of the box:

1. **Breakout Rooms**: Create multiple sub-meetings within a single session to enhance collaboration and focus.
2. **Pagination**: Efficiently handle large participant lists with seamless pagination.
3. **Polls**: Conduct real-time polls to gather instant feedback from participants.
4. **Media Access Requests Management**: Manage media access requests with ease to ensure smooth operations
5. **Chat (Direct & Group)**: Facilitate communication with direct and group chat options.
6. **Cloud Recording (track-based)**: Customize recordings with track-based options, including watermarks, name tags, background colors, and more.
7. **Managed Events**: Manage events with features to handle abandoned and inactive participants, as well as enforce time and capacity limits.


# Getting Started <a name="getting-started"></a>

This section will guide users through the initial setup and installation of the Flutter package.

### Documentation Reference

For comprehensive documentation on the available methods, components, and functions, please visit [mediasfu.com](https://www.mediasfu.com/flutter/). This resource provides detailed information for this guide and additional documentation.


## Installation

To install the package using Flutter, follow the instructions below:

1. Add the `mediasfu_sdk` package to your project by running the following command:

    ```bash
    flutter pub add mediasfu_sdk
    ```

2. **Obtain an API key from MediaSFU.** You can get your API key by signing up or logging into your account at [mediasfu.com](https://www.mediasfu.com/).

<div style="background-color:#f0f0f0; padding: 5px; border-radius: 5px;">
  <h5 style="color:#d9534f;">Important:</h5>
  <p style="font-size: 1.2em; color:black;">You must obtain an API key from <a href="https://www.mediasfu.com/">mediasfu.com</a> to use this package.</p>
</div>

### 3. Configure Your Project

To ensure that your Flutter app has the necessary permissions and configurations for camera, microphone, and network access on both iOS and Android platforms, follow the detailed steps below.

#### iOS Setup

1. **Minimum iOS Platform Version**

   - Navigate to your `ios/Podfile` located in your project's iOS directory.
   - Find the line specifying the iOS platform version.
   - Update the minimum iOS platform version to `12.0`:

     ```ruby
     platform :ios, '12.0'
     ```

2. **Info.plist Updates**

   - Open your `Info.plist` file located at `<project root>/ios/Runner/Info.plist`.
   - Add the following entries to allow camera and microphone usage:

     ```xml
     <key>NSCameraUsageDescription</key>
     <string>$(PRODUCT_NAME) Camera Usage</string>
     <key>NSMicrophoneUsageDescription</key>
     <string>$(PRODUCT_NAME) Microphone Usage</string>
     ```

---

#### macOS Setup (Optional)

1. **Minimum macOS Version**

   - Navigate to your `macos/Podfile` located in your project's macOS directory.
   - Find the line specifying the macOS platform version.
   - Update the minimum macOS platform version to `10.15` (Catalina) or higher:

     ```ruby
     platform :osx, '10.15'
     ```

2. **Info.plist Updates**

   - Open your `macos/Runner/Info.plist` file located at `<project root>/macos/Runner/Info.plist`.
   - Add the following entries to allow camera and microphone usage:

     ```xml
     <key>NSCameraUsageDescription</key>
     <string>Camera access is required for video calls</string>
     <key>NSMicrophoneUsageDescription</key>
     <string>Microphone access is required for audio calls</string>
     ```

3. **Entitlements Configuration**

   - Create a new file named `Release.entitlements` in your `macos/Runner` directory if it doesn't already exist.
   - Add the following entries to `Release.entitlements` to allow your app to access the camera, microphone, and open outgoing network connections:

     ```xml
     <key>com.apple.security.network.server</key>
     <true/>
     <key>com.apple.security.network.client</key>
     <true/>
     <key>com.apple.security.device.camera</key>
     <true/>
     <key>com.apple.security.device.microphone</key>
     <true/>
     ```

#### Android Setup

1. **Update Gradle Configuration**

   - Open the `build.gradle` file located at `<project root>/android/app/build.gradle`.
   - Ensure the following SDK versions are set:

     ```gradle
     android {
         compileSdkVersion 33
         defaultConfig {
             minSdkVersion 23
             targetSdkVersion 33
             // Other configurations...
         }
         compileOptions {
             sourceCompatibility JavaVersion.VERSION_1_8
             targetCompatibility JavaVersion.VERSION_1_8
         }
     }
     ```

2. **AndroidManifest Permissions**

   - Open the `AndroidManifest.xml` file located at `<project root>/android/app/src/main/AndroidManifest.xml`.
   - Add the following permissions to allow camera, microphone, and network access:

     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     <uses-permission android:name="android.permission.CAMERA" />
     <uses-permission android:name="android.permission.RECORD_AUDIO" />
     <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
     <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
     <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
     <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
     <uses-permission android:name="android.permission.WAKE_LOCK" />
     ```

   - If your app requires Bluetooth functionality, add these permissions:

     ```xml
     <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
     <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
     <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
     ```

3. **Enable Java 8 Compatibility**

   - Ensure your app is compatible with Java 8 by adding the following code block to the `android` section of your `build.gradle`:

     ```gradle
     android {
         //...
         compileOptions {
             sourceCompatibility JavaVersion.VERSION_1_8
             targetCompatibility JavaVersion.VERSION_1_8
         }
     }
     ```

#### Web Setup (Optional)

If you are targeting **Flutter Web**, ensure you have proper configurations for camera and microphone access:

1. **Secure Context**

   - Use a secure context (HTTPS) to ensure that browser permissions for camera and microphone are handled correctly.

2. **Browser Permissions**

   - Ensure that your web application requests and handles the necessary permissions for camera and microphone access.

By following these steps, you ensure that your Flutter app has the necessary permissions and configurations for camera, microphone, and network access on both iOS and Android platforms.

# Basic Usage Guide <a name="basic-usage-guide"></a>

A basic guide on how to use the package for common tasks.

This section will guide users through the initial setup and installation of the Flutter package.

This guide provides a basic overview of how to set up and use the `mediasfu_sdk` module for common tasks across platforms.

### Initial Setup and Installation

1. **Add Dependency**

   Add `mediasfu_sdk` to your `pubspec.yaml`:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     mediasfu_sdk: ^1.0.0
   ```

2. **Install Packages**

   Run the following command to install the dependencies:

   ```bash
   flutter pub get
   ```

### Post-Installation

After installing the dependencies, ensure that you have configured your project correctly for both iOS and Android platforms. Follow the [Configuration](#configuration) section below to set up the necessary permissions and settings.

## Introduction

MediaSFU is a 2-page application consisting of a prejoin/welcome page and the main events room page. This guide will walk you through the basic usage of the module for setting up these pages.

### Documentation Reference

For comprehensive documentation on the available methods, components, and functions, please visit [mediasfu.com](https://www.mediasfu.com/flutter/). This resource provides detailed information for this guide and additional documentation.

## Prebuilt Event Rooms

MediaSFU provides prebuilt event rooms for various purposes. These rooms are rendered as full pages and can be easily imported and used in your application. Here are the available prebuilt event rooms:

1. **MediasfuGeneric**: A generic event room suitable for various types of events.
2. **MediasfuBroadcast**: A room optimized for broadcasting events.
3. **MediasfuWebinar**: Specifically designed for hosting webinars.
4. **MediasfuConference**: Ideal for hosting conferences.
5. **MediasfuChat**: A room tailored for interactive chat sessions.

Users can easily pick an interface and render it in their app.

If no API credentials are provided, a default home page will be displayed where users can scan or manually enter the event details.

To use these prebuilt event rooms, simply import them into your application:

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart';
```

---

## Simplest Usage

The simplest way to use MediaSFU is by directly rendering a predefined event room component, such as `MediasfuGeneric`. This allows you to quickly integrate real-time communication features without extensive configuration.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   // Pass the MediasfuGenericOptions to the MediasfuGeneric component
    final MediasfuGenericOptions options = MediasfuGenericOptions(
    );

    return MaterialApp(
      title: 'Mediasfu Generic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(options: options),
    );
  }
}
```

## Programmatically Fetching Tokens

If you prefer to fetch the required tokens programmatically without visiting MediaSFU's website, you can use the PreJoinPage component and pass your credentials as part of the options.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mediasfu account credentials
    // Replace 'your_api_username' and 'your_api_key' with your actual credentials
    final credentials = Credentials(
      apiUserName: 'your_api_username',
      apiKey: 'your_api_key',
    );

    final MediasfuGenericOptions options = MediasfuGenericOptions(
      credentials: credentials,
    );

    return MaterialApp(
      title: 'Mediasfu Generic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(options: options),
    );
  }
}
```

<div style="text-align: center;">

### Preview of Welcome Page

<img src="https://mediasfu.com/images/prejoin.png" alt="Preview of Welcome Page" title="Welcome Page" style="max-height: 500px;">

<!-- Add a blank line for spacing -->
&nbsp;

### Preview of Prejoin Page

<img src="https://mediasfu.com/images/prejoin3.png" alt="Preview of Prejoin Page" title="Prejoin Page" style="max-height: 500px;">

</div>


## Custom Welcome/Prejoin Page

Alternatively, you can design your own welcome/prejoin page to tailor the user experience to your application's needs. The primary function of this page is to fetch user tokens from MediaSFU's API and establish a connection using the returned link if the credentials are valid.

### Passing a Custom Widget

MediaSFU allows you to pass a custom widget to replace the default prejoin page. This flexibility enables you to design a personalized interface that aligns with your app's branding and user flow.

### Implementing a Custom Prejoin Page

To implement a custom prejoin page, follow these steps:

#### Step 1: Define Your Custom Prejoin Page Widget

Create a custom widget that defines the UI and behavior of your prejoin page. This widget should interact with the provided parameters to handle user input and establish connections.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

/// A custom pre-join page widget that can be used instead of the default Mediasfu pre-join page.
///
/// This widget displays a personalized welcome message and includes a button to proceed to the session.
///
/// **Note:** Ensure this widget is passed to [MediasfuGenericOptions] only when you intend to use a custom pre-join page.
Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Welcome to Mediasfu'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello, ${credentials.apiUserName}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Get ready to join your session.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Proceed to the session by updating the validation status
              options?.updateValidated(true);
            },
            child: const Text('Join Now'),
          ),
        ],
      ),
    ),
  );
}
```
#### Step 2: Integrate the Custom Prejoin Page into Your Application

Update your main application widget to utilize the custom prejoin page by passing it to the `MediasfuGenericOptions`.

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget for MediaSFU.
///
/// This widget initializes the necessary credentials and configuration for the MediaSFU application,
/// including options for using seed data to generate random participants and messages.
/// It allows selecting different event types such as broadcast, chat, webinar, and conference.
class MyApp extends StatelessWidget {
  /// Constructs a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaSFU account credentials
    // Replace 'your_api_username' and 'your_api_key' with your actual credentials
    final credentials = Credentials(
      apiUserName: 'your_api_username',
      apiKey: 'your_api_key',
    );

    
    // === Main Activated Example ===
    // Default to MediasfuGeneric with credentials
    // This will render the pre-join page requiring credentials
    final MediasfuGenericOptions options = MediasfuGenericOptions(
      credentials: credentials,

      preJoinPageWidget: (
          {PreJoinPageOptions? options, required Credentials credentials}) {
        return myCustomPreJoinPage(
          options: options,
          credentials: credentials,
        );
      },

    );

    return MaterialApp(
      title: 'Mediasfu Generic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(options: options),
    );
  }
}
```
---

### Mediasfu Prejoin Page Core Parts

The **default prejoin page** included in the `mediasfu_sdk` package implements the logic for:

1. **Connection Validation**:
   - Ensures valid credentials are provided.
   - Implements rate-limiting to prevent abuse.
2. **Room Creation & Joining**:
   - Supports creating new rooms or joining existing ones.
   - Makes requests to MediaSFU’s backend API.
3. **Socket Connection**:
   - Establishes a socket connection to MediaSFU servers upon successful validation.
4. **Alerts & Error Handling**:
   - Displays alerts for invalid credentials, rate limits, and other errors.

Core logic within the default `PreJoinPage` includes:

```dart
class PreJoinPage extends StatelessWidget {
  final PreJoinPageOptions? options;
  final Credentials credentials;

  PreJoinPage({required this.options, required this.credentials});

  @override
  Widget build(BuildContext context) {
    // Core logic and integration
    // Includes validation, API calls, and socket connection

    return Container(); // Default UI, replaceable with a custom widget
  }
}
```

By passing your own widget as shown earlier, you can override this default behavior while retaining the logic and functionality provided by the `PreJoinPageOptions` and `MediasfuGenericOptions`. This ensures your app's custom design seamlessly integrates with MediaSFU's backend.

### IP Blockage Warning And Local UI Development

Entering the event room without the correct credentials may result in IP blockage, as the page automatically attempts to connect with MediaSFU servers, which rate limit bad requests based on IP address.

If users attempt to enter the event room without valid credentials or tokens, it may lead to IP blockage due to MediaSFU servers' rate limiting mechanism. To avoid unintentional connections to MediaSFU servers during UI development, users can pass the `useLocalUIMode` parameter as `true`.

In this mode, the package will operate locally without making requests to MediaSFU servers. However, to render certain UI elements such as messages, participants, requests, etc., users may need to provide seed data. They can achieve this by importing random data generators and passing the generated data to the event room component.

### Example for Broadcast Room

```dart
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart'

void main() {
  runApp(const MyApp());
}

/// A custom pre-join page widget that can be used instead of the default Mediasfu pre-join page.
///
/// This widget displays a personalized welcome message and includes a button to proceed to the session.
///
/// **Note:** Ensure this widget is passed to [MediasfuBroadcastOptions] only when you intend to use a custom pre-join page.

// Uncomment the following lines to use a custom pre-join page

Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Welcome to Mediasfu'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello, ${credentials.apiUserName}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Get ready to join your session.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Proceed to the session by updating the validation status
              options!.updateValidated(true);
            },
            child: const Text('Join Now'),
          ),
        ],
      ),
    ),
  );
}

/// The main application widget for MediaSFU.
///
/// This widget initializes the necessary credentials and configuration for the MediaSFU application,
/// including options for using seed data to generate random participants and messages.
/// It allows selecting different event types such as broadcast, chat, webinar, and conference.
class MyApp extends StatelessWidget {
  /// Constructs a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mediasfu account credentials
    // Replace 'your_api_username' and 'your_api_key' with your actual credentials
    final credentials = Credentials(
      apiUserName: 'your_api_username',
      apiKey: 'your_api_username',
    );
    // Whether to use seed data for generating random participants and messages
    // Set to true if you want to run the application in local UI mode with seed data

    //NOTE: Seed data usage is unstable and may cause the application to crash due to the large amount of null values

    const bool useSeed = false;
    SeedData? seedData;

    // Event type ('broadcast', 'chat', 'webinar', 'conference')
    // Set this to match the component you are using
    // Uncomment and set the desired event type
    // const EventType eventType = EventType.broadcast;

    /*
    // If using seed data, generate random participants, messages, requests, and waiting room lists
    if (useSeed) {
      // Name of the member
      const String memberName = 'Prince';

      // Name of the host
      const String hostName = 'Fred';

      // Generate random participants
      final participants = generateRandomParticipants(
        GenerateRandomParticipantsOptions(
          member: memberName,
          coHost: '',
          host: hostName,
          forChatBroadcast:
              eventType == EventType.chat || eventType == EventType.broadcast,
        ),
      );

      // Generate random messages
      final messages = generateRandomMessages(
        GenerateRandomMessagesOptions(
          participants: participants,
          member: memberName,
          host: hostName,
        ),
      );

      // Generate random requests
      final requests = generateRandomRequestList(
        GenerateRandomRequestListOptions(
          participants: participants,
          hostName: memberName,
          coHostName: '',
          numberOfRequests: 3,
        ),
      );

      // Generate random waiting list
      final waitingList = generateRandomWaitingRoomList();

      // Assign generated data to seedData
      seedData = SeedData(
        participants: participants,
        messages: messages,
        requests: requests,
        waitingList: waitingList,
        member: memberName,
        host: hostName,
        eventType: eventType,
      );
    }
    */

    // Whether to use local UI mode; prevents making requests to the Mediasfu servers during UI development
    const bool useLocalUIMode = useSeed;

    // === Main Activated Example ===
    // Default to MediasfuBroadcast with credentials
    // This will render the pre-join page requiring credentials
    final MediasfuBroadcastOptions options = MediasfuBroadcastOptions(
      credentials: credentials,
      // Uncomment the following lines to use a custom pre-join page

      /*
      preJoinPageWidget: (
          {PreJoinPageOptions? options, required Credentials credentials}) {
        return myCustomPreJoinPage(
          credentials: credentials,
        );
      },
      */

      // Uncomment the following lines to enable local UI mode with seed data
      /*
      useLocalUIMode: useLocalUIMode,
      useSeed: useSeed,
      seedData: seedData,
      */
    );

    return MaterialApp(
      title: 'Mediasfu Broadcast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuBroadcast(options: options),
    );

    // === Alternative Use Cases ===
    // Uncomment the desired block to use a different Mediasfu component

    /*
    // Simple Use Case (Welcome Page)
    // Renders the default welcome page
    // No additional inputs required
    return MaterialApp(
      title: 'Mediasfu Welcome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuBroadcast(),
    );
    */

    /*
    // Use Case with Pre-Join Page (Credentials Required)
    // Uses a pre-join page that requires users to enter credentials
    return MaterialApp(
      title: 'Mediasfu Pre-Join',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuBroadcast(
        options: MediasfuBroadcastOptions(
          preJoinPageWidget: PreJoinPage(),
          credentials: credentials,
        ),
      ),
    );
    */

    /*
    // Use Case with Local UI Mode (Seed Data Required)
    // Runs the application in local UI mode using seed data
    return MaterialApp(
      title: 'Mediasfu Local UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuBroadcast(
        options: MediasfuBroadcastOptions(
          useLocalUIMode: true,
          useSeed: true,
          seedData: seedData!,
        ),
      ),
    );
    */
  }
}
```

### Example for Generic View

```dart
import 'package:mediasfu_sdk/mediasfu_sdk.dart'

void main() {
  runApp(const MyApp());
}

/// A custom pre-join page widget that can be used instead of the default Mediasfu pre-join page.
///
/// This widget displays a personalized welcome message and includes a button to proceed to the session.
///
/// **Note:** Ensure this widget is passed to [MediasfuGenericOptions] only when you intend to use a custom pre-join page.

// Uncomment the following lines to use a custom pre-join page

Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Welcome to Mediasfu'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello, ${credentials.apiUserName}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Get ready to join your session.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Proceed to the session by updating the validation status
              options!.updateValidated(true);
            },
            child: const Text('Join Now'),
          ),
        ],
      ),
    ),
  );
}

/// The main application widget for MediaSFU.
///
/// This widget initializes the necessary credentials and configuration for the MediaSFU application,
/// including options for using seed data to generate random participants and messages.
/// It allows selecting different event types such as broadcast, chat, webinar, and conference.
class MyApp extends StatelessWidget {
  /// Constructs a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mediasfu account credentials
    // Replace 'your_api_username' and 'your_api_key' with your actual credentials
    final credentials = Credentials(
      apiUserName: 'your_api_username',
      apiKey: 'your_api_username',
    );
    // Whether to use seed data for generating random participants and messages
    // Set to true if you want to run the application in local UI mode with seed data

    //NOTE: Seed data usage is unstable and may cause the application to crash due to the large amount of null values

    const bool useSeed = false;
    SeedData? seedData;

    // Event type ('broadcast', 'chat', 'webinar', 'conference')
    // Set this to match the component you are using
    // Uncomment and set the desired event type
    // const EventType eventType = EventType.webinar;

    /*
    // If using seed data, generate random participants, messages, requests, and waiting room lists
    if (useSeed) {
      // Name of the member
      const String memberName = 'Prince';

      // Name of the host
      const String hostName = 'Fred';

      // Generate random participants
      final participants = generateRandomParticipants(
        GenerateRandomParticipantsOptions(
          member: memberName,
          coHost: '',
          host: hostName,
          forChatBroadcast:
              eventType == EventType.chat || eventType == EventType.broadcast,
        ),
      );

      // Generate random messages
      final messages = generateRandomMessages(
        GenerateRandomMessagesOptions(
          participants: participants,
          member: memberName,
          host: hostName,
        ),
      );

      // Generate random requests
      final requests = generateRandomRequestList(
        GenerateRandomRequestListOptions(
          participants: participants,
          hostName: memberName,
          coHostName: '',
          numberOfRequests: 3,
        ),
      );

      // Generate random waiting list
      final waitingList = generateRandomWaitingRoomList();

      // Assign generated data to seedData
      seedData = SeedData(
        participants: participants,
        messages: messages,
        requests: requests,
        waitingList: waitingList,
        member: memberName,
        host: hostName,
        eventType: eventType,
      );
    }
    */

    // Whether to use local UI mode; prevents making requests to the Mediasfu servers during UI development
    const bool useLocalUIMode = useSeed;

    // === Main Activated Example ===
    // Default to MediasfuGeneric with credentials
    // This will render the pre-join page requiring credentials
    final MediasfuGenericOptions options = MediasfuGenericOptions(
      credentials: credentials,
      // Uncomment the following lines to use a custom pre-join page

      /*
      preJoinPageWidget: (
          {PreJoinPageOptions? options, required Credentials credentials}) {
        return myCustomPreJoinPage(
          credentials: credentials,
        );
      },
      */

      // Uncomment the following lines to enable local UI mode with seed data
      /*
      useLocalUIMode: useLocalUIMode,
      useSeed: useSeed,
      seedData: seedData,
      */
    );

    return MaterialApp(
      title: 'Mediasfu Generic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(options: options),
    );

    // === Alternative Use Cases ===
    // Uncomment the desired block to use a different Mediasfu component

    /*
    // Simple Use Case (Welcome Page)
    // Renders the default welcome page
    // No additional inputs required
    return MaterialApp(
      title: 'Mediasfu Welcome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(),
    );
    */

    /*
    // Use Case with Pre-Join Page (Credentials Required)
    // Uses a pre-join page that requires users to enter credentials
    return MaterialApp(
      title: 'Mediasfu Pre-Join',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(
        options: MediasfuGenericOptions(
          preJoinPageWidget: PreJoinPage(),
          credentials: credentials,
        ),
      ),
    );
    */

    /*
    // Use Case with Local UI Mode (Seed Data Required)
    // Runs the application in local UI mode using seed data
    return MaterialApp(
      title: 'Mediasfu Local UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(
        options: MediasfuGenericOptions(
          useLocalUIMode: true,
          useSeed: true,
          seedData: seedData!,
        ),
      ),
    );
    */

    /*
    // MediasfuBroadcast Component
    // Uncomment to use the broadcast event type
    return MaterialApp(
      title: 'Mediasfu Broadcast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuBroadcast(
        credentials: credentials,
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: useSeed ? seedData! : SeedData(),
      ),
    );
    */

    /*
    // MediasfuChat Component
    // Uncomment to use the chat event type
    return MaterialApp(
      title: 'Mediasfu Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuChat(
        credentials: credentials,
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: useSeed ? seedData! : SeedData(),
      ),
    );
    */

    /*
    // MediasfuWebinar Component
    // Uncomment to use the webinar event type
    return MaterialApp(
      title: 'Mediasfu Webinar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuWebinar(
        credentials: credentials,
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: useSeed ? seedData! : SeedData(),
      ),
    );
    */

    /*
    // MediasfuConference Component
    // Uncomment to use the conference event type
    return MaterialApp(
      title: 'Mediasfu Conference',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuConference(
        credentials: credentials,
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: useSeed ? seedData! : SeedData(),
      ),
    );
    */
  }
}

```

In the provided examples, users can set `useLocalUIMode` to `true` during UI development to prevent unwanted connections to MediaSFU servers. Additionally, they can generate seed data for rendering UI components locally by using random data generators provided by the package.

### Local UI Development in MediaSFU

During local UI development, the MediaSFU view is designed to be responsive to changes in screen size and orientation, adapting its layout accordingly. However, since UI changes are typically linked to communication with servers, developing the UI locally might result in less responsiveness due to the lack of real-time data updates. To mitigate this, users can force trigger changes in the UI by rotating the device, resizing the window, or simulating server responses by clicking on buttons within the page.

While developing locally, users may encounter occasional error warnings as the UI attempts to communicate with the server. These warnings can be safely ignored, as they are simply indicative of unsuccessful server requests in the local development environment.

> **Note:** this mode is experimental and have numerous null values that may cause the application to crash but it is useful for testing purposes.


# Intermediate Usage Guide <a name="intermediate-usage-guide"></a>

Expands on the basic usage, covering more advanced features and scenarios.

### Intermediate Usage Guide

In the Intermediate Usage Guide, we'll explore the core components and functionalities of the MediaSFU package, focusing on media display, controls, and modal interactions. **Click on any listed component/method to open the full documentation.**

#### Core Components Overview

The main items displayed on an event page are media components (such as video, audio, and blank cards) and control components (for pagination, navigation, etc.).

##### Media Display Components:

> ##### **Media Display Components**

| Component Name | Description |
|----------------|-------------|
| **[MainAspectComponent](https://www.mediasfu.com/flutter/components_display_components_main_aspect_component/MainAspectComponent-class)** | Serves as a container for the primary aspect of the user interface, typically containing the main content or focus of the application. |
| **[MainScreenComponent](https://www.mediasfu.com/flutter/components_display_components_main_screen_component/MainScreenComponent-class)** | Responsible for rendering the main screen layout of the application, providing the foundation for displaying various elements and content. |
| **[MainGridComponent](https://www.mediasfu.com/flutter/components_display_components_main_grid_component/MainGridComponent-class)** | Crucial part of the user interface, organizing and displaying primary content or elements in a grid layout format. |
| **[SubAspectComponent](https://www.mediasfu.com/flutter/components_display_components_sub_aspect_component/SubAspectComponent-class)** | Acts as a secondary container within the user interface, often housing additional elements or controls related to the main aspect. |
| **[MainContainerComponent](https://www.mediasfu.com/flutter/components_display_components_main_container_component/MainContainerComponent-class)** | Primary container for the application's content, encapsulating all major components and providing structural organization. |
| **[OtherGridComponent](https://www.mediasfu.com/flutter/components_display_components_other_grid_component/OtherGridComponent-class)** | Complements the Main Grid Component by offering additional grid layouts, typically used for displaying secondary or auxiliary content. |

---

> ##### **Control Components**

| Component Name | Description |
|----------------|-------------|
| **[ControlButtonsComponent](https://www.mediasfu.com/flutter/components_display_components_control_buttons_component/ControlButtonsComponent-class)** | Comprises a set of buttons or controls used for navigating, interacting, or managing various aspects of the application's functionality. |
| **[ControlButtonsAltComponent](https://www.mediasfu.com/flutter/components_display_components_control_buttons_alt_component/ControlButtonsAltComponent-class)** | Provides alternative button configurations or styles for controlling different aspects of the application. |
| **[ControlButtonsComponent Touch](https://www.mediasfu.com/flutter/components_display_components_control_buttons_component_touch/ControlButtonsComponentTouch-class)** | Specialized component designed for touch-enabled devices, offering floating buttons or controls for intuitive interaction with the application's features. |

---
These components collectively contribute to the overall user interface, facilitating navigation, interaction, and content display within the application.

> ##### **Modal Components**

| Modal Component | Description |
|-----------------|-------------|
| **[LoadingModal](https://www.mediasfu.com/flutter/components_display_components_loading_modal/LoadingModal-class)** | Modal for displaying loading indicator during data fetching or processing. |
| **[MainAspectComponent](https://www.mediasfu.com/flutter/components_display_components_main_aspect_component/MainAspectComponent-class)** | Component responsible for displaying the main aspect of the event page. |
| **[ControlButtonsComponent](https://www.mediasfu.com/flutter/components_display_components_control_buttons_component/ControlButtonsComponent-class)** | Component for displaying control buttons such as pagination controls. |
| **[ControlButtonsAltComponent](https://www.mediasfu.com/flutter/components_display_components_control_buttons_alt_component/ControlButtonsAltComponent-class)** | Alternate control buttons component for specific use cases. |
| **[ControlButtonsComponentTouch](https://www.mediasfu.com/flutter/components_display_components_control_buttons_component_touch/ControlButtonsComponentTouch-class)** | Touch-enabled control buttons component for mobile devices. |
| **[OtherGridComponent](https://www.mediasfu.com/flutter/components_display_components_other_grid_component/OtherGridComponent-class)** | Component for displaying additional grid elements on the event page. |
| **[MainScreenComponent](https://www.mediasfu.com/flutter/components_display_components_main_screen_component/MainScreenComponent-class)** | Component for rendering the main screen content of the event. |
| **[MainGridComponent](https://www.mediasfu.com/flutter/components_display_components_main_grid_component/MainGridComponent-class)** | Main grid component for displaying primary event content. |
| **[SubAspectComponent](https://www.mediasfu.com/flutter/components_display_components_sub_aspect_component/SubAspectComponent-class)** | Component for displaying secondary aspects of the event page. |
| **[MainContainerComponent](https://www.mediasfu.com/flutter/components_display_components_main_container_component/MainContainerComponent-class)** | Main container component for the event page content. |
| **[AlertComponent](https://www.mediasfu.com/flutter/components_display_components_alert_component/AlertComponent-class)** | Modal for displaying alert messages to the user. |
| **[MenuModal](https://www.mediasfu.com/flutter/components_menu_components_menu_modal/MenuModal-class)** | Modal for displaying a menu with various options. |
| **[RecordingModal](https://www.mediasfu.com/flutter/components_recording_components_recording_modal/RecordingModal-class)** | Modal for managing recording functionality during the event. |
| **[RequestsModal](https://www.mediasfu.com/flutter/components_requests_components_requests_modal/RequestsModal-class)** | Modal for handling requests from participants during the event. |
| **[WaitingRoomModal](https://www.mediasfu.com/flutter/components_waiting_components_waiting_modal/WaitingRoomModal-class)** | Modal for managing waiting room functionality during the event. |
| **[DisplaySettingsModal](https://www.mediasfu.com/flutter/components_display_settings_components_display_settings_modal/DisplaySettingsModal-class)** | Modal for adjusting display settings during the event. |
| **[EventSettingsModal](https://www.mediasfu.com/flutter/components_event_settings_components_event_settings_modal/EventSettingsModal-class)** | Modal for configuring event settings. |
| **[CoHostModal](https://www.mediasfu.com/flutter/components_co_host_components_co_host_modal/CoHostModal-class)** | Modal for managing co-host functionality during the event. |
| **[ParticipantsModal](https://www.mediasfu.com/flutter/components_participants_components_participants_modal/ParticipantsModal-class)** | Modal for displaying participant information and controls. |
| **[MessagesModal](https://www.mediasfu.com/flutter/components_message_components_messages_modal/MessagesModal-class)** | Modal for managing messages and chat functionality during the event. |
| **[MediaSettingsModal](https://www.mediasfu.com/flutter/components_media_settings_components_media_settings_modal/MediaSettingsModal-class)** | Modal for adjusting media settings during the event. |
| **[ConfirmExitModal](https://www.mediasfu.com/flutter/components_exit_components_confirm_exit_modal/ConfirmExitModal-class)** | Modal for confirming exit from the event. |
| **[ConfirmHereModal](https://www.mediasfu.com/flutter/components_misc_components_confirm_here_modal/ConfirmHereModal-class)** | Modal for confirming certain actions or selections. |
| **[ShareEventModal](https://www.mediasfu.com/flutter/components_misc_components_share_event_modal/ShareEventModal-class)** | Modal for sharing the event with others. |
| **[PollModal](https://www.mediasfu.com/flutter/components_polls_components_poll_modal/PollModal-class)** | Modal for conducting polls or surveys during the event. |
| **[WelcomePage](https://www.mediasfu.com/flutter/components_misc_components_welcome_page/WelcomePage-class)** | Serves as the initial page displayed to users upon entering the application for an event. It provides a welcoming interface with relevant information about the event. |
| **[PreJoinPage](https://www.mediasfu.com/flutter/components_misc_components_prejoin_page/PreJoinPage-class)** | The `PreJoinPage` represents the page where users prepare to join the event. It includes functionalities for creating or joining a room, validating credentials, and initializing the connection for the event. |
| **[BreakoutRoomsModal](https://www.mediasfu.com/flutter/components_breakout_components_breakout_rooms_modal/BreakoutRoomsModal-class)** | Modal for managing breakout rooms during the event. |
                         

#### Modal Interactions

Each modal has corresponding functions to trigger its usage:

1. [`launchMenuModal`](https://www.mediasfu.com/flutter/methods_menu_methods_launch_menu_modal/launchMenuModal): Launches the menu modal for settings and configurations.
2. [`launchRecording`](https://www.mediasfu.com/flutter/methods_recording_methods_launch_recording/launchRecording): Initiates the recording modal for recording functionalities.
3. [`startRecording`](https://www.mediasfu.com/flutter/methods_recording_methods_start_recording/startRecording): Starts the recording process.
4. [`confirmRecording`](https://www.mediasfu.com/flutter/methods_recording_methods_confirm_recording/confirmRecording): Confirms and finalizes the recording.
5. [`launchWaiting`](https://www.mediasfu.com/flutter/methods_waiting_methods_launch_waiting/launchWaiting): Opens the waiting room modal for managing waiting room interactions.
6. [`launchCoHost`](https://www.mediasfu.com/flutter/methods_co_host_methods_launch_co_host/launchCoHost): Opens the co-host modal for managing co-host functionalities.
7. [`launchMediaSettings`](https://www.mediasfu.com/flutter/methods_media_settings_methods_launch_media_settings/launchMediaSettings): Launches the media settings modal for adjusting media-related configurations.
8. [`launchDisplaySettings`](https://www.mediasfu.com/flutter/methods_display_settings_methods_launch_display_settings/launchDisplaySettings): Opens the display settings modal for adjusting display configurations.
9. [`launchSettings`](https://www.mediasfu.com/flutter/methods_settings_methods_launch_settings/launchSettings): Initiates the settings modal for general event settings and configurations.
10. [`launchRequests`](https://www.mediasfu.com/flutter/methods_requests_methods_launch_requests/launchRequests): Opens the requests modal for managing user requests.
11. [`launchParticipants`](https://www.mediasfu.com/flutter/methods_participants_methods_launch_participants/launchParticipants): Displays the participants modal for viewing and managing event participants.
12. [`launchMessages`](https://www.mediasfu.com/flutter/methods_message_methods_launch_messages/launchMessages): Opens the messages modal for communication through chat messages.
13. [`launchConfirmExit`](https://www.mediasfu.com/flutter/methods_exit_methods_launch_confirm_exit/launchConfirmExit): Prompts users to confirm before exiting the event.
14. [`launchPoll`](https://www.mediasfu.com/flutter/methods_polls_methods_launch_poll/launchPoll): Opens the poll modal for conducting polls or surveys.
15. [`launchBreakoutRooms`](https://www.mediasfu.com/flutter/methods_breakout_rooms_methods_launch_breakout_rooms/launchBreakoutRooms): Initiates the breakout rooms modal for managing breakout room functionalities.


#### Media Display and Controls

These components facilitate media display and control functionalities:

1. **[Pagination](https://www.mediasfu.com/flutter/components_display_components_pagination/Pagination-class)**: Handles pagination and page switching.
2. **[FlexibleGrid](https://www.mediasfu.com/flutter/components_display_components_flexible_grid/FlexibleGrid-class)**: Renders flexible grid layouts for media display.
3. **[FlexibleVideo](https://www.mediasfu.com/flutter/components_display_components_flexible_video/FlexibleVideo-class)**: Displays videos in a flexible manner within the grid.
4. **[AudioGrid](https://www.mediasfu.com/flutter/components_display_components_audio_grid/AudioGrid-class)**: Renders audio components within the grid layout.

These components enable seamless media presentation and interaction within the event environment, providing users with a rich and immersive experience.

| UI Media Component | Description |
|--------------|-------------|
| **[MeetingProgressTimer](https://www.mediasfu.com/flutter/components_display_components_meeting_progress_timer/MeetingProgressTimer-class)** | Component for displaying a timer indicating the progress of a meeting or event. |
| **[MiniAudio](https://www.mediasfu.com/flutter/components_display_components_mini_audio/MiniAudio-class)** | Component for rendering a compact audio player with basic controls. |
| **[MiniCard](https://www.mediasfu.com/flutter/components_display_components_mini_card/MiniCard-class)** | Component for displaying a minimized card view with essential information. |
| **[AudioCard](https://www.mediasfu.com/flutter/components_display_components_audio_card/AudioCard-class)** | Component for displaying audio content with control elements, details, and audio decibels. |
| **[VideoCard](https://www.mediasfu.com/flutter/components_display_components_video_card/VideoCard-class)** | Component for displaying video content with control elements, details, and audio decibels. |
| **[CardVideoDisplay](https://www.mediasfu.com/flutter/components_display_components_card_video_display/CardVideoDisplay-class)** | Video player component for displaying embedded videos with controls and details. |
| **[MiniAudioPlayer](https://www.mediasfu.com/flutter/methods_utils_mini_audio_player_mini_audio_player/MiniAudioPlayer-class)** | Utility method for playing audio and rendering a mini audio modal when the user is not actively displayed on the page. |

---
With the Intermediate Usage Guide, users can explore and leverage the core components and functionalities of the MediaSFU Package to enhance their event hosting and participation experiences.

Here's a sample import and usage code for a Broadcast screen:

```dart

import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';


class MediasfuBroadcast extends StatefulWidget {
  final MediasfuBroadcastOptions options;

  const MediasfuBroadcast({
    super.key,
    required this.options,
  });

  @override
  _MediasfuBroadcastState createState() => _MediasfuBroadcastState();
}


class _MediasfuBroadcastState extends State<MediasfuBroadcast> {

    //sample details 

    bool validated = false;

    void updateValidated(bool value) {
    setState(() {
      validated = value;
    });

    if (validated) {
      joinAndUpdate().then((value) => null);
    }
  }

  // Room Details
  final ValueNotifier<String> roomName = ValueNotifier(''); // Room name
  final ValueNotifier<String> member = ValueNotifier(''); // Member name
  final ValueNotifier<String> adminPasscode =
      ValueNotifier(''); // Admin passcode
  final ValueNotifier<String> islevel = ValueNotifier("0"); // Level

  //others ...

  
  //Record Button
  List<ButtonTouch> recordButton = [];

  void initializeRecordButton() {
    recordButton = [
      // Record Button
      ButtonTouch(
        icon: Icons.fiber_manual_record,
        active: false,
        onPress: () {
          // Action for the Record button
          launchRecording(
            LaunchRecordingOptions(
                updateIsRecordingModalVisible: updateIsRecordingModalVisible,
                isRecordingModalVisible: isRecordingModalVisible.value,
                stopLaunchRecord: stopLaunchRecord.value,
                canLaunchRecord: canLaunchRecord.value,
                recordingAudioSupport: recordingAudioSupport.value,
                recordingVideoSupport: recordingVideoSupport.value,
                updateCanRecord: updateCanRecord,
                updateClearedToRecord: updateClearedToRecord,
                recordStarted: recordStarted.value,
                recordPaused: recordPaused.value,
                localUIMode: widget.options.useLocalUIMode == true),
          );
        },
        activeColor: const Color.fromARGB(255, 244, 3, 3),
        inActiveColor: const Color.fromARGB(255, 251, 9, 9),
        show: true,
        size: 24,
      ),
    ];
  }



  // Record Buttons
  List<ButtonTouch> recordButtonsTouch = [];

   //Control Buttons Broadcast Events
  List<ButtonTouch> controlBroadcastButtons = [];



  Widget buildEventRoom(BuildContext context) {
  initializeRecordButton();
  initializeRecordButtons();
  initializeControlBroadcastButtons();


    @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Top: true adjusts for iOS status bar, ignores for other platforms
      top: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Makes status bar transparent
          statusBarIconBrightness:
              Brightness.light, // Sets status bar icons to light color
        ),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            // Check if the device is in landscape mode
            isPortrait.value = orientation == Orientation.portrait;
            return Scaffold(
              body: _buildRoomInterface(),
              resizeToAvoidBottomInset: false,
            );
          },
        ),
      ),
    );
  }


    return validated
        ? MainContainerComponent(
            options: MainContainerComponentOptions(
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              children: [
                MainAspectComponent(
                  options: MainAspectComponentOptions(
                    backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                    updateIsWideScreen: updateIsWideScreen,
                    updateIsMediumScreen: updateIsMediumScreen,
                    updateIsSmallScreen: updateIsSmallScreen,
                    defaultFraction: 1 - controlHeight.value,
                    showControls: eventType.value == EventType.webinar ||
                        eventType.value == EventType.conference,
                    children: [
                      ValueListenableBuilder<ComponentSizes>(
                          valueListenable: componentSizes,
                          builder: (context, componentSizes, child) {
                            return MainScreenComponent(
                              options: MainScreenComponentOptions(
                                doStack: true,
                                mainSize: mainHeightWidth,
                                updateComponentSizes: updateComponentSizes,
                                defaultFraction: 1 - controlHeight.value,
                                showControls:
                                    eventType.value == EventType.webinar ||
                                        eventType.value == EventType.conference,
                                children: [
                                  ValueListenableBuilder<GridSizes>(
                                    valueListenable: gridSizes,
                                    builder: (context, gridSizes, child) {
                                      return MainGridComponent(
                                        options: MainGridComponentOptions(
                                          height: componentSizes.mainHeight,
                                          width: componentSizes.mainWidth,
                                          backgroundColor: const Color.fromRGBO(
                                              217, 227, 234, 0.99),
                                          mainSize: mainHeightWidth,
                                          showAspect: mainHeightWidth > 0,
                                          timeBackgroundColor:
                                              recordState == 'green'
                                                  ? Colors.green
                                                  : recordState == 'yellow'
                                                      ? Colors.yellow
                                                      : Colors.red,
                                          meetingProgressTime:
                                              meetingProgressTime.value,
                                          showTimer: true,
                                          children: [
                                            FlexibleVideo(
                                                options: FlexibleVideoOptions(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      217, 227, 234, 0.99),
                                              customWidth:
                                                  componentSizes.mainWidth,
                                              customHeight:
                                                  componentSizes.mainHeight,
                                              rows: 1,
                                              columns: 1,
                                              componentsToRender:
                                                  mainGridStream,
                                              showAspect:
                                                  mainGridStream.isNotEmpty,
                                            )),
                                            ControlButtonsComponentTouch(
                                                options:
                                                    ControlButtonsComponentTouchOptions(
                                              buttons: controlBroadcastButtons,
                                              direction: 'vertical',
                                              showAspect: eventType.value ==
                                                  EventType.broadcast,
                                              location: 'bottom',
                                              position: 'right',
                                            )),
                                            ControlButtonsComponentTouch(
                                                options:
                                                    ControlButtonsComponentTouchOptions(
                                              buttons: recordButton,
                                              direction: 'horizontal',
                                              showAspect: eventType.value ==
                                                      EventType.broadcast &&
                                                  !showRecordButtons.value &&
                                                  islevel.value == '2',
                                              location: 'bottom',
                                              position: 'middle',
                                            )),
                                            ControlButtonsComponentTouch(
                                                options:
                                                    ControlButtonsComponentTouchOptions(
                                              buttons: recordButtonsTouch,
                                              direction: 'horizontal',
                                              showAspect: eventType.value ==
                                                      EventType.broadcast &&
                                                  showRecordButtons.value &&
                                                  islevel.value == '2',
                                              location: 'bottom',
                                              position: 'middle',
                                            )),
                                            AudioGrid(
                                                options: AudioGridOptions(
                                              componentsToRender:
                                                  audioOnlyStreams.value,
                                            )),
                                            ValueListenableBuilder<String>(
                                                valueListenable:
                                                    meetingProgressTime,
                                                builder: (context,
                                                    meetingProgressTime,
                                                    child) {
                                                  return MeetingProgressTimer(
                                                      options:
                                                          MeetingProgressTimerOptions(
                                                    meetingProgressTime:
                                                        meetingProgressTime,
                                                    initialBackgroundColor:
                                                        recordState == 'green'
                                                            ? Colors.green
                                                            : recordState ==
                                                                    'yellow'
                                                                ? Colors.yellow
                                                                : Colors.red,
                                                    showTimer: true,
                                                  ));
                                                }),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
          )
        : widget.options.credentials != null &&
                widget.options.credentials!.apiKey.isNotEmpty &&
                widget.options.credentials!.apiKey != 'your_api_key'
            ? renderpreJoinPageWidget() ?? renderWelcomePage()
            : renderWelcomePage();
}


 Widget _buildRoomInterface() {
    return Stack(
      children: [
        buildEventRoom(context),

        _buildShareEventModal(), // Add Share Event Modal
        _buildRecordingModal(), // Add Recording Modal
        _buildParticipantsModal(), // Add Participants Modal
        _buildMessagesModal(), // Add Messages Modal

        _buildConfirmExitModal(), // Add Confirm Exit Modal

        _buildAlertModal(), // Add Alert Modal
        _buildConfirmHereModal(), // Add Confirm Here Modal
        _buildLoadingModal(), // Add Loading Modal
      ],
    );
  }

      Widget _buildParticipantsModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isParticipantsModalVisible,
      builder: (context, isParticipantsVisible, child) {
        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: filteredParticipants,
          builder: (context, filteredParticipants, child) {
            return ParticipantsModal(
              options: ParticipantsModalOptions(
                backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                isParticipantsModalVisible: isParticipantsVisible,
                onParticipantsClose: () {
                  updateIsParticipantsModalVisible(false);
                },
                participantsCounter: participantsCounter.value,
                onParticipantsFilterChange: onParticipantsFilterChange,
                parameters: mediasfuParameters,
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildConfirmExitModal() {
    return ValueListenableBuilder<bool>(
      valueListenable: isConfirmExitModalVisible,
      builder: (context, isConfirmExitVisible, child) {
        return ConfirmExitModal(
          options: ConfirmExitModalOptions(
            backgroundColor: const Color.fromRGBO(181, 233, 229, 0.97),
            isVisible: isConfirmExitVisible,
            onClose: () {
              updateIsConfirmExitModalVisible(false);
            },
            islevel: islevel.value,
            roomName: roomName.value,
            member: member.value,
            socket: socket.value,
          ),
        );
      },
    );
  }



//other widgets for the modals

}

```

This sample code demonstrates the import and usage of various components and features for a Broadcast screen, including rendering different UI components based on the validation state, handling socket connections, displaying video streams, controlling recording, and managing component sizes.

Here's a sample usage of the control button components as used above:

```dart
    void initializeRecordButtons() {
    recordButtons = [
      // Play/Pause Button
      AltButton(
        // name: Pause,
        icon: Icons.play_circle_filled,
        active: !recordPaused.value,
        onPress: () => updateRecording(UpdateRecordingOptions(
          parameters: mediasfuParameters,
        )),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        alternateIcon: Icons.pause_circle_filled,
        show: true,
      ),
      // Stop Button
      AltButton(
        // name: Stop,
        icon: Icons.stop_circle,
        active: false,
        onPress: () => stopRecording(
          StopRecordingOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.black,
        show: true,
      ),
      // Timer Display
      AltButton(
        customComponent: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.all(2),
          child: Text(
            recordingProgressTime.value,
            style: const TextStyle(
              color: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        show: true,
      ),
      // Status Button
      AltButton(
        // name: Status,
        icon: Icons.circle,
        active: false,
        onPress: () => (),
        activeColor: Colors.black,
        inActiveColor: recordPaused.value == false ? Colors.red : Colors.yellow,
        show: true,
      ),
      // Settings Button
      AltButton(
        // name: Settings,
        icon: Icons.settings,
        active: false,
        onPress: () => launchRecording(
          LaunchRecordingOptions(
              updateIsRecordingModalVisible: updateIsRecordingModalVisible,
              isRecordingModalVisible: isRecordingModalVisible.value,
              stopLaunchRecord: stopLaunchRecord.value,
              canLaunchRecord: canLaunchRecord.value,
              recordingAudioSupport: recordingAudioSupport.value,
              recordingVideoSupport: recordingVideoSupport.value,
              updateCanRecord: updateCanRecord,
              updateClearedToRecord: updateClearedToRecord,
              recordStarted: recordStarted.value,
              recordPaused: recordPaused.value,
              localUIMode: widget.options.useLocalUIMode == true),
        ),

        activeColor: Colors.green,
        inActiveColor: Colors.black,
        show: true,
      )
    ];
  }


  // Initialize Control Buttons Broadcast Events
   void initializeControlBroadcastButtons() {
    controlBroadcastButtons = [
      // Users button
      ButtonTouch(
        icon: Icons.group_outlined,
        active: participantsActive,
        onPress: () => launchParticipants(
          LaunchParticipantsOptions(
            updateIsParticipantsModalVisible: updateIsParticipantsModalVisible,
            isParticipantsModalVisible: isParticipantsModalVisible.value,
          ),
        ),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        show: true,
      ),

      // Share button
      ButtonTouch(
        icon: Icons.share,
        alternateIcon: Icons.share,
        active: true,
        onPress: () =>
            updateIsShareEventModalVisible(!isShareEventModalVisible.value),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        show: true,
      ),
      // Custom component
      ButtonTouch(
        customComponent: Stack(
          children: [
            // Your icon
            const Icon(
              Icons.comment,
              size: 20,
              color: Colors.black,
            ),
            // Conditionally render a badge
            if (showMessagesBadge.value)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onPress: () => launchMessages(
          LaunchMessagesOptions(
            updateIsMessagesModalVisible: updateIsMessagesModalVisible,
            isMessagesModalVisible: isMessagesModalVisible.value,
          ),
        ),
        show: true,
      ),

      // Switch camera button
      ButtonTouch(
        icon: Icons.sync,
        alternateIcon: Icons.sync,
        active: true,
        onPress: () => switchVideoAlt(
          SwitchVideoAltOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: Colors.black,
        inActiveColor: Colors.black,
        show: islevel.value == '2',
      ),
      // Video button
      ButtonTouch(
        icon: Icons.video_call,
        alternateIcon: Icons.video_call,
        active: videoActive,
        onPress: () => clickVideo(
          ClickVideoOptions(
            parameters: mediasfuParameters,
          ),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        show: islevel.value == '2',
      ),
      // Microphone button
      ButtonTouch(
        icon: Icons.mic,
        alternateIcon: Icons.mic,
        active: micActive,
        onPress: () => clickAudio(
          ClickAudioOptions(parameters: mediasfuParameters),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        show: islevel.value == '2',
      ),

      ButtonTouch(
        customComponent: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 20, color: Colors.black),
              const SizedBox(width: 5),
              Text(
                participantsCounter.value.toString(),
                style: const TextStyle(
                  backgroundColor: Colors.transparent,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        show: true,
      ),
      // End call button
      ButtonTouch(
        icon: Icons.call_end,
        active: endCallActive,
        onPress: () => launchConfirmExit(
          LaunchConfirmExitOptions(
            updateIsConfirmExitModalVisible: updateIsConfirmExitModalVisible,
            isConfirmExitModalVisible: isConfirmExitModalVisible.value,
          ),
        ),
        activeColor: Colors.green,
        inActiveColor: Colors.red,
        show: true,
      ),
    ];
  }

```
This sample code defines arrays `recordButtons` and `controlBroadcastButtons`, each containing configuration objects for different control buttons. These configurations include properties such as icon, active state, onPress function, activeColor, inActiveColor, and show flag to control the visibility of each button.

You can customize these configurations according to your requirements, adding, removing, or modifying buttons as needed. Additionally, you can refer to the relevant component files (`control_buttons_alt_component.dart` and `control_buttons_component_touch.dart`) for more details on how to add custom buttons.

<div style="text-align: center;">
  Preview of Broadcast Page

<img src="https://mediasfu.com/images/broadcast.png" alt="Preview of Welcome Page" title="Welcome Page" style="max-height: 500px;">

<!-- Add a blank line for spacing -->
&nbsp;
  
  Preview of Conference Page

<img src="https://mediasfu.com/images/conference1.png" alt="Preview of Prejoin Page" title="Prejoin Page" style="max-height: 500px;">

### Preview of Conference Page's Mini Grids

<img src="https://mediasfu.com/images/conference2.png" alt="Preview of Prejoin Page" title="Prejoin Page" style="max-height: 500px;">

</div>
<br/>

# Advanced Usage Guide <a name="advanced-usage-guide"></a>

In-depth documentation for advanced users, covering complex functionalities and customization options.

**Introduction to Advanced Media Control Functions:**

In advanced usage scenarios, users often encounter complex tasks related to media control, connectivity, and streaming management within their applications. To facilitate these tasks, a comprehensive set of functions is provided, offering granular control over various aspects of media handling and communication with servers.

These advanced media control functions encompass a wide range of functionalities, including connecting to and disconnecting from WebSocket servers, joining and updating room parameters, managing device creation, switching between different media streams, handling permissions, processing consumer transports, managing screen sharing, adjusting layouts dynamically, and much more.

This robust collection of functions empowers developers to tailor their applications to specific requirements, whether it involves intricate media streaming setups, real-time communication protocols, or sophisticated user interface interactions. With these tools at their disposal, developers can create rich and responsive media experiences that meet the demands of their users and applications.

Here's a tabulated list of advanced control functions along with brief explanations (click the function(link) for full usage guide):
| **Function**                                                                 | **Explanation**                                                                                       |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| **[connectSocket](https://www.mediasfu.com/flutter/sockets_socket_manager/connectSocket)**                  | Connects to the WebSocket server.                                                                     |
| **[disconnectSocket](https://www.mediasfu.com/flutter/sockets_socket_manager/disconnectSocket)**           | Disconnects from the WebSocket server.                                                                |
| **[joinRoomClient](https://www.mediasfu.com/flutter/producer_client_producer_client_emits_join_room_client/joinRoomClient)**             | Joins a room as a client.                                                                             |
| **[updateRoomParametersClient](https://www.mediasfu.com/flutter/producer_client_producer_client_emits_update_room_parameters_client/updateRoomParametersClient)** | Updates room parameters as a client.                                                                  |
| **[createDeviceClient](https://www.mediasfu.com/flutter/producer_client_producer_client_emits_create_device_client/createDeviceClient)** | Creates a device as a client.                                                                         |
| **[switchVideoAlt](https://www.mediasfu.com/flutter/methods_stream_methods_switch_video_alt/switchVideoAlt)**                | Switches video/camera streams.                                                                        |
| **[clickVideo](https://www.mediasfu.com/flutter/methods_stream_methods_click_video/clickVideo)**                              | Handles clicking on video controls.                                                                   |
| **[clickAudio](https://www.mediasfu.com/flutter/methods_stream_methods_click_audio/clickAudio)**                              | Handles clicking on audio controls.                                                                   |
| **[clickScreenShare](https://www.mediasfu.com/flutter/methods_stream_methods_click_screen_share/clickScreenShare)**          | Handles clicking on screen share controls.                                                            |
| **[streamSuccessVideo](https://www.mediasfu.com/flutter/consumers_stream_success_video/streamSuccessVideo)**                 | Handles successful video streaming.                                                                   |
| **[streamSuccessAudio](https://www.mediasfu.com/flutter/consumers_stream_success_audio/streamSuccessAudio)**                 | Handles successful audio streaming.                                                                   |
| **[streamSuccessScreen](https://www.mediasfu.com/flutter/consumers_stream_success_screen/streamSuccessScreen)**              | Handles successful screen sharing.                                                                    |
| **[streamSuccessAudioSwitch](https://www.mediasfu.com/flutter/consumers_stream_success_audio_switch/streamSuccessAudioSwitch)** | Handles successful audio switching.                                                                   |
| **[checkPermission](https://www.mediasfu.com/flutter/consumers_check_permission/checkPermission)**                            | Checks for media access permissions.                                                                  |
| **[producerClosed](https://www.mediasfu.com/flutter/consumers_socket_receive_methods_producer_closed/producerClosed)**        | Handles the closure of a producer.                                                                    |
| **[newPipeProducer](https://www.mediasfu.com/flutter/consumers_socket_receive_methods_new_pipe_producer/newPipeProducer)**    | Creates receive transport for a new piped producer.                                                   |
| **[updateMiniCardsGrid](https://www.mediasfu.com/flutter/consumers_update_mini_cards_grid/updateMiniCardsGrid)**              | Updates the mini-grids (mini cards) grid.                                                             |
| **[mixStreams](https://www.mediasfu.com/flutter/consumers_mix_streams/mixStreams)**                                          | Mixes streams and prioritizes interesting ones together.                                              |
| **[dispStreams](https://www.mediasfu.com/flutter/consumers_disp_streams/dispStreams)**                                        | Displays streams (media).                                                                             |
| **[stopShareScreen](https://www.mediasfu.com/flutter/consumers_stop_share_screen/stopShareScreen)**                          | Stops screen sharing.                                                                                 |
| **[checkScreenShare](https://www.mediasfu.com/flutter/consumers_check_screen_share/checkScreenShare)**                       | Checks for screen sharing availability.                                                              |
| **[startShareScreen](https://www.mediasfu.com/flutter/consumers_start_share_screen/startShareScreen)**                       | Starts screen sharing.                                                                                |
| **[requestScreenShare](https://www.mediasfu.com/flutter/consumers_request_screen_share/requestScreenShare)**                 | Requests permission for screen sharing.                                                              |
| **[reorderStreams](https://www.mediasfu.com/flutter/consumers_reorder_streams/reorderStreams)**                              | Reorders streams (based on interest level).                                                          |
| **[prepopulateUserMedia](https://www.mediasfu.com/flutter/consumers_prepopulate_user_media/prepopulateUserMedia)**           | Populates user media (for main grid).                                                                |
| **[getVideos](https://www.mediasfu.com/flutter/consumers_get_videos/getVideos)**                                             | Retrieves videos that are pending.                                                                   |
| **[rePort](https://www.mediasfu.com/flutter/consumers_re_port/rePort)**                                                     | Handles re-porting (updates of changes in UI when recording).                                         |
| **[trigger](https://www.mediasfu.com/flutter/consumers_trigger/trigger)**                                                   | Triggers actions (reports changes in UI to backend for recording).                                    |
| **[consumerResume](https://www.mediasfu.com/flutter/consumers_consumer_resume/consumerResume)**                              | Resumes consumers.                                                                                   |
| **[connectSendTransportAudio](https://www.mediasfu.com/flutter/consumers_connect_send_transport_audio/connectSendTransportAudio)** | Connects send transport for audio.                                                                   |
| **[connectSendTransportVideo](https://www.mediasfu.com/flutter/consumers_connect_send_transport_video/connectSendTransportVideo)** | Connects send transport for video.                                                                   |
| **[connectSendTransportScreen](https://www.mediasfu.com/flutter/consumers_connect_send_transport_screen/connectSendTransportScreen)** | Connects send transport for screen sharing.                                                          |
| **[processConsumerTransports](https://www.mediasfu.com/flutter/consumers_process_consumer_transports/processConsumerTransports)** | Processes consumer transports to pause/resume based on the current active page.                       |
| **[resumePauseStreams](https://www.mediasfu.com/flutter/consumers_resume_pause_streams/resumePauseStreams)**                 | Resumes or pauses streams.                                                                            |
| **[readjust](https://www.mediasfu.com/flutter/consumers_readjust/readjust)**                                                | Readjusts display elements.                                                                          |
| **[checkGrid](https://www.mediasfu.com/flutter/consumers_check_grid/checkGrid)**                                            | Checks the grid sizes to display.                                                                    |
| **[getEstimate](https://www.mediasfu.com/flutter/consumers_get_estimate/getEstimate)**                                       | Gets an estimate of grids to add.                                                                    |
| **[calculateRowsAndColumns](https://www.mediasfu.com/flutter/consumers_calculate_rows_and_columns/calculateRowsAndColumns)** | Calculates rows and columns for the grid.                                                            |
| **[addVideosGrid](https://www.mediasfu.com/flutter/consumers_add_videos_grid/addVideosGrid)**                               | Adds videos to the grid.                                                                             |
| **[onScreenChanges](https://www.mediasfu.com/flutter/consumers_on_screen_changes/onScreenChanges)**                         | Handles screen changes (orientation and resize).                                                     |
| **[sleep](https://www.mediasfu.com/flutter/methods_utils_sleep/sleep)**                                                     | Pauses execution for a specified duration.                                                           |
| **[changeVids](https://www.mediasfu.com/flutter/consumers_change_vids/changeVids)**                                         | Changes videos.                                                                                      |
| **[compareActiveNames](https://www.mediasfu.com/flutter/consumers_compare_active_names/compareActiveNames)**                 | Compares active names (for recording UI changes reporting).                                           |
| **[compareScreenStates](https://www.mediasfu.com/flutter/consumers_compare_screen_states/compareScreenStates)**             | Compares screen states (for recording changes in grid sizes reporting).                               |
| **[createSendTransport](https://www.mediasfu.com/flutter/consumers_create_send_transport/createSendTransport)**             | Creates a send transport.                                                                            |
| **[resumeSendTransportAudio](https://www.mediasfu.com/flutter/consumers_resume_send_transport_audio/resumeSendTransportAudio)** | Resumes a send transport for audio.                                                                  |
| **[receiveAllPipedTransports](https://www.mediasfu.com/flutter/consumers_receive_all_piped_transports/receiveAllPipedTransports)** | Receives all piped transports.                                                                       |
| **[disconnectSendTransportVideo](https://www.mediasfu.com/flutter/consumers_disconnect_send_transport_video/disconnectSendTransportVideo)** | Disconnects send transport for video.                                                                |
| **[disconnectSendTransportAudio](https://www.mediasfu.com/flutter/consumers_disconnect_send_transport_audio/disconnectSendTransportAudio)** | Disconnects send transport for audio.                                                                |
| **[disconnectSendTransportScreen](https://www.mediasfu.com/flutter/consumers_disconnect_send_transport_screen/disconnectSendTransportScreen)** | Disconnects send transport for screen sharing.                                                       |
| **[connectSendTransport](https://www.mediasfu.com/flutter/consumers_connect_send_transport/connectSendTransport)**           | Connects a send transport.                                                                           |
| **[getPipedProducersAlt](https://www.mediasfu.com/flutter/consumers_get_piped_producers_alt/getPipedProducersAlt)**          | Gets piped producers.                                                                                |
| **[signalNewConsumerTransport](https://www.mediasfu.com/flutter/consumers_signal_new_consumer_transport/signalNewConsumerTransport)** | Signals a new consumer transport.                                                                    |
| **[connectRecvTransport](https://www.mediasfu.com/flutter/consumers_connect_recv_transport/connectRecvTransport)**          | Connects a receive transport.                                                                        |
| **[reUpdateInter](https://www.mediasfu.com/flutter/consumers_re_update_inter/reUpdateInter)**                               | Re-updates the interface based on audio decibels.                                                   |
| **[updateParticipantAudioDecibels](https://www.mediasfu.com/flutter/consumers_update_participant_audio_decibels/updateParticipantAudioDecibels)** | Updates participant audio decibels.                                                                  |
| **[closeAndResize](https://www.mediasfu.com/flutter/consumers_close_and_resize/closeAndResize)**                            | Closes and resizes the media elements.                                                               |
| **[autoAdjust](https://www.mediasfu.com/flutter/consumers_auto_adjust/autoAdjust)**                                         | Automatically adjusts display elements.                                                              |
| **[switchUserVideoAlt](https://www.mediasfu.com/flutter/consumers_switch_user_video_alt/switchUserVideoAlt)**               | Switches user video (alternate) (back/front).                                                        |
| **[switchUserVideo](https://www.mediasfu.com/flutter/consumers_switch_user_video/switchUserVideo)**                         | Switches user video (specific video id).                                                             |
| **[switchUserAudio](https://www.mediasfu.com/flutter/consumers_switch_user_audio/switchUserAudio)**                         | Switches user audio.                                                                                 |
| **[receiveRoomMessages](https://www.mediasfu.com/flutter/consumers_receive_room_messages/receiveRoomMessages)**             | Receives room messages.                                                                              |
| **[formatNumber](https://www.mediasfu.com/flutter/methods_utils_format_number/formatNumber)**                               | Formats a number (for broadcast viewers).                                                            |
| **[connectIps](https://www.mediasfu.com/flutter/consumers_connect_ips/connectIps)**                                         | Connects IPs (connect to consuming servers).                                                         |
| **[startMeetingProgressTimer](https://www.mediasfu.com/flutter/methods_utils_meeting_timer_start_meeting_progress_timer/startMeetingProgressTimer)** | Starts the meeting progress timer.                                                                   |
| **[updateRecording](https://www.mediasfu.com/flutter/methods_recording_methods_update_recording/updateRecording)**          | Updates the recording status.                                                                        |
| **[stopRecording](https://www.mediasfu.com/flutter/methods_recording_methods_stop_recording/stopRecording)**                | Stops the recording process.                                                                         |
| **[pollUpdated](https://www.mediasfu.com/flutter/methods_polls_methods_poll_updated/pollUpdated)**                          | Handles updated poll data.                                                                           |
| **[handleVotePoll](https://www.mediasfu.com/flutter/methods_polls_methods_handle_vote_poll/handleVotePoll)**                | Handles voting in a poll.                                                                            |
| **[handleCreatePoll](https://www.mediasfu.com/flutter/methods_polls_methods_handle_create_poll/handleCreatePoll)**          | Handles creating a poll.                                                                             |
| **[handleEndPoll](https://www.mediasfu.com/flutter/methods_polls_methods_handle_end_poll/handleEndPoll)**                   | Handles ending a poll.                                                                               |
| **[breakoutRoomUpdated](https://www.mediasfu.com/flutter/methods_breakout_rooms_methods_breakout_room_updated/breakoutRoomUpdated)** | Handles updated breakout room data. |
| **[resumePauseAudioStreams](https://www.mediasfu.com/flutter/consumers_resume_pause_audio_streams/resumePauseAudioStreams)** | Resumes or pauses audio streams. |
| **[processConsumerTransportsAudio](https://www.mediasfu.com/flutter/consumers_process_consumer_transports_audio/processConsumerTransportsAudioo)**  | Processes consumer transports for audio. |                                                                  



### Room Socket Events

In the context of a room's real-time communication, various events occur, such as user actions, room management updates, media controls, and meeting status changes. To effectively handle these events and synchronize the application's state with the server, specific functions are provided. These functions act as listeners for socket events, allowing the application to react accordingly.

#### Provided Socket Event Handling Functions:

| **Function**                                                                   | **Explanation**                                                                                     |
|--------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **[userWaiting](https://www.mediasfu.com/flutter/producers_socket_receive_methods_user_waiting/userWaiting)**                 | Triggered when a user is waiting.                                                                   |
| **[personJoined](https://www.mediasfu.com/flutter/producers_socket_receive_methods_person_joined/personJoined)**               | Triggered when a person joins the room.                                                            |
| **[allWaitingRoomMembers](https://www.mediasfu.com/flutter/producers_socket_receive_methods_all_waiting_room_members/allWaitingRoomMembers)** | Triggered when information about all waiting room members is received.                             |
| **[roomRecordParams](https://www.mediasfu.com/flutter/producers_socket_receive_methods_room_record_params/roomRecordParams)**   | Triggered when room recording parameters are received.                                              |
| **[banParticipant](https://www.mediasfu.com/flutter/producers_socket_receive_methods_ban_participant/banParticipant)**         | Triggered when a participant is banned.                                                            |
| **[updatedCoHost](https://www.mediasfu.com/flutter/producers_socket_receive_methods_updated_co_host/updatedCoHost)**           | Triggered when the co-host information is updated.                                                 |
| **[participantRequested](https://www.mediasfu.com/flutter/producers_socket_receive_methods_participant_requested/participantRequested)** | Triggered when a participant requests access.                                                      |
| **[screenProducerId](https://www.mediasfu.com/flutter/producers_socket_receive_methods_screen_producer_id/screenProducerId)**   | Triggered when the screen producer ID is received.                                                 |
| **[updateMediaSettings](https://www.mediasfu.com/flutter/producers_socket_receive_methods_update_media_settings/updateMediaSettings)** | Triggered when media settings are updated.                                                         |
| **[producerMediaPaused](https://www.mediasfu.com/flutter/producers_socket_receive_methods_producer_media_paused/producerMediaPaused)** | Triggered when producer media is paused.                                                           |
| **[producerMediaResumed](https://www.mediasfu.com/flutter/producers_socket_receive_methods_producer_media_resumed/producerMediaResumed)** | Triggered when producer media is resumed.                                                          |
| **[producerMediaClosed](https://www.mediasfu.com/flutter/producers_socket_receive_methods_producer_media_closed/producerMediaClosed)** | Triggered when producer media is closed.                                                           |
| **[controlMediaHost](https://www.mediasfu.com/flutter/producers_socket_receive_methods_control_media_host/controlMediaHost)**   | Triggered when media control is hosted.                                                            |
| **[meetingEnded](https://www.mediasfu.com/flutter/producers_socket_receive_methods_meeting_ended/meetingEnded)**               | Triggered when the meeting ends.                                                                   |
| **[disconnectUserSelf](https://www.mediasfu.com/flutter/producers_socket_receive_methods_disconnect_user_self/disconnectUserSelf)** | Triggered when a user disconnects.                                                                 |
| **[receiveMessage](https://www.mediasfu.com/flutter/producers_socket_receive_methods_receive_message/receiveMessage)**         | Triggered when a message is received.                                                              |
| **[meetingTimeRemaining](https://www.mediasfu.com/flutter/producers_socket_receive_methods_meeting_time_remaining/meetingTimeRemaining)** | Triggered when meeting time remaining is received.                                                 |
| **[meetingStillThere](https://www.mediasfu.com/flutter/producers_socket_receive_methods_meeting_still_there/meetingStillThere)** | Triggered when the meeting is still active.                                                        |
| **[startRecords](https://www.mediasfu.com/flutter/producers_socket_receive_methods_start_records/startRecords)**               | Triggered when recording starts.                                                                   |
| **[reInitiateRecording](https://www.mediasfu.com/flutter/producers_socket_receive_methods_re_initiate_recording/reInitiateRecording)** | Triggered when recording needs to be re-initiated.                                                 |
| **[getDomains](https://www.mediasfu.com/flutter/producers_socket_receive_methods_get_domains/getDomains)**                     | Triggered when domains are received.                                                               |
| **[updateConsumingDomains](https://www.mediasfu.com/flutter/producers_socket_receive_methods_update_consuming_domains/updateConsumingDomains)** | Triggered when consuming domains are updated.                                                      |
| **[RecordingNotice](https://www.mediasfu.com/flutter/producers_socket_receive_methods_recording_notice/RecordingNotice)**      | Triggered when a recording notice is received.                                                     |
| **[timeLeftRecording](https://www.mediasfu.com/flutter/producers_socket_receive_methods_time_left_recording/timeLeftRecording)** | Triggered when time left for recording is received.                                                |
| **[stoppedRecording](https://www.mediasfu.com/flutter/producers_socket_receive_methods_stopped_recording/stoppedRecording)**   | Triggered when recording stops.                                                                    |
| **[hostRequestResponse](https://www.mediasfu.com/flutter/producers_socket_receive_methods_host_request_response/hostRequestResponse)** | Triggered when the host request response is received.                                              |
| **[allMembers](https://www.mediasfu.com/flutter/producers_socket_receive_methods_all_members/allMembers)**                     | Triggered when information about all members is received.                                          |
| **[allMembersRest](https://www.mediasfu.com/flutter/producers_socket_receive_methods_all_members_rest/allMembersRest)**         | Triggered when information about all members is received (rest of the members).                    |
| **[disconnect](https://www.mediasfu.com/flutter/producers_socket_receive_methods_disconnect/disconnect)**                     | Triggered when a disconnect event occurs.                                                          |
| **[pollUpdated](https://www.mediasfu.com/flutter/methods_polls_methods_poll_updated/pollUpdated)**                             | Triggered when a poll is updated.                                                                  |
| **[breakoutRoomUpdated](https://www.mediasfu.com/flutter/methods_breakout_rooms_methods_breakout_room_updated/breakoutRoomUpdated)** | Triggered when a breakout room is updated.                                                        |

#### Sample Usage:

```dart 
// Example usage of provided socket event handling functions
import 'package:mediasfu_sdk/mediasfu_sdk.dart'show participantRequested, screenProducerId, participantRequestedOptions, screenProducerIdOptions, Request;

  socket.value!.on('participantRequested', (data) async {
    try {
      // Convert userRequest data to Request object
      Request request = Request.fromMap(data['userRequest']);
      // Handle 'participantRequested' event
      participantRequested(
        ParticipantRequestedOptions(
          userRequest: request,
          requestList: requestList.value,
          waitingRoomList: waitingRoomList.value,
          updateRequestList: updateRequestList,
          updateTotalReqWait: updateTotalReqWait,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        // print('Error handling participantRequested event: $error');
      }
    }
  });

  socket.value!.on('screenProducerId', (data) async {
    // Handle 'screenProducerId' event
    try {
      screenProducerId(ScreenProducerIdOptions(
        producerId: data['producerId'],
        screenId: screenId.value,
        membersReceived: membersReceived.value,
        shareScreenStarted: shareScreenStarted.value,
        deferScreenReceived: deferScreenReceived.value,
        participants: participants.value,
        updateScreenId: updateScreenId,
        updateShareScreenStarted: updateShareScreenStarted,
        updateDeferScreenReceived: updateDeferScreenReceived,
      ));
    } catch (error) {
      if (kDebugMode) {
        // print('Error handling screenProducerId event: $error');
      }
    }
  });

```
These functions enable seamless interaction with the server and ensure that the application stays synchronized with the real-time events occurring within the room.

### Customizing Media Display in MediaSFU

By default, media display in MediaSFU is handled by the following key functions:

- **`prepopulateUserMedia`**: This function controls the main media grid, such as the host's video in webinar or broadcast views (MainGrid).
- **`addVideosGrid`**: This function manages the mini grid's media, such as participants' media in MiniGrid views (MiniCards, AudioCards, VideoCards).

#### Customizing the Media Display

If you want to modify the default content displayed by MediaSFU components, such as the `MiniCard`, `AudioCard`, or `VideoCard`, you can replace the default UI with your own custom components.

To implement your custom UI for media display:

1. **Custom MainGrid (Host's Video)**:
   - Modify the UI in the `prepopulateUserMedia` function.
   - Example link to MediaSFU's default implementation: [`prepopulateUserMedia`](https://github.com/MediaSFU/MediaSFU_SDK_Flutter/tree/main/lib/consumers/prepopulate_user_media.dart).

2. **Custom MiniGrid (Participants' Media)**:
   - Modify the UI in the `addVideosGrid` function.
   - Example link to MediaSFU's default implementation: [`addVideosGrid`](https://github.com/MediaSFU/MediaSFU_SDK_Flutter/tree/main/lib/consumers/add_videos_grid.dart).

To create a custom UI, you can refer to existing MediaSFU implementations like:

- [MediasfuGeneric](https://github.com/MediaSFU/MediaSFU_SDK_Flutter/tree/main/lib/components/mediasfu_components/mediasfu_generic.dart)
- [MediasfuBroadcast](https://github.com/MediaSFU/MediaSFU_SDK_Flutter/tree/main/lib/components/mediasfu_components/mediasfu_broadcast.dart)

Once your custom components are built, modify the imports of `prepopulateUserMedia` and `addVideosGrid` to point to your custom implementations instead of the default MediaSFU ones.

This allows for full flexibility in how media is displayed in both the main and mini grids, giving you the ability to tailor the user experience to your specific needs.

# API Reference <a name="api-reference"></a>

For detailed information on the API methods and usage, please refer to the [MediaSFU API Documentation](https://mediasfu.com/developers).

If you need further assistance or have any questions, feel free to ask!

For sample codes and practical implementations, visit the [MediaSFU Sandbox](https://www.mediasfu.com/sandbox).


# Troubleshooting <a name="troubleshooting"></a>

Encountering issues while integrating MediaSFU into your Flutter application? Below are common problems and their solutions to help you get back on track.

### 1. Interactive Testing with MediaSFU's Frontend

**Issue**: Difficulty in verifying if events or media transmissions are functioning correctly within your application.

**Solution**: Utilize MediaSFU's frontend to join the same room as your Flutter application. This allows you to interactively monitor and analyze event handling and media streams.

**Steps**:
- **Open MediaSFU's Frontend**: Navigate to the [MediaSFU Frontend](https://mediasfu.com/frontend) in your web browser.
- **Join the Same Room**: Use the same room credentials in the frontend that your Flutter app is using.
- **Monitor Interactions**: Perform actions in your Flutter app (e.g., start a call, share media) and observe the corresponding changes in the frontend. Similarly, perform actions in the frontend and verify their effects in your Flutter app.

This method helps ensure that interactions between users and media streams are functioning as expected.

### 2. Reducing Terminal Log Clutter

**Issue**: Excessive Java logs cluttering the terminal output when running your Flutter application in debug mode, making it difficult to identify relevant Flutter logs.

**Solution**: Filter out irrelevant logs using command-line tools to display only Flutter-related logs, enhancing readability and debugging efficiency.

**For Unix-based Systems (Linux/macOS)**:
Use the following command to run your Flutter app while filtering logs:

```bash
flutter run | sed '/^.\// { /^\(V\|I\|W\|E\)\/flutter/!d }'
```

**Explanation**:
- `flutter run`: Starts your Flutter application.
- `|`: Pipes the output to the next command.
- `sed '/^.\// { /^\(V\|I\|W\|E\)\/flutter/!d }'`: Filters the logs to display only those that start with Flutter's log tags (V for Verbose, I for Info, W for Warning, E for Error).

**For Windows Users**:
Use PowerShell to achieve similar log filtering:

```powershell
flutter run | Select-String "flutter/"
```

**Note**: Ensure you have the necessary command-line tools installed and configured for your operating system.

### 3. Issues with Remote Streams on Web

**Issue**: Remote streams not appearing when testing your Flutter application on the web, potentially due to localhost-related issues.

**Solution**: Follow these recommendations to ensure a reliable testing environment:

#### a. Build and Deploy

- **Build for Production**: Create a production build of your Flutter web application using:

  ```bash
  flutter build web
  ```

- **Deploy to a Staging or Live Environment**: Deploy the build to a web server or hosting service to test in a real-world scenario, which can bypass localhost limitations related to browser security and network configurations.

#### b. Use a Different Browser

- **Test Across Multiple Browsers**: Some browsers handle WebRTC and media streams differently. Test your application on various browsers (e.g., Chrome, Firefox, Edge) to identify if the issue is browser-specific.

- **Check Browser Permissions**: Ensure that the browser has granted the necessary permissions for camera and microphone access.

#### c. Verify Network Configurations

- **Firewall and Network Settings**: Ensure that your network allows WebRTC traffic and that firewalls are not blocking necessary ports.

- **Use HTTPS**: Browsers enforce stricter security policies for WebRTC on non-secure (HTTP) connections. Deploy your application over HTTPS to ensure proper functionality.

### 4. Additional Common Issues

#### a. Unable to Connect to MediaSFU Server

**Solution**:
- **Check Credentials**: Ensure that your `apiUserName` and `apiKey` are correctly set and valid.
- **Network Connectivity**: Verify that your device has a stable internet connection.
- **Server Status**: Confirm that MediaSFU servers are operational by checking the [MediaSFU Status Page](https://status.mediasfu.com).

#### b. Application Crashes or Freezes During Media Transmission

**Solution**:
- **Update Dependencies**: Ensure that all Flutter dependencies are up-to-date by running:

  ```bash
  flutter pub get
  flutter pub upgrade
  ```

- **Review Logs**: Use the filtered logs (as described in section 2) to identify any errors or warnings that could indicate the cause.
- **Device Resources**: Ensure that the device running the application has sufficient resources (CPU, memory) to handle media transmissions.

#### c. UI Elements Not Displaying Correctly

**Solution**:
- **Hot Reload**: Use Flutter's hot reload feature to apply code changes without restarting the application.
- **Check Widget Tree**: Ensure that your widgets are properly nested and there are no conflicts in the UI hierarchy.
- **Responsive Design**: Verify that your UI is responsive and adapts to different screen sizes and orientations.


### Key Points to Remember

- **Interactive Testing**: Utilize MediaSFU's frontend to verify event handling and media streams.
- **Log Filtering**: Use command-line tools to filter out non-Flutter logs for a cleaner debugging experience.
- **Web Testing**: Deploy your app to a live environment and test across multiple browsers to resolve remote stream issues.
- **Stay Updated**: Regularly update your dependencies and monitor server statuses to prevent common issues.
- **Responsive UI**: Ensure your application's UI is responsive and correctly structured to avoid display problems.
   
1. **Interactive Testing with MediaSFU's Frontend**:
   Users can interactively join MediaSFU's frontend in the same room to analyze if various events or media transmissions are happening as expected. For example, adding a user there to check changes made by the host and vice versa.
 
2. **Reducing Terminal Log Clutter**:
   When running your Flutter application on a physical device in debug mode, you might encounter excessive logs from Java that clutter the terminal output. To address this issue, you can use the following command to filter out irrelevant logs:
   
   ```
   flutter run | sed '/^.\// { /^\(V\|I\|W\|E\)\/flutter/!d }'
   ```
   
   This command will only display logs related to Flutter, excluding unnecessary logs from other sources. It helps in maintaining a cleaner terminal output for better debugging experience.

3. **Issues with Remote Streams on Web**:
If you have issues seeing remote streams on the web, it might be due to problems related to localhost. Testing on localhost can sometimes lead to issues due to various factors, such as browser security settings or network configurations. To ensure a more reliable testing environment, it is recommended to:

    - ***Build and Deploy***: Make a production build of your application and deploy it to a staging or live environment. This will help you test the application in a real-world scenario, bypassing potential issues related to localhost.
    - ***Use a Different Browser***: Sometimes, different browsers handle local streams differently. Testing on multiple browsers can help identify if the issue is browser-specific.
These troubleshooting steps should help users address common issues and optimize their experience with MediaSFU. If the issues persist or additional assistance is needed, users can refer to the [documentation](https://mediasfu.com/docs) or reach out to the support team for further assistance.

# Contributing <a name="contributing"></a>

We welcome contributions from the community to improve the project! If you'd like to contribute, please check out our [GitHub repository](https://github.com/MediaSFU_SDK_Flutter) and follow the guidelines outlined in the README.

If you encounter any issues or have suggestions for improvement, please feel free to open an issue on GitHub.

We appreciate your interest in contributing to the project!

If you need further assistance or have any questions, feel free to ask!



<div style="text-align: center;">

https://github.com/MediaSFU/MediaSFU-ReactJS/assets/157974639/a6396722-5b2f-4e93-a5b3-dd53ffd20eb7

</div>
