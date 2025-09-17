// Example: Custom Builder Implementation for MediaSFU SDK
// This example demonstrates how to pass custom builders through the component hierarchy
// from MediasfuGeneric to the VideoCard, AudioCard, and MiniCard components.

import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

/// A custom pre-join page widget that can be used instead of the default MediaSFU pre-join page.
///
/// This widget displays information about custom builders and includes a button to proceed to the session.
///
/// **Note:** Ensure this widget is passed to [MediasfuGenericOptions] only when you intend to use a custom pre-join page.
Widget myCustomPreJoinPage({
  PreJoinPageOptions? options,
  required Credentials credentials,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Custom Builders Demo'),
      backgroundColor: Colors.purple.shade800,
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
            'This demo showcases custom MediaSFU builders:',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Custom VideoCard with gradient styling'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.audiotrack, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Custom AudioCard with unique design'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.crop_free, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Custom MiniCard with custom appearance'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Proceed to the session by updating the validation status
              if (options != null) {
                options.parameters.updateValidated(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Join Custom Builders Demo'),
          ),
        ],
      ),
    ),
  );
}

/// The main application widget for MediaSFU Custom Builders Demo.
///
/// This widget demonstrates the custom builder implementation without using
/// localUIMode or seed data, following the standard MediaSFU pattern.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Provides access to the source parameters if not using the default UI (returnUI = false in options)
  final ValueNotifier<MediasfuParameters?> sourceParameters =
      ValueNotifier(null);

  // Update function to update source parameters if not using the default UI (returnUI = false in options)
  void updateSourceParameters(MediasfuParameters? parameters) {
    sourceParameters.value = parameters;
  }

  @override
  void initState() {
    super.initState();

    // Attach the listener
    sourceParameters.addListener(() {
      _onSourceParametersChanged(sourceParameters.value);
    });
  }

  @override
  void dispose() {
    // Detach the listener
    sourceParameters.removeListener(() {
      _onSourceParametersChanged(sourceParameters.value);
    });
    sourceParameters.dispose();
    super.dispose();
  }

  /// Listener for changes in sourceParameters.
  void _onSourceParametersChanged(MediasfuParameters? parameters) {
    if (parameters != null) {
      // Add custom logic here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================
    //                API CREDENTIALS CONFIGURATION
    // =========================================================

    /**
     * For development purposes - using MediaSFU Cloud
     * In production, securely handle credentials server-side
     */
    final credentials = Credentials(
      apiUserName: 'dummyUsr',
      apiKey:
          '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    );
    const localLink = ''; // Leave empty if not using your own server
    const connectMediaSFU = true; // Set to true if using MediaSFU Cloud

    // =========================================================
    //                    CONFIGURATION
    // =========================================================

    bool returnUI = true; // Set to false to use a custom UI

    final MediasfuGenericOptions options = MediasfuGenericOptions(
      // Custom pre-join page to explain the demo
      // preJoinPageWidget: ({PreJoinPageOptions? options}) {
      //   return myCustomPreJoinPage(
      //     options: options,
      //     credentials: credentials,
      //   );
      // },

      // Standard MediaSFU configuration
      credentials: credentials,
      connectMediaSFU: connectMediaSFU,
      localLink: localLink,
      returnUI: returnUI,

      // Custom room functions
      createMediaSFURoom: createRoomOnMediaSFU,
      joinMediaSFURoom: joinRoomOnMediaSFU,

      // // Custom VideoCard builder - replaces the default VideoCard entirely
      // customVideoCard: ({
      //   required participant,
      //   required stream,
      //   required width,
      //   required height,
      //   imageSize,
      //   doMirror,
      //   showControls,
      //   showInfo,
      //   name,
      //   backgroundColor,
      //   onVideoPress,
      //   parameters,
      // }) {
      //   return Container(
      //     width: width,
      //     height: height,
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.purple.shade800, Colors.blue.shade600],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //       borderRadius: BorderRadius.circular(16),
      //       border: Border.all(color: Colors.white, width: 3),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black26,
      //           blurRadius: 10,
      //           offset: Offset(0, 5),
      //         ),
      //       ],
      //     ),
      //     child: Stack(
      //       children: [
      //         // Video content would go here
      //         ClipRRect(
      //           borderRadius: BorderRadius.circular(13),
      //           child: Container(
      //             width: double.infinity,
      //             height: double.infinity,
      //             color: Colors.black54,
      //             child: Center(
      //               child: Icon(
      //                 Icons.videocam,
      //                 size: 64,
      //                 color: Colors.white70,
      //               ),
      //             ),
      //           ),
      //         ),

      //         // Custom overlay with participant info
      //         if (showInfo == true)
      //           Positioned(
      //             top: 12,
      //             left: 12,
      //             child: Container(
      //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //               decoration: BoxDecoration(
      //                 color: Colors.black54,
      //                 borderRadius: BorderRadius.circular(20),
      //               ),
      //               child: Row(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   Icon(Icons.person, color: Colors.white, size: 16),
      //                   SizedBox(width: 4),
      //                   Text(
      //                     name ?? participant.name,
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 12,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),

      //         // Custom controls overlay
      //         if (showControls == true)
      //           Positioned(
      //             bottom: 12,
      //             right: 12,
      //             child: Container(
      //               padding: EdgeInsets.all(8),
      //               decoration: BoxDecoration(
      //                 color: Colors.black54,
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //               child: Row(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   Icon(Icons.mic, color: Colors.white, size: 20),
      //                   SizedBox(width: 8),
      //                   Icon(Icons.videocam, color: Colors.white, size: 20),
      //                 ],
      //               ),
      //             ),
      //           ),
      //       ],
      //     ),
      //   );
      // },

      // // Custom AudioCard builder - for audio-only participants
      // customAudioCard: ({
      //   required name,
      //   required barColor,
      //   required textColor,
      //   required imageSource,
      //   required roundedImage,
      //   required imageStyle,
      //   parameters,
      // }) {
      //   return Container(
      //     padding: EdgeInsets.all(16),
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.orange.shade600, Colors.red.shade500],
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomCenter,
      //       ),
      //       borderRadius: BorderRadius.circular(20),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black26,
      //           blurRadius: 8,
      //           offset: Offset(0, 4),
      //         ),
      //       ],
      //     ),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         // Avatar
      //         Container(
      //           width: 60,
      //           height: 60,
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             shape: BoxShape.circle,
      //             border: Border.all(color: Colors.white, width: 3),
      //           ),
      //           child: Center(
      //             child: Text(
      //               name.isNotEmpty ? name[0].toUpperCase() : '?',
      //               style: TextStyle(
      //                 fontSize: 24,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.orange.shade600,
      //               ),
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 8),

      //         // Name with audio indicator
      //         Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Icon(
      //               Icons.mic,
      //               color: barColor ? Colors.red : Colors.white,
      //               size: 16,
      //             ),
      //             SizedBox(width: 4),
      //             Text(
      //               name,
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 14,
      //               ),
      //               maxLines: 1,
      //               overflow: TextOverflow.ellipsis,
      //             ),
      //           ],
      //         ),

      //         // Audio wave indicator
      //         if (barColor)
      //           Container(
      //             margin: EdgeInsets.only(top: 8),
      //             child: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: List.generate(
      //                 5,
      //                 (index) => Container(
      //                   width: 3,
      //                   height: 12 + (index % 3) * 6,
      //                   margin: EdgeInsets.symmetric(horizontal: 1),
      //                   decoration: BoxDecoration(
      //                     color: Colors.white,
      //                     borderRadius: BorderRadius.circular(2),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //       ],
      //     ),
      //   );
      // },

      // // Custom MiniCard builder - for inactive participants
      // customMiniCard: ({
      //   required initials,
      //   required fontSize,
      //   customStyle,
      //   required name,
      //   required showVideoIcon,
      //   required showAudioIcon,
      //   required imageSource,
      //   required roundedImage,
      //   required imageStyle,
      //   parameters,
      // }) {
      //   return Container(
      //     padding: EdgeInsets.all(12),
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.grey.shade600, Colors.grey.shade800],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //       borderRadius: BorderRadius.circular(12),
      //       border: Border.all(color: Colors.grey.shade300, width: 2),
      //     ),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         // Initials circle
      //         Container(
      //           width: 40,
      //           height: 40,
      //           decoration: BoxDecoration(
      //             color: Colors.grey.shade300,
      //             shape: BoxShape.circle,
      //           ),
      //           child: Center(
      //             child: Text(
      //               initials,
      //               style: TextStyle(
      //                 fontSize: double.tryParse(fontSize) ?? 16,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.grey.shade800,
      //               ),
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 6),

      //         // Name
      //         Text(
      //           name,
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 12,
      //             fontWeight: FontWeight.w500,
      //           ),
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //         ),

      //         // Status indicators
      //         Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             if (showVideoIcon)
      //               Icon(Icons.videocam_off, color: Colors.red, size: 12),
      //             if (showVideoIcon && showAudioIcon) SizedBox(width: 4),
      //             if (showAudioIcon)
      //               Icon(Icons.mic_off, color: Colors.red, size: 12),
      //           ],
      //         ),
      //       ],
      //     ),
      //   );
      // },
    );

    return MaterialApp(
      title: 'MediaSFU Custom Builders Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MediasfuGeneric(options: options),
    );
  }
}

