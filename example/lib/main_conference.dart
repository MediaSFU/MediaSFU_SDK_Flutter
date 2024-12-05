// ignore_for_file: unused_shown_name, unused_import
import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

/// A custom pre-join page widget that can be used instead of the default Mediasfu pre-join page.
///
/// This widget displays a personalized welcome message and includes a button to proceed to the session.
///
/// **Note:** Ensure this widget is passed to [MediasfuWebinarOptions] only when you intend to use a custom pre-join page.

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
              options!.parameters.updateValidated(true);
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
/// This widget initializes the necessary configuration and credentials for the MediaSFU application.
/// Users can specify their own Community Edition (CE) server, utilize MediaSFU Cloud by default, or enable MediaSFU Cloud for egress features.
///
/// **Remarks:**
/// - **Using Your Own Community Edition (CE) Server**: Set the `localLink` to point to your CE server.
/// - **Using MediaSFU Cloud by Default**: If not using a custom server (`localLink` is empty), the application connects to MediaSFU Cloud.
/// - **MediaSFU Cloud Egress Features**: To enable cloud recording, capturing, and returning real-time images and audio buffers,
///   set `connectMediaSFU` to `true` in addition to specifying your `localLink`.
/// - **Credentials Requirement**: If not using your own server, provide `apiUserName` and `apiKey`. The same applies when using MediaSFU Cloud for egress.
/// - **Deprecated Feature**: `useLocalUIMode` is deprecated due to updates for strong typing and improved configuration options.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ========================
    // ====== CONFIGURATION ======
    // ========================

    // Mediasfu account credentials
    // Replace 'your_api_username' and 'your_api_key' with your actual credentials
    // Not needed if using a custom server with no MediaSFU Cloud Egress (recording, ...)

    // Note: If not even using the credentials, modify the apiKey part from 'your_api_key' to say 'your_api' or something else
    // If not, the Prejoin page will not be able to be used for your own server

    final Credentials credentials = Credentials(
      apiUserName: 'your_api_username',
      apiKey: 'your_api_key',
    );

    // Specify your Community Edition (CE) server link or leave as an empty string if not using a custom server
    const String localLink =
        'http://localhost:3000'; // Set to '' if not using your own server

    /**
     * Automatically set `connectMediaSFU` to `true` if `localLink` is provided,
     * indicating the use of MediaSFU Cloud by default.
     *
     * - If `localLink` is not empty, MediaSFU Cloud will be used for additional features.
     * - If `localLink` is empty, the application will connect to MediaSFU Cloud by default.
     */
    final bool connectMediaSFU = localLink.trim().isNotEmpty;

    // ========================
    // ====== USE CASES ======
    // ========================

    // Deprecated Feature: useLocalUIMode
    // This feature is deprecated due to updates for strong typing.
    // It is no longer required and should not be used in new implementations.

    /**
     * Uncomment and configure the following section if you intend to use seed data
     * for generating random participants and messages.
     *
     * Note: This is deprecated and maintained only for legacy purposes.
     */
    /*
    const bool useSeed = false;
    SeedData? seedData;

    if (useSeed) {
      const String memberName = 'Prince';
      const String hostName = 'Fred';

      final participants = generateRandomParticipants(
        GenerateRandomParticipantsOptions(
          member: memberName,
          coHost: '',
          host: hostName,
          forChatBroadcast:
              eventType == EventType.chat || eventType == EventType.broadcast,
        ),
      );

      final messages = generateRandomMessages(
        GenerateRandomMessagesOptions(
          participants: participants,
          member: memberName,
          host: hostName,
          forChatBroadcast:
              eventType == EventType.chat || eventType == EventType.broadcast,
        ),
      );

      final requests = generateRandomRequestList(
        GenerateRandomRequestListOptions(
          participants: participants,
          hostName: memberName,
          coHostName: '',
          numberOfRequests: 3,
        ),
      );

      final waitingList = generateRandomWaitingRoomList();

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

    // ========================
    // ====== COMPONENT SELECTION ======
    // ========================

    /**
     * Choose the Mediasfu component based on the event type and use case.
     * Uncomment the component corresponding to your specific use case.
     */

    // ------------------------
    // ====== SIMPLE USE CASE ======
    // ------------------------

    /**
     * **Simple Use Case (Welcome Page)**
     *
     * Renders the default welcome page.
     * No additional inputs required.
     */
    // return MaterialApp(
    //   title: 'Mediasfu Conference',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: MediasfuConference(),
    // );

    // ------------------------
    // ====== PRE-JOIN USE CASE ======
    // ------------------------

    /**
     * **Use Case with Pre-Join Page (Credentials Required)**
     *
     * Uses a pre-join page that requires users to enter credentials.
     */
    // final MediasfuConferenceOptions options = MediasfuConferenceOptions(
    //   preJoinPageWidget: PreJoinPage(),
    //   credentials: credentials,
    // );
    // return MaterialApp(
    //   title: 'Mediasfu Conference with Pre-Join',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: MediasfuConference(options: options),
    // );

    // ------------------------
    // ====== SEED DATA USE CASE ======
    // ------------------------

    /**
     * **Use Case with Local UI Mode (Seed Data Required)**
     *
     * Runs the application in local UI mode using seed data.
     *
     * @deprecated Due to updates for strong typing, this feature is deprecated.
     */
    // final MediasfuConferenceOptions options = MediasfuConferenceOptions(
    //   useLocalUIMode: true,
    //   useSeed: true,
    //   seedData: seedData!,
    // );
    // return MaterialApp(
    //   title: 'Mediasfu Conference with Seed Data',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: MediasfuConference(options: options),
    // );

    // ------------------------
    // ====== Conference EVENT TYPE ======
    // ------------------------

    /**
     * **MediasfuConference Component**
     *
     * Uncomment to use the Conference event type.
     */
    /*
    final MediasfuConferenceOptions options = MediasfuConferenceOptions(
      credentials: credentials,
      localLink: localLink,
      connectMediaSFU: connectMediaSFU,
      // seedData: useSeed ? seedData : null,
    );
    return MaterialApp(
      title: 'Mediasfu Conference',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuConference(options: options),
    );
    */

    // ========================
    // ====== DEFAULT COMPONENT ======
    // ========================

    /**
     * **Default to MediasfuConference with Updated Configuration**
     *
     * Renders the welcome page with specified server and cloud connection settings.
     */
    final MediasfuConferenceOptions options = MediasfuConferenceOptions(
      // Uncomment the following lines to use a custom pre-join page
      /*
      preJoinPageWidget: ({PreJoinPageOptions? options}) {
        return myCustomPreJoinPage(
          credentials: credentials,
        );
      },
      */

      // Uncomment the following lines to enable local UI mode with seed data; deprecated
      /*
        useLocalUIMode: useLocalUIMode,
        useSeed: useSeed,
        seedData: seedData,
      */

      // Uncomment the following lines to use your own Mediasfu server
      localLink: localLink,

      // Uncomment the following lines to pass your Credentials if not using MediaSFU Cloud (primarily or secondarily)
      // MediaSFU Cloud handles recording and other egress processes for MediaSFU Community Edition
      // You need to pass your own Mediasfu server link if you are using MediaSFU Community Edition
      // Pass your credentials if you will be using MediaSFU Cloud for recording and other egress processes or as your primary server

      credentials: credentials,

      // Uncomment the following lines to use your own Mediasfu server with MediaSFU Cloud (for recording and other egress purposes)
      // If you are using MediaSFU Cloud for recording and other egress processes, set connectMediaSFU to true
      connectMediaSFU: connectMediaSFU,
    );
    return MaterialApp(
      title: 'Mediasfu Conference',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuConference(options: options),
    );
  }
}
