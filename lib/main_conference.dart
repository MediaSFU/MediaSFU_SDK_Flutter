// ignore_for_file: unused_shown_name, unused_import, unused_local_variable, dead_code
import 'package:flutter/material.dart';
import 'methods/utils/create_room_on_media_sfu.dart' show createRoomOnMediaSFU;
import 'methods/utils/join_room_on_media_sfu.dart' show joinRoomOnMediaSFU;
import 'types/types.dart'
    show
        ClickVideoOptions,
        ClickAudioOptions,
        ClickScreenShareOptions,
        CreateMediaSFURoomOptions,
        EventType,
        MediasfuParameters,
        Participant;

import 'components/mediasfu_components/mediasfu_conference.dart'
    show MediasfuConference, MediasfuConferenceOptions;
import 'components/misc_components/prejoin_page.dart'
    show PreJoinPageOptions, Credentials;

void main() {
  runApp(const MyApp());
}

/// A custom pre-join page widget that can be used instead of the default MediaSFU pre-join page.
///
/// This widget displays a personalized welcome message and includes a button to proceed to the conference session.
///
/// **Note:** Ensure this widget is passed to [MediasfuConferenceOptions] only when you intend to use a custom pre-join page.
Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Welcome to MediaSFU Conference'),
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
            'Get ready to join your conference session.',
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

/// Custom VideoCard builder for conference sessions
/// This replaces the default VideoCard with a custom blue gradient design
Widget myCustomConferenceVideoCard({
  required Participant participant,
  required stream,
  required double width,
  required double height,
  imageSize,
  doMirror,
  showControls,
  showInfo,
  name,
  backgroundColor,
  onVideoPress,
  parameters,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade800, Colors.teal.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Video content placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54,
            child: Center(
              child: Icon(
                Icons.video_call,
                size: 64,
                color: Colors.white70,
              ),
            ),
          ),
        ),
        // Custom conference overlay
        if (showInfo == true)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.teal.shade500],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    name ?? participant.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

