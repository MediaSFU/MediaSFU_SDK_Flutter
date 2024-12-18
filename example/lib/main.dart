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
Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Welcome to MediaSFU'),
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
              if (options != null) {
                options.parameters.updateValidated(true);
              }
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
///
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Provides access to the source parameters if not using the default UI (returnUI = false in options). See more in the guide.
  final ValueNotifier<MediasfuParameters?> sourceParameters =
      ValueNotifier(null);

  // Update function to update source parameters if not using the default UI (returnUI = false in options). See more in the guide.
  void updateSourceParameters(MediasfuParameters? parameters) {
    sourceParameters.value = parameters;
    // _onSourceParametersChanged(parameters);
  }

  // =========================================================
  //   CUSTOM USAGE OF SOURCE PARAMETERS FOR NON-DEFAULT UI
  // =========================================================

  // trigger click video after 5 seconds; this is just an example, best usage is building a custom UI
  // to handle these functionalities with buttons clicks, etc.
  //
  void triggerClickVideo() {
    Future.delayed(const Duration(seconds: 5), () {
      sourceParameters.value
          ?.clickVideo(ClickVideoOptions(parameters: sourceParameters.value!));
    });
  }

  @override
  void initState() {
    super.initState();

    // Attach the listener
    sourceParameters.addListener(() {
      _onSourceParametersChanged(sourceParameters.value);
    });

    // trigger click video after 5 seconds, uncomment to trigger
    // triggerClickVideo();
  }

  @override
  void dispose() {
    // Detach the listener; irrelevant if not 'returnUI = false'
    // Comment out if not using sourceParameters
    sourceParameters.removeListener(() {
      _onSourceParametersChanged(sourceParameters.value);
    });
    sourceParameters.dispose();
    super.dispose();
  }

  // ==============================================================
  //  SOURCE PARAMETERS LISTENER (REQUIRED ONLY IF USING CUSTOM UI)
  // ==============================================================

  /// Listener for changes in sourceParameters.
  /// Prints the updated parameters to the console whenever they change.
  void _onSourceParametersChanged(MediasfuParameters? parameters) {
    if (parameters != null) {
      // if (kDebugMode) {
      //   print('Source Parameters Updated: ${parameters.roomName}');
      // }
      // Add custom logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================
    //                API CREDENTIALS CONFIGURATION
    // =========================================================

    /**
     * Scenario A: Not using MediaSFU Cloud at all.
     * - No credentials needed. Just set localLink to your CE server.
     * Example:
     */
    /*
    final credentials = Credentials(
      apiUserName: '',
      apiKey: '',
    );
    final localLink = 'http://your-ce-server.com'; // e.g., http://localhost:3000
    final connectMediaSFU = localLink.trim().isNotEmpty;
    */

    /**
     * Scenario B: Using MediaSFU CE + MediaSFU Cloud for Egress only.
     * - Use dummy credentials (8 chars for userName, 64 chars for apiKey).
     * - Your CE backend will forward requests with your real credentials.
     */
    /*
    final credentials = Credentials(
      apiUserName: 'dummyUsr',
      apiKey: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    );
    final localLink = 'http://your-ce-server.com'; // e.g., http://localhost:3000
    final connectMediaSFU = localLink.trim().isNotEmpty; // Set to true if using MediaSFU CE
    */

    /**
     * Scenario C: Using MediaSFU Cloud without your own server.
     * - For development, use your actual or dummy credentials.
     * - In production, securely handle credentials server-side and use custom room functions.
     */
    final credentials = Credentials(
      apiUserName: 'yourDevUser', // 8 chars recommended for dummy
      apiKey:
          'yourDevApiKey1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef', // 64 chars
    );
    const localLink = ''; // Leave empty if not using your own server
    const connectMediaSFU =
        true; // Set to true if using MediaSFU Cloud since localLink is empty

    // =========================================================
    //                    UI RENDERING OPTIONS
    // =========================================================

    /**
     * If you want a fully custom UI (e.g., a custom layout inspired by WhatsApp):
     * 1. Set `returnUI = false` to prevent the default MediaSFU UI from rendering.
     * 2. Provide `noUIPreJoinOptions` to simulate what would have been entered on a pre-join page.
     * 3. Use `sourceParameters` and `updateSourceParameters` to access and update state/actions.
     * 4. No need for any of the above if you're using the default MediaSFU UI.
     */

    // Example noUIPreJoinOptions for creating a room
    final CreateMediaSFURoomOptions noUIPreJoinOptionsCreate =
        CreateMediaSFURoomOptions(
      action: 'create',
      capacity: 10,
      duration: 15,
      eventType: EventType.broadcast,
      userName: 'Prince',
    );

    // Example noUIPreJoinOptions for joining a room
    /*
    final JoinMediaSFURoomOptions noUIPreJoinOptionsJoin = JoinMediaSFURoomOptions(
      action: 'join',
      userName: 'Prince',
      meetingID: 'yourMeetingID',
    );
    */

    const bool returnUI =
        true; // Set to false for custom UI, true for default MediaSFU UI

    // State management using ValueNotifier (can be replaced with other state management solutions)
    final ValueNotifier<MediasfuParameters?> sourceParameters =
        ValueNotifier(null);

    // void updateSourceParameters(MediasfuParameters? data) {
    //   sourceParameters.value = data;
    // }

    // =========================================================
    //                CUSTOM ROOM FUNCTIONS (OPTIONAL)
    // =========================================================

    /**
     * To securely forward requests to MediaSFU:
     * - Implement custom `createMediaSFURoom` and `joinMediaSFURoom` functions.
     * - These functions send requests to your server, which then communicates with MediaSFU Cloud.
     *
     * Already implemented `createRoomOnMediaSFU` and `joinRoomOnMediaSFU` are examples.
     *
     * If using MediaSFU CE backend, ensure your server endpoints:
     * - Validate dummy credentials.
     * - Forward requests to mediasfu.com with real credentials.
     */

    // =========================================================
    //              CHOOSE A USE CASE / COMPONENT
    // =========================================================

    /**
     * Multiple components are available depending on your event type:
     * MediasfuBroadcast, MediasfuChat, MediasfuWebinar, MediasfuConference
     *
     * By default, we'll use MediasfuGeneric with custom settings.
     */

    // =========================================================
    //                    RENDER COMPONENT
    // =========================================================

    /**
     * The MediasfuGeneric component is used by default.
     * You can replace it with any other component based on your event type.
     * Example: MediasfuBroadcast(options: ...)
     * Example: MediasfuChat(options: ...)
     * Example: MediasfuWebinar(options: ...)
     * Example: MediasfuConference(options: ...)
     *
     * The PreJoinPage component is displayed if `returnUI` is true.
     * If `returnUI` is false, `noUIPreJoinOptions` is used as a substitute.
     * You can also use `sourceParameters` to interact with MediaSFU functionalities directly.
     * Avoid using `useLocalUIMode` or `useSeed` in new implementations.
     * Ensure that real credentials are not exposed in the frontend.
     * Use HTTPS and secure backend endpoints for production.
     */

    // Example configurations (uncomment as needed)

    /*
    // Example of MediaSFU CE with no MediaSFU Cloud
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      localLink: localLink,
    );
    */

    /*
    // Example of MediaSFU CE + MediaSFU Cloud for Egress only
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      credentials: credentials,
      localLink: localLink,
      connectMediaSFU: connectMediaSFU,
    );
    */

    /*
    // Example of MediaSFU Cloud only
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      credentials: credentials,
      connectMediaSFU: connectMediaSFU,
    );
    */

    /*
    // Example of MediaSFU CE + MediaSFU Cloud for Egress only with custom UI
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      credentials: credentials,
      localLink: localLink,
      connectMediaSFU: connectMediaSFU,
      returnUI: false,
      noUIPreJoinOptions: noUIPreJoinOptionsCreate,
      sourceParameters: sourceParameters.value,
      updateSourceParameters: updateSourceParameters,
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,
    );
    */

    /*
    // Example of MediaSFU Cloud only with custom UI
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      credentials: credentials,
      connectMediaSFU: connectMediaSFU,
      returnUI: false,
      noUIPreJoinOptions: noUIPreJoinOptionsCreate,
      sourceParameters: sourceParameters.value,
      updateSourceParameters: updateSourceParameters,
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,
    );
    */

    /*
    // Example of using MediaSFU CE only with custom UI
    final options = MediasfuGenericOptions(
      preJoinPageWidget: PreJoinPage(),
      localLink: localLink,
      connectMediaSFU: false,
      returnUI: false,
      noUIPreJoinOptions: noUIPreJoinOptionsCreate,
      sourceParameters: sourceParameters.value,
      updateSourceParameters: updateSourceParameters,
    );
    */

    // === Main Activated Example ===
    // Default to MediasfuGeneric with credentials and custom UI options
    final MediasfuGenericOptions options = MediasfuGenericOptions(
      // Uncomment the following lines to use a custom pre-join page
      /*
      preJoinPageWidget: ({PreJoinPageOptions? options}) {
        return myCustomPreJoinPage(
          credentials: credentials,
        );
      },
      */

      // Uncomment the following lines to enable local UI mode with seed data
      /*
      useLocalUIMode: true,
      useSeed: true,
      seedData: seedData,
      */

      // Pass your Credentials if you will be using MediaSFU Cloud for recording and other egress processes or as your primary server
      credentials: credentials,

      // Use your own MediaSFU server link if you are using MediaSFU Community Edition
      // Pass your credentials if you will be using MediaSFU Cloud for recording and other egress processes or as your primary server
      connectMediaSFU: connectMediaSFU,

      // Uncomment the following line to specify your own MediaSFU Community Edition server
      localLink: localLink, // e.g., 'http://localhost:3000'

      // Set to false to use a custom UI, true to use the default MediaSFU UI
      returnUI: returnUI,

      // Provide pre-join options if not using the default UI (if creating a room)
      noUIPreJoinOptionsCreate:
          !returnUI ? noUIPreJoinOptionsCreate : null, // if creating a room

      // Provide pre-join options if not using the default UI (if joining a room)
      // noUIPreJoinOptionsJoin: !returnUI ? noUIPreJoinOptionsJoin : null, // if joining a room

      // Manage source parameters if not using the default UI
      sourceParameters: !returnUI ? sourceParameters.value : null,

      // Update source parameters if not using the default UI
      updateSourceParameters: !returnUI ? updateSourceParameters : null,

      // Provide custom room functions if not using the default functions
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,
    );

    return MaterialApp(
      title: 'MediaSFU Generic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuGeneric(options: options),
    );

    // === Alternative Use Cases ===
    // Uncomment the desired block to use a different MediaSFU component

    /*
    // Simple Use Case (Welcome Page)
    // Renders the default welcome page
    // No additional inputs required
    return MaterialApp(
      title: 'MediaSFU Welcome',
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
      title: 'MediaSFU Pre-Join',
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
      title: 'MediaSFU Local UI',
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
      title: 'MediaSFU Broadcast',
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
      title: 'MediaSFU Chat',
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
      title: 'MediaSFU Webinar',
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
      title: 'MediaSFU Conference',
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

/**
 * =======================
 * ====== EXTRA NOTES ======
 * =======================
 *
 * ### Handling Core Methods
 * With `sourceParameters`, you can access core methods such as `clickVideo` and `clickAudio`:
 *
 * ```dart
 * // Example of toggling video
 * void toggleVideo(SourceParameters sourceParameters) {
 *   sourceParameters.clickVideo({...sourceParameters});
 * }
 *
 * // Example of toggling audio
 * void toggleAudio(SourceParameters sourceParameters) {
 *   sourceParameters.clickAudio({...sourceParameters});
 * }
 * ```
 *
 * This allows your custom UI to interact with MediaSFU's functionalities seamlessly.
 *
 * ### Seed Data (Deprecated)
 * The seed data functionality is deprecated and maintained only for legacy purposes.
 * It is recommended to avoid using it in new implementations.
 *
 * ### Security Considerations
 * - **Protect API Credentials:** Ensure that API credentials are not exposed in the frontend. Use environment variables and secure backend services to handle sensitive information.
 * - **Use HTTPS:** Always use HTTPS to secure data transmission between the client and server.
 * - **Validate Inputs:** Implement proper validation and error handling on both client and server sides to prevent malicious inputs.
 *
 * ### Custom Backend Example for MediaSFU CE
 * Below is an example of how to set up custom backend endpoints for creating and joining rooms using MediaSFU CE. Assume all unlisted imports are exported by the package:
 *
 * ```typescript
 * import express from 'express';
 * import fetch from 'node-fetch';
 * 
 * const app = express();
 * app.use(express.json());
 * 
 * app.post("/createRoom", async (req, res) => {
 *   try {
 *     const { apiUserName, apiKey } = req.headers.authorization.replace("Bearer ", "").split(":");
 *     if (!apiUserName || !apiKey || !verifyCredentials(apiUserName, apiKey)) {
 *       return res.status(401).json({ error: "Invalid credentials" });
 *     }
 * 
 *     const response = await fetch("https://mediasfu.com/v1/rooms/", {
 *       method: "POST",
 *       headers: {
 *         "Content-Type": "application/json",
 *         Authorization: `Bearer ${apiUserName}:${apiKey}`,
 *       },
 *       body: JSON.stringify(req.body),
 *     });
 * 
 *     const result = await response.json();
 *     res.status(response.status).json(result);
 *   } catch (error) {
 *     res.status(500).json({ error: "Internal server error" });
 *   }
 * });
 * 
 * app.post("/joinRoom", async (req, res) => {
 *   try {
 *     const { apiUserName, apiKey } = req.headers.authorization.replace("Bearer ", "").split(":");
 *     if (!apiUserName || !apiKey || !verifyCredentials(apiUserName, apiKey)) {
 *       return res.status(401).json({ error: "Invalid credentials" });
 *     }
 * 
 *     const response = await fetch("https://mediasfu.com/v1/rooms/join", {
 *       method: "POST",
 *       headers: {
 *         "Content-Type": "application/json",
 *         Authorization: `Bearer ${apiUserName}:${apiKey}`,
 *       },
 *       body: JSON.stringify(req.body),
 *     });
 * 
 *     const result = await response.json();
 *     res.status(response.status).json(result);
 *   } catch (error) {
 *     res.status(500).json({ error: "Internal server error" });
 *   }
 * });
 * ```
 *
 * ### Custom Room Function Implementation
 * Below are examples of how to implement custom functions for creating and joining rooms securely in Dart. Assume all unlisted imports are exported by the package:
 *
 * ```dart
 * Future<CreateJoinRoomResult> createRoomOnMediaSFU(
 *   CreateMediaSFURoomOptions options,
 * ) async {
 *   try {
 *     final payload = options.payload;
 *     final apiUserName = options.apiUserName;
 *     final apiKey = options.apiKey;
 *     String endpoint = 'https://mediasfu.com/v1/rooms/';
 * 
 *     if (options.localLink.isNotEmpty) {
 *       endpoint = '${options.localLink}/createRoom';
 *     }
 * 
 *     final response = await http.post(
 *       Uri.parse(endpoint),
 *       headers: {
 *         "Content-Type": "application/json",
 *         "Authorization": "Bearer $apiUserName:$apiKey",
 *       },
 *       body: jsonEncode(payload.toMap()),
 *     );
 * 
 *     if (response.statusCode == 200 || response.statusCode == 201) {
 *       final data = jsonDecode(response.body);
 *       return CreateJoinRoomResult(
 *         data: CreateJoinRoomResponse.fromJson(data),
 *         success: true,
 *       );
 *     } else {
 *       final error = jsonDecode(response.body);
 *       return CreateJoinRoomResult(
 *         data: CreateJoinRoomError.fromJson(error),
 *         success: false,
 *       );
 *     }
 *   } catch (_) {
 *     return CreateJoinRoomResult(
 *       data: CreateJoinRoomError(error: 'Unknown error'),
 *       success: false,
 *     );
 *   }
 * }
 * 
 * Future<CreateJoinRoomResult> joinRoomOnMediaSFU(
 *   JoinMediaSFURoomOptions options,
 * ) async {
 *   try {
 *     final payload = options.payload;
 *     final apiUserName = options.apiUserName;
 *     final apiKey = options.apiKey;
 *     String endpoint = 'https://mediasfu.com/v1/rooms/join';
 * 
 *     if (options.localLink.isNotEmpty) {
 *       endpoint = '${options.localLink}/joinRoom';
 *     }
 * 
 *     final response = await http.post(
 *       Uri.parse(endpoint),
 *       headers: {
 *         "Content-Type": "application/json",
 *         "Authorization": "Bearer $apiUserName:$apiKey",
 *       },
 *       body: jsonEncode(payload.toMap()),
 *     );
 * 
 *     if (response.statusCode == 200 || response.statusCode == 201) {
 *       final data = jsonDecode(response.body);
 *       return CreateJoinRoomResult(
 *         data: CreateJoinRoomResponse.fromJson(data),
 *         success: true,
 *       );
 *     } else {
 *       final error = jsonDecode(response.body);
 *       return CreateJoinRoomResult(
 *         data: CreateJoinRoomError.fromJson(error),
 *         success: false,
 *       );
 *     }
 *   } catch (_) {
 *     return CreateJoinRoomResult(
 *       data: CreateJoinRoomError(error: 'Unknown error'),
 *       success: false,
 *     );
 *   }
 * }
 * ```
 *
 * #### Assumptions:
 * - All unlisted imports such as `http`, `CreateMediaSFURoomOptions`, `JoinMediaSFURoomOptions`, `CreateJoinRoomResult`, `CreateJoinRoomResponse`, and `CreateJoinRoomError` are exported by the package.
 * - This structure ensures type safety, clear error handling, and flexibility for customization.
 *
 * ========================
 * ====== END OF GUIDE ======
 * ========================
 */
