import 'package:flutter/material.dart';
import './components/mediasfu_components/mediasfu_chat.dart' show MediasfuChat;
import './components/misc_components/prejoin_page.dart' show PreJoinPage;
import './methods/utils/generate_random_participants.dart'
    show generateRandomParticipants;
import './methods/utils/generate_random_messages.dart'
    show generateRandomMessages;

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