/**
 * =======================
 * ====== EXTRA NOTES ======
 * =======================
 *
 * ### Custom Builder Implementation
 * This example demonstrates how to implement custom builders for MediaSFU components:
 *
 * 1. **Custom VideoCard**: Purple-blue gradient styling with custom overlays
 * 2. **Custom AudioCard**: Orange-red gradient for audio-only participants
 * 3. **Custom MiniCard**: Grey gradient for inactive participants
 *
 * ### Integration Notes
 * - Custom builders are passed through the MediaSFU component hierarchy
 * - They receive all necessary parameters from the original components
 * - You can customize styling, layout, and behavior while maintaining functionality
 *
 * ### Security Considerations
 * - Protect API credentials in production
 * - Use environment variables and secure backend services
 * - This example uses dummy credentials for demonstration purposes
 */

/// Custom MediaSFU Component that completely replaces the default interface
/// This demonstrates how to build your own MediaSFU interface using the parameters
Widget myCustomMediaSFUComponent({
  required MediasfuParameters parameters,
}) {
  return Scaffold(
    backgroundColor: Colors.grey.shade900,
    appBar: AppBar(
      title: const Text('My Custom MediaSFU Interface'),
      backgroundColor: Colors.purple.shade800,
      elevation: 0,
    ),
    body: Column(
      children: [
        // Custom header with room info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room: ${parameters.roomName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Participants: ${parameters.participants.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Custom video/audio controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Video toggle button
              ElevatedButton.icon(
                onPressed: () {
                  parameters
                      .clickVideo(ClickVideoOptions(parameters: parameters));
                },
                icon: Icon(
                  parameters.videoAction ? Icons.videocam : Icons.videocam_off,
                  color: Colors.white,
                ),
                label: Text(
                  parameters.videoAction ? 'Video On' : 'Video Off',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      parameters.videoAction ? Colors.green : Colors.red,
                ),
              ),

              // Audio toggle button
              ElevatedButton.icon(
                onPressed: () {
                  parameters
                      .clickAudio(ClickAudioOptions(parameters: parameters));
                },
                icon: Icon(
                  parameters.micAction ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                ),
                label: Text(
                  parameters.micAction ? 'Audio On' : 'Audio Off',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      parameters.micAction ? Colors.green : Colors.red,
                ),
              ),

              // Screen share button
              ElevatedButton.icon(
                onPressed: () {
                  parameters.clickScreenShare(
                      ClickScreenShareOptions(parameters: parameters));
                },
                icon: Icon(
                  parameters.screenAction
                      ? Icons.stop_screen_share
                      : Icons.screen_share,
                  color: Colors.white,
                ),
                label: Text(
                  parameters.screenAction ? 'Stop Share' : 'Share Screen',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      parameters.screenAction ? Colors.orange : Colors.blue,
                ),
              ),
            ],
          ),
        ),

        // Custom participants list
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Participants',
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
                      ? const Center(
                          child: Text(
                            'No participants yet',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: parameters.participants.length,
                          itemBuilder: (context, index) {
                            final participant = parameters.participants[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.purple.shade600,
                                    child: Text(
                                      participant.name.isNotEmpty
                                          ? participant.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          participant.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
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
                                      Icon(
                                        participant.muted ?? false
                                            ? Icons.mic_off
                                            : Icons.mic,
                                        color: participant.muted ?? false
                                            ? Colors.red
                                            : Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        participant.videoOn ?? false
                                            ? Icons.videocam
                                            : Icons.videocam_off,
                                        color: participant.videoOn ?? false
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // Custom footer with room controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add custom functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Text('Messages',
                    style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add custom functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  // End call functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                child:
                    const Text('Leave', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
