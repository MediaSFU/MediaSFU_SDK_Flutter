import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/display_components/audio_card.dart' show AudioCard;
import '../components/display_components/mini_card.dart' show MiniCard;
import '../components/display_components/video_card.dart' show VideoCard;

/// This function [prepopulateUserMedia] is responsible for prepopulating user media components based on the provided parameters.
/// It takes in a [name] and a [parameters] map, and returns a list of dynamic components.
/// The [parameters] map contains various parameters such as participants, video streams, screen sharing status, event type, etc.
/// It destructures the parameters map and initializes variables based on the values.
/// It then checks the event type and returns an empty list if it is 'chat'.
/// If screen sharing is started or shared, it handles the main grid visibility and adjusts the display for screen sharing.
/// It determines if the user is sharing the screen or someone else is sharing.
/// It populates the main screen with the host video if screen sharing is started or shared.
/// If video is off or the user is not the admin, it adds an audio card instead.
/// Finally, it returns the list of components.

typedef UpdateForceFullDisplay = void Function(bool);
typedef UpdateMainScreenPerson = void Function(String);
typedef UpdateMainScreenFilled = void Function(bool);
typedef UpdateAdminOnMainScreen = void Function(bool);
typedef UpdateMainHeightWidth = void Function(double);
typedef UpdateScreenForceFullDisplay = void Function(bool);
typedef UpdateUpdateMainWindow = void Function(bool);
typedef UpdateMainGridStream = void Function(dynamic);

