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
