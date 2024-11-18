// ignore_for_file: unused_import, unused_shown_name
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

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
