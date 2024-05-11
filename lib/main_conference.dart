import 'package:flutter/material.dart';
import './components/mediasfu_components/mediasfu_conference.dart'
    show MediasfuConference;
import './components/misc_components/prejoin_page.dart' show PreJoinPage;
import './methods/utils/generate_random_participants.dart'
    show generateRandomParticipants;
import './methods/utils/generate_random_messages.dart'
    show generateRandomMessages;
import './methods/utils/generate_random_request_list.dart'
    show generateRandomRequestList;
import './methods/utils/generate_random_waiting_room_list.dart'
    show generateRandomWaitingRoomList;

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
/// Users have the option to design and pass their custom prejoin page or use the default prejoin page provided by Mediasfu.
/// Custom prejoin pages offer flexibility in design and functionality, allowing users to tailor the prejoin experience
/// to their specific needs, such as collecting additional information or providing specialized instructions.
class MyApp extends StatelessWidget {
  /// Indicates whether to use seed data for generating random participants and messages.
  final bool useSeed = false;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Name of the member
    const String memberName = 'Prince';

    // Name of the host (same as member if the member is the host)
    const String hostName = 'Prince';

    // Generate random participants, messages, requests, and waiting list
    final participants =
        useSeed ? generateRandomParticipants(memberName, '', hostName) : [];
    final messages = useSeed
        ? generateRandomMessages(participants, memberName, '', hostName)
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
    };

    // Whether to use local UI mode; prevents making requests to the Mediasfu servers during UI development
    final useLocalUIMode = useSeed;

    return MaterialApp(
      title: 'Mediasfu Conference',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuConference(
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
