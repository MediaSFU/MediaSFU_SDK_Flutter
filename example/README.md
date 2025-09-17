# Mediasfu Flutter SDK Example
This is an example Flutter project demonstrating the usage of the Mediasfu Flutter SDK.

## Overview
This example project showcases different usage scenarios of the Mediasfu Flutter SDK, including broadcasting, chatting, webinar, conference, and generic functionalities.

### Usage
To run the example project, you can use specific usage scenarios provided in the following files:

- `lib/main_broadcast.dart`: Demonstrates broadcasting functionality.
- `lib/main_chat.dart`: Demonstrates chatting functionality.
- `lib/main_webinar.dart`: Demonstrates webinar functionality.
- `lib/main_conference.dart`: Demonstrates conference functionality.
- `lib/main_generic.dart`: Demonstrates generic usage scenarios.
- `lib/custom_builders_example.dart`: Demonstrates custom UI builders for VideoCard, AudioCard, and MiniCard components.
- `lib/complete_custom_component_example.dart`: Demonstrates complete custom interface replacement using CustomComponentType.

Open the desired file and run the project using the Flutter CLI:

```bash
flutter run lib/main_broadcast.dart
```

Replace `main_broadcast.dart` with the file name corresponding to the scenario you want to test.

## Custom Components
The MediaSFU SDK provides powerful customization options:

### 1. Custom Builders
Use custom builders to replace individual UI components like VideoCard, AudioCard, and MiniCard:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    customVideoCard: myCustomVideoCard,
    customAudioCard: myCustomAudioCard,
    customMiniCard: myCustomMiniCard,
  ),
)
```

### 2. Complete Custom Interface
Use `CustomComponentType` to replace the entire MediaSFU interface with your own widget while still accessing all MediaSFU functionality:

```dart
MediasfuGeneric(
  options: MediasfuGenericOptions(
    customComponent: myCustomInterface,
  ),
)

Widget myCustomInterface({required MediasfuParameters parameters}) {
  return Scaffold(
    // Your completely custom UI
    // Access all MediaSFU functionality through parameters
    body: Column(
      children: [
        // Custom header, controls, participants list, etc.
        ElevatedButton(
          onPressed: () => parameters.clickVideo(
            ClickVideoOptions(parameters: parameters),
          ),
          child: Text('Toggle Video'),
        ),
      ],
    ),
  );
}
```

## Chat MediaSFU 
```dart 
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

// Global credentials used for authentication
final credentials = {
  'apiUserName': "your_api_user_name",
  'apiKey': "your_api_key",
};

/// The main application widget responsible for setting up the UI and navigation.
///
/// Users have the option to use a custom prejoin page or the default prejoin page provided by Mediasfu.
/// Custom prejoin pages require user credentials to create/join an event.
/// If no custom prejoin page is provided, a default welcome page is presented where users can scan their access code
/// obtained from the Mediasfu website.
class MyApp extends StatelessWidget {
  /// Indicates whether to use seed data for generating random participants and messages.
  final bool useSeed = false;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Name of the member
    const String memberName = 'Alice';

    // Name of the host (same as member if the member is the host)
    const String hostName = 'Fred';

    // Generate random participants with Alice as member and Fred as host
    final participants = useSeed
        ? generateRandomParticipants(memberName, '', hostName,
            forChatBroadcast: true)
        : [];

    // Generate random messages for the generated participants
    final messages = useSeed
        ? generateRandomMessages(participants, memberName, '', hostName,
            forChatBroadcast: true)
        : [];

    // Assign the generated participants and messages to seedData
    final seedData = {
      'participants': participants,
      'messages': messages,
      'member': memberName,
      'host': hostName,
    };

    // Whether to use local UI mode; prevents making requests to the Mediasfu servers during UI development
    final useLocalUIMode = useSeed;

    return MaterialApp(
      title: 'Mediasfu Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuChat(
        // Configure the PrejoinPage widget with credentials and parameters
        PrejoinPage: ({
          required Map<String, dynamic> credentials,
          required Map<String, dynamic> parameters,
        }) {
          return PreJoinPage(credentials: credentials, parameters: parameters);
        },
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: useSeed ? seedData : {}, // Pass seed data if useSeed is true
        credentials: credentials, // Pass global credentials
      ),
    );
  }
}
```

## Generic MediaSFU
```dart
    import 'package:flutter/material.dart';
    import 'package:mediasfu_sdk/mediasfu_sdk.dart';
    
    void main() {
      runApp(const MyApp());
    }
    
    // Global credentials used for authentication
    final credentials = {
      'apiUserName': "your_api_user_name",
      'apiKey': "your_api_key",
    };
    
    /// The main application widget responsible for setting up the UI and navigation.
    ///
    /// Users have the option to provide a custom view by passing the [PreJoinPage]
    /// widget, which can be tailored to their specific requirements. This flexibility
    /// allows users to design and customize the prejoin experience according to their
    /// needs, such as collecting additional information or providing specialized instructions.
    /// When using the prejoin page, ensure to pass appropriate [credentials] for authentication.
    ///
    /// For generic usage, where a custom view is not provided, the application defaults
    /// to [MediasfuGeneric], offering a generic prejoin experience. In this mode, seed data
    /// can be utilized for UI design purposes by enabling the [useSeed] flag. When [useSeed]
    /// is true, seed data containing random participants, messages, requests, and waiting lists
    /// is provided. Set [useLocalUIMode] to true to prevent making requests to Mediasfu servers
    /// during UI development.
    class MyApp extends StatelessWidget {
      /// Whether to use seed data for generating random participants and messages.
      final bool useSeed = false;
    
      const MyApp({super.key});
    
      @override
      Widget build(BuildContext context) {
        // Name of the member
        const String memberName = 'Prince';
    
        // Name of the host (same as member if the member is the host)
        const String hostName = 'Fred';
    
        // Determine the event type
        const String eventType =
            'chat'; // 'broadcast', 'chat', 'webinar', 'conference'
    
        // Generate random participants, messages, requests, and waiting list
        final participants = useSeed
            ? generateRandomParticipants(memberName, '', hostName,
                forChatBroadcast: eventType == "broadcast" || eventType == "chat")
            : [];
        final messages = useSeed
            ? generateRandomMessages(participants, memberName, '', hostName,
                forChatBroadcast: eventType == "broadcast" || eventType == "chat")
            : [];
        final requests = useSeed
            ? generateRandomRequestList(participants, memberName, '', 3)
            : [];
        final waitingList =
            useSeed ? generateRandomWaitingRoomList(participants) : [];
    
        // Create seed data
        final seedData = {
          'participants': participants,
          'messages': messages,
          'requests': requests,
          'waitingList': waitingList,
          'member': memberName,
          'host': hostName,
          'eventType': eventType,
        };
    
        // Whether to use local UI mode; prevents making requests to the Mediasfu servers during UI development
        final useLocalUIMode = useSeed;
    
        return MaterialApp(
          title: 'Mediasfu Generic',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MediasfuGeneric(
            // Configure the PrejoinPage widget with credentials and parameters
            PrejoinPage: ({
              required Map<String, dynamic> credentials,
              required Map<String, dynamic> parameters,
            }) {
              return PreJoinPage(credentials: credentials, parameters: parameters);
            },
            useLocalUIMode: useLocalUIMode,
            useSeed: useSeed,
            // Pass seed data if useSeed is true and useLocalUIMode is true
            seedData: useSeed && useLocalUIMode ? seedData : {},
            // Pass global credentials only if using a PrejoinPage
            credentials: !useLocalUIMode ? credentials : {},
          ),
        );
      }
    }
```