List<dynamic> prepopulateUserMedia({
  required String name,
  required Map<String, dynamic> parameters,
}) {
  try {
    // Destructure parameters
    Map<String, dynamic> updatedParameters =
        parameters['getUpdatedAllParams']();
    List participants = updatedParameters['participants'] ?? [];
    List allVideoStreams = updatedParameters['allVideoStreams'] ?? [];
    String islevel = updatedParameters['islevel'] ?? '1';
    String member = updatedParameters['member'] ?? '';
    bool shared = updatedParameters['shared'] ?? false;
    bool shareScreenStarted = updatedParameters['shareScreenStarted'] ?? false;
    String eventType = updatedParameters['eventType'] ?? '';
    String screenId = updatedParameters['screenId'] ?? '';
    bool forceFullDisplay = updatedParameters['forceFullDisplay'] ?? false;
    bool mainScreenFilled = updatedParameters['mainScreenFilled'] ?? false;
    bool adminOnMainScreen = updatedParameters['adminOnMainScreen'] ?? false;
    String mainScreenPerson = updatedParameters['mainScreenPerson'] ?? '';
    bool videoAlreadyOn = updatedParameters['videoAlreadyOn'] ?? false;
    bool audioAlreadyOn = updatedParameters['audioAlreadyOn'] ?? false;
    List oldAllStreams = updatedParameters['oldAllStreams'];
    Function checkOrientation = updatedParameters['checkOrientation'];
    bool screenForceFullDisplay = updatedParameters['screenForceFullDisplay'];
    dynamic localStreamScreen = updatedParameters['localStreamScreen'];
    List<dynamic> remoteScreenStream =
        updatedParameters['remoteScreenStream'] ?? [];
    dynamic localStreamVideo = updatedParameters['localStreamVideo'];
    double mainHeightWidth = updatedParameters['mainHeightWidth'];
    bool isWideScreen = updatedParameters['isWideScreen'] ?? false;
    bool localUIMode = updatedParameters['localUIMode'] ?? false;
    // Define variables for the functions using typedefs
    final UpdateMainScreenPerson updateMainScreenPerson =
        parameters['updateMainScreenPerson'];
    final UpdateMainScreenFilled updateMainScreenFilled =
        parameters['updateMainScreenFilled'];
    final UpdateAdminOnMainScreen updateAdminOnMainScreen =
        parameters['updateAdminOnMainScreen'];
    final UpdateMainHeightWidth updateMainHeightWidth =
        parameters['updateMainHeightWidth'];
    final UpdateScreenForceFullDisplay updateScreenForceFullDisplay =
        parameters['updateScreenForceFullDisplay'];
    final UpdateUpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];
    final UpdateMainGridStream updateMainGridStream =
        parameters['updateMainGridStream'];

    // If the event type is 'chat', return an empty list
    if (eventType == 'chat') {
      return [];
    }

    // Initialize variables
    Map<String, dynamic>? host;
    dynamic hostStream;
    List<Widget> newComponent = [];

    // Check if screen sharing is started or shared
    if (shareScreenStarted || shared) {
      // Handle main grid visibility based on the event type
      if (eventType == 'conference') {
        if (shared || shareScreenStarted) {
          if (mainHeightWidth == 0) {
            // Add the main grid if not present
            updateMainHeightWidth(84);
          }
        } else {
          // Remove the main grid if not shared or started
          updateMainHeightWidth(0);
        }
      }

      // Switch display to optimize for screen share
      screenForceFullDisplay = forceFullDisplay;

      // Get the orientation and adjust forceFullDisplay
      String orientation = checkOrientation();
      if (orientation == 'portrait' || !isWideScreen) {
        if (shareScreenStarted || shared) {
          screenForceFullDisplay = false;
          updateScreenForceFullDisplay(screenForceFullDisplay);
        }
      }

      // Check if the user is sharing the screen
      if (shared) {
        // User is sharing
        host = {'name': member};
        hostStream = localStreamScreen;

        // Update admin on the main screen
        adminOnMainScreen = islevel == '2';
        updateAdminOnMainScreen(adminOnMainScreen);

        // Update main screen person
        mainScreenPerson = host['name'];
        updateMainScreenPerson(mainScreenPerson);
      } else {
        // Someone else is sharing
        host = participants.firstWhere(
            (participant) =>
                participant['ScreenID'] == screenId &&
                participant['ScreenOn'] == true,
            orElse: () => null);

        host ??= participants.firstWhere(
            (participant) => participant['ScreenOn'] == true,
            orElse: () => null);

        // Check remoteScreenStream
        if (host != null) {
          if (remoteScreenStream.isEmpty) {
            hostStream = allVideoStreams.firstWhere(
                (stream) => stream['producerId'] == host?['ScreenID'],
                orElse: () => null);
          } else {
            hostStream = remoteScreenStream.elementAt(0);
          }
        }
      }
    } else {
      // Screen share not started
      if (eventType == 'conference') {
        // No main grid for conferences
        return [];
      }

      // Find the host with level '2'
      host = participants.firstWhere(
          (participant) => participant['islevel'] == '2',
          orElse: () => null);

      // Update main screen person
      mainScreenPerson = host != null ? host['name'] : '';
      updateMainScreenPerson(mainScreenPerson);
    }

    // If host is not null, check if host videoIsOn
    if (host != null) {
      // Populate the main screen with the host video
      if ((shareScreenStarted || shared) && hostStream != null) {
        forceFullDisplay = screenForceFullDisplay;
        newComponent.add(
          VideoCard(
            key: Key(host['ScreenID'] ?? host['name']),
            videoStream: shared ? hostStream : hostStream!['stream'],
            remoteProducerId: host['ScreenID'] ?? host['name'],
            eventType: eventType,
            forceFullDisplay: forceFullDisplay,
            participant: host,
            backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
            showControls: false,
            showInfo: true,
            name: host['name'],
            doMirror: false,
            parameters: parameters,
          ),
        );

        updateMainGridStream(newComponent);

        mainScreenFilled = true;
        updateMainScreenFilled(mainScreenFilled);
        adminOnMainScreen = host['islevel'] == '2';
        updateAdminOnMainScreen(adminOnMainScreen);
        mainScreenPerson = host['name'];
        updateMainScreenPerson(mainScreenPerson);

        return newComponent;
      }

      // Check if video is already on or not
      if ((islevel != '2' && !host['videoOn']) ||
          (islevel == '2' &&
              (host.containsKey('videoOn') &&
                      (!host['videoOn'] || !videoAlreadyOn) ||
                  localUIMode == true))) {
        // Video is off
        if (islevel == '2' && videoAlreadyOn) {
          // Admin's video is on
          newComponent.add(
            VideoCard(
              key: Key(host['videoID']),
              videoStream: localStreamVideo,
              remoteProducerId: host['videoID'],
              eventType: eventType,
              forceFullDisplay: forceFullDisplay,
              participant: host,
              backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
              showControls: false,
              showInfo: true,
              name: host['name'],
              doMirror: true,
              parameters: parameters,
            ),
          );

          updateMainGridStream(newComponent);

          mainScreenFilled = true;
          updateMainScreenFilled(mainScreenFilled);
          adminOnMainScreen = true;
          updateAdminOnMainScreen(adminOnMainScreen);
          mainScreenPerson = host['name'];
          updateMainScreenPerson(mainScreenPerson);
        } else {
          // Video is off and not admin
          bool audOn = false;

          if ((islevel == '2' && audioAlreadyOn)) {
            audOn = true;
          } else {
            if (islevel != '2') {
              audOn = host['muted'] == false;
            }
          }

          if (audOn) {
            // Audio is on
            try {
              newComponent.add(
                AudioCard(
                  name: host['name'],
                  barColor: const Color.fromARGB(255, 229, 20, 20),
                  textColor: const Color.fromARGB(255, 17, 16, 16),
                  customStyle: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  controlsPosition: 'topLeft',
                  infoPosition: 'topRight',
                  roundedImage: true,
                  parameters: parameters,
                  participant: host,
                  showControls: islevel != '2',
                  backgroundColor: Colors.transparent,
                ),
              );

              updateMainGridStream(newComponent);
            } catch (error) {
              // Handle audio card creation error
            }

            mainScreenFilled = true;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = islevel == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host['name'];
            updateMainScreenPerson(mainScreenPerson);
          } else {
            // Audio is off
            try {
              newComponent.add(
                MiniCard(
                  initials: name,
                  fontSize: 20,
                  customStyle: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              );

              updateMainGridStream(newComponent);
            } catch (error) {
              // Handle mini card creation error
            }

            mainScreenFilled = false;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = islevel == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host['name'];
            updateMainScreenPerson(mainScreenPerson);
          }
        }
      } else {
        // Video is on
        if (shareScreenStarted || shared) {
          // Screen share is on
          try {
            newComponent.add(
              VideoCard(
                key: Key(host['ScreenID'] ?? host['name']),
                videoStream: shared ? hostStream : hostStream!['stream'],
                remoteProducerId: host['ScreenID'] ?? host['name'],
                eventType: eventType,
                forceFullDisplay: forceFullDisplay,
                participant: host,
                backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                showControls: false,
                showInfo: true,
                name: host['name'],
                doMirror: false,
                parameters: parameters,
              ),
            );

            updateMainGridStream(newComponent);

            mainScreenFilled = true;
            updateMainScreenFilled(mainScreenFilled);
            adminOnMainScreen = host['islevel'] == '2';
            updateAdminOnMainScreen(adminOnMainScreen);
            mainScreenPerson = host['name'];
            updateMainScreenPerson(mainScreenPerson);
          } catch (error) {
            // Handle video card creation error
          }
        } else {
          // Screen share is off
          dynamic streame;
          if (islevel == '2') {
            host['stream'] = localStreamVideo;
          } else {
            streame = oldAllStreams.firstWhere(
                (streame) => streame['producerId'] == host!['videoID'],
                orElse: () => null);
            host['stream'] = streame != null ? streame['stream'] : null;
          }

          try {
            if (host['stream'] != null) {
              newComponent.add(
                VideoCard(
                  key: Key(host['videoID']),
                  videoStream: host['stream'],
                  remoteProducerId: host['videoID'],
                  eventType: eventType,
                  forceFullDisplay: forceFullDisplay,
                  participant: host,
                  backgroundColor: const Color.fromRGBO(217, 227, 234, 0.99),
                  showControls: false,
                  showInfo: true,
                  name: host['name'],
                  doMirror: member == host['name'],
                  parameters: parameters,
                ),
              );

              updateMainGridStream(newComponent);
              mainScreenFilled = true;
              adminOnMainScreen = host['islevel'] == '2';
              mainScreenPerson = host['name'];
            } else {
              newComponent.add(
                MiniCard(
                  initials: name,
                  fontSize: 20,
                  customStyle: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              );

              updateMainGridStream(newComponent);
              mainScreenFilled = false;
              adminOnMainScreen = islevel == '2';
              mainScreenPerson = host['name'];
            }

            updateMainScreenFilled(mainScreenFilled);
            updateAdminOnMainScreen(adminOnMainScreen);
            updateMainScreenPerson(mainScreenPerson);
          } catch (error) {
            // Handle video card creation error
          }
        }
      }
    } else {
      // Host is null, add a mini card
      try {
        newComponent.add(
          MiniCard(
            initials: name,
            fontSize: 20,
            customStyle: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        );

        updateMainGridStream(newComponent);

        mainScreenFilled = false;
        adminOnMainScreen = false;
        mainScreenPerson = '';
        updateMainScreenFilled(mainScreenFilled);
        updateAdminOnMainScreen(adminOnMainScreen);
        updateMainScreenPerson(mainScreenPerson);
      } catch (error) {
        // Handle mini card creation error
      }
    }

    updateUpdateMainWindow(false);

    return newComponent;
  } catch (error) {
    // Handle errors during the process of preparing and populating the main screen
    if (kDebugMode) {
      print(
          'Error preparing and populating the main screen: ${error.toString()}');
    }

    // throw error;
    return [];
  }
}