/// Custom AudioCard builder for conference sessions
/// Features a blue/teal gradient design for audio-only participants
Widget myCustomConferenceAudioCard({
  required String name,
  required bool barColor,
  textColor,
  cardBackgroundColor,
  customWidth,
  customHeight,
  imageSource,
  roundedImage,
  imageStyle,
}) {
  return Container(
    width: customWidth ?? 100,
    height: customHeight ?? 100,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade700, Colors.teal.shade500],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Conference icon
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.people,
            color: Colors.white,
            size: 32,
          ),
        ),
        SizedBox(height: 8),
        
        // Participant name
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Audio wave indicator
        if (barColor)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                4,
                (index) => Container(
                  width: 4,
                  height: 20 + (index * 3),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Custom MiniCard builder for conference sessions
/// Displays small participant cards with conference-specific styling
Widget myCustomConferenceMiniCard({
  required String name,
  required bool showWaveform,
  overlayPosition,
  barColor,
  textColor,
  imageSource,
  roundedImage,
  imageStyle,
}) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: showWaveform 
            ? [Colors.blue.shade600, Colors.teal.shade400]
            : [Colors.grey.shade700, Colors.grey.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: showWaveform ? Colors.white : Colors.grey.shade400, 
        width: 2,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          showWaveform ? Icons.groups : Icons.person,
          color: Colors.white,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// Complete Custom Conference Interface
/// This replaces the entire MediaSFU conference interface with a custom design
Widget myCustomConferenceInterface({required MediasfuParameters parameters}) {
  return Scaffold(
    backgroundColor: Colors.blue.shade900,
    appBar: AppBar(
      title: Text('🎥 Conference Room'),
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: Column(
      children: [
        // Conference status header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.meeting_room, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conference: ${parameters.roomName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Participants: ${parameters.participants.length}',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Icons.person, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'You: ${parameters.member}',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Conference controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildConferenceControlButton(
                onPressed: () => parameters.clickVideo(
                  ClickVideoOptions(parameters: parameters),
                ),
                icon: parameters.videoAction ? Icons.videocam : Icons.videocam_off,
                label: parameters.videoAction ? 'Video On' : 'Video Off',
                isActive: parameters.videoAction,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
              ),
              _buildConferenceControlButton(
                onPressed: () => parameters.clickAudio(
                  ClickAudioOptions(parameters: parameters),
                ),
                icon: parameters.micAction ? Icons.mic : Icons.mic_off,
                label: parameters.micAction ? 'Mic On' : 'Mic Off',
                isActive: parameters.micAction,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
              ),
              _buildConferenceControlButton(
                onPressed: () => parameters.clickScreenShare(
                  ClickScreenShareOptions(parameters: parameters),
                ),
                icon: parameters.screenAction 
                    ? Icons.stop_screen_share 
                    : Icons.screen_share,
                label: parameters.screenAction ? 'Stop Share' : 'Share Screen',
                isActive: parameters.screenAction,
                activeColor: Colors.orange,
                inactiveColor: Colors.blue,
              ),
            ],
          ),
        ),
        
        // Main conference area - participants list
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Conference Participants (${parameters.participants.length})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: parameters.participants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Waiting for participants to join...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: parameters.participants.length,
                          itemBuilder: (context, index) {
                            final participant = parameters.participants[index];
                            return _buildConferenceParticipantCard(participant, Colors.blue.shade600);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // Conference action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildConferenceActionButton(
                onPressed: () {
                  // Custom chat functionality
                },
                icon: Icons.chat_bubble,
                label: 'Chat',
                color: Colors.blue.shade600,
              ),
              _buildConferenceActionButton(
                onPressed: () {
                  // Custom recording
                },
                icon: Icons.fiber_manual_record,
                label: 'Record',
                color: Colors.red.shade600,
              ),
              _buildConferenceActionButton(
                onPressed: () {
                  // Leave conference
                },
                icon: Icons.exit_to_app,
                label: 'Leave',
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildConferenceControlButton({
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  required bool isActive,
  required Color activeColor,
  required Color inactiveColor,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? activeColor : inactiveColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
  );
}

Widget _buildConferenceActionButton({
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  required Color color,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

Widget _buildConferenceParticipantCard(Participant participant, Color accentColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade700,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade600),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: accentColor,
          radius: 20,
          child: Text(
            participant.name.isNotEmpty 
                ? participant.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                participant.islevel ?? 'participant',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (participant.muted ?? false) ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                (participant.muted ?? false) ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (participant.videoOn ?? false) ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                (participant.videoOn ?? false) ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// The main application widget for MediaSFU Conference.
///
/// This widget initializes the necessary credentials and configuration for the MediaSFU Conference application,
/// including options for creating and joining conference rooms.
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
     * - Dummy credentials are needed to render PreJoinPage. 
     * Example:
     */
    /*
    final credentials = Credentials(
      apiUserName: 'dummyUsr',
      apiKey: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    );
    final localLink = 'http://your-ce-server.com'; // e.g., http://localhost:3000
    final connectMediaSFU = false; // Set to false if not using MediaSFU Cloud
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
    final connectMediaSFU = true; // Set to true if using MediaSFU Cloud for egress
    */

    /**
     * Scenario C: Using MediaSFU Cloud without your own server.
     * - For development, use your actual or dummy credentials.
     * - In production, securely handle credentials server-side and use custom room functions for joining and creating rooms.
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
    //                CUSTOM ROOM FUNCTIONS (OPTIONAL)
    // =========================================================

    /**
     * To securely forward requests to MediaSFU:
     * - Implement custom `createMediaSFURoom` and `joinMediaSFURoom` functions.
     * - These functions send requests to your server, which then communicates with MediaSFU Cloud.
     *
     * Already implemented `createRoomOnMediaSFU` and `joinRoomOnMediaSFU` are examples.
     */

    // =========================================================
    //                    RENDER COMPONENT
    // =========================================================

    /**
     * The MediasfuConference component is used to handle conference events.
     * It allows you to create and join conference rooms with the provided options.
     * 
     * **Note:** Ensure that real credentials are not exposed in the frontend.
     * Use HTTPS and secure backend endpoints for production.
     */

    // === Main Activated Example ===
    // Configured for MediasfuConference with credentials and custom pre-join page
    bool returnUI = true; // Set to false to use a custom UI

    // Example noUIPreJoinOptions for creating a room
    final CreateMediaSFURoomOptions noUIPreJoinOptionsCreate =
        CreateMediaSFURoomOptions(
      action: 'create',
      capacity: 10,
      duration: 15,
      eventType: EventType.conference,
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

    final MediasfuConferenceOptions options = MediasfuConferenceOptions(
      // Uncomment the following lines to use a custom pre-join page
      /*
      preJoinPageWidget: ({PreJoinPageOptions? options}) {
        return myCustomPreJoinPage(
          credentials: credentials,
        );
      },
      */

      // Pass your Credentials if you will be using MediaSFU Cloud for recording and other egress processes or as your primary server
      credentials: credentials,

      // Use your own MediaSFU server link if you are using MediaSFU Community Edition
      // Pass your credentials if you will be using MediaSFU Cloud for recording and other egress processes or as your primary server
      connectMediaSFU: connectMediaSFU,

      // Specify your own MediaSFU Community Edition server if applicable
      localLink: localLink, // e.g., 'http://localhost:3000'

      // Set to false to use a custom UI, true to use the default MediaSFU UI
      returnUI: returnUI,

      // Provide pre-join options if not using the default UI (if creating a room)
      noUIPreJoinOptionsCreate: !returnUI ? noUIPreJoinOptionsCreate : null,

      // Provide pre-join options if not using the default UI (if joining a room)
      // noUIPreJoinOptionsJoin: !returnUI ? noUIPreJoinOptionsJoin : null,

      // Manage source parameters if not using the default UI
      sourceParameters: !returnUI ? sourceParameters.value : null,

      // Update source parameters if not using the default UI
      updateSourceParameters: !returnUI ? updateSourceParameters : null,

      // ======== CUSTOM COMPONENT OPTIONS ========
      // Uncomment ONE of the following sections to enable custom UI components:

      // OPTION 1: Custom builders for individual components (recommended for most customizations)
      /*
      customVideoCard: myCustomConferenceVideoCard,
      customAudioCard: myCustomConferenceAudioCard,
      customMiniCard: myCustomConferenceMiniCard,
      */

      // OPTION 2: Complete custom interface replacement (for advanced customizations)
      /*
      customComponent: myCustomConferenceInterface,
      */

      // Provide custom room functions if not using the default functions
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,
    );

    return MaterialApp(
      title: 'MediaSFU Conference',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediasfuConference(options: options),
    );
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
