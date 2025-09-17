/// Complete Custom Component Example for MediaSFU SDK
/// 
/// This example demonstrates how to use the CustomComponentType functionality
/// to completely replace the default MediaSFU interface with your own custom widget.
/// 
/// The CustomComponentType allows you to provide a completely custom interface
/// while still having access to all MediaSFU parameters and functionality.

import 'package:flutter/material.dart';
import 'package:mediasfu_sdk/mediasfu_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom MediaSFU Component Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CustomComponentDemo(),
    );
  }
}

class CustomComponentDemo extends StatelessWidget {
  const CustomComponentDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom MediaSFU Component'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose MediaSFU Component Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Generic Component with Custom Interface
            ElevatedButton(
              onPressed: () => _showCustomGeneric(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Custom Generic Component'),
            ),
            const SizedBox(height: 20),
            
            // Conference Component with Custom Interface
            ElevatedButton(
              onPressed: () => _showCustomConference(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Custom Conference Component'),
            ),
            const SizedBox(height: 20),
            
            // Broadcast Component with Custom Interface
            ElevatedButton(
              onPressed: () => _showCustomBroadcast(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Custom Broadcast Component'),
            ),
            const SizedBox(height: 20),
            
            // Chat Component with Custom Interface
            ElevatedButton(
              onPressed: () => _showCustomChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Custom Chat Component'),
            ),
            const SizedBox(height: 20),
            
            // Webinar Component with Custom Interface
            ElevatedButton(
              onPressed: () => _showCustomWebinar(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Custom Webinar Component'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomGeneric(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediasfuGeneric(
          options: MediasfuGenericOptions(
            // Replace the entire MediaSFU interface with your custom component
            customComponent: myCustomGenericInterface,
          ),
        ),
      ),
    );
  }

  void _showCustomConference(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediasfuConference(
          options: MediasfuConferenceOptions(
            customComponent: myCustomConferenceInterface,
          ),
        ),
      ),
    );
  }

  void _showCustomBroadcast(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediasfuBroadcast(
          options: MediasfuBroadcastOptions(
            customComponent: myCustomBroadcastInterface,
          ),
        ),
      ),
    );
  }

  void _showCustomChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediasfuChat(
          options: MediasfuChatOptions(
            customComponent: myCustomChatInterface,
          ),
        ),
      ),
    );
  }

  void _showCustomWebinar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediasfuWebinar(
          options: MediasfuWebinarOptions(
            customComponent: myCustomWebinarInterface,
          ),
        ),
      ),
    );
  }
}

/// Custom Generic Interface
/// This replaces the entire MediaSFU Generic interface
Widget myCustomGenericInterface({required MediasfuParameters parameters}) {
  return _buildCustomInterface(
    parameters: parameters,
    title: 'Custom Generic MediaSFU',
    backgroundColor: Colors.purple.shade900,
    accentColor: Colors.purple.shade600,
  );
}

/// Custom Conference Interface
Widget myCustomConferenceInterface({required MediasfuParameters parameters}) {
  return _buildCustomInterface(
    parameters: parameters,
    title: 'Custom Conference Room',
    backgroundColor: Colors.blue.shade900,
    accentColor: Colors.blue.shade600,
  );
}

/// Custom Broadcast Interface
Widget myCustomBroadcastInterface({required MediasfuParameters parameters}) {
  return _buildCustomInterface(
    parameters: parameters,
    title: 'Custom Broadcast Studio',
    backgroundColor: Colors.red.shade900,
    accentColor: Colors.red.shade600,
  );
}

/// Custom Chat Interface
Widget myCustomChatInterface({required MediasfuParameters parameters}) {
  return _buildCustomInterface(
    parameters: parameters,
    title: 'Custom Chat Room',
    backgroundColor: Colors.green.shade900,
    accentColor: Colors.green.shade600,
  );
}

/// Custom Webinar Interface
Widget myCustomWebinarInterface({required MediasfuParameters parameters}) {
  return _buildCustomInterface(
    parameters: parameters,
    title: 'Custom Webinar Hall',
    backgroundColor: Colors.orange.shade900,
    accentColor: Colors.orange.shade600,
  );
}

/// Shared custom interface builder
Widget _buildCustomInterface({
  required MediasfuParameters parameters,
  required String title,
  required Color backgroundColor,
  required Color accentColor,
}) {
  return Scaffold(
    backgroundColor: backgroundColor,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    body: Column(
      children: [
        // Header with room information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.meeting_room, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Room: ${parameters.roomName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Participants: ${parameters.participants.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.person, color: Colors.white70, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    parameters.member,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Media control buttons
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
              _buildControlButton(
                onPressed: () => parameters.clickVideo(
                  ClickVideoOptions(parameters: parameters),
                ),
                icon: parameters.videoAction ? Icons.videocam : Icons.videocam_off,
                label: parameters.videoAction ? 'Video On' : 'Video Off',
                isActive: parameters.videoAction,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
              ),
              _buildControlButton(
                onPressed: () => parameters.clickAudio(
                  ClickAudioOptions(parameters: parameters),
                ),
                icon: parameters.micAction ? Icons.mic : Icons.mic_off,
                label: parameters.micAction ? 'Mic On' : 'Mic Off',
                isActive: parameters.micAction,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
              ),
              _buildControlButton(
                onPressed: () => parameters.clickScreenShare(
                  ClickScreenShareOptions(parameters: parameters),
                ),
                icon: parameters.screenAction 
                    ? Icons.stop_screen_share 
                    : Icons.screen_share,
                label: parameters.screenAction ? 'Stop Share' : 'Share',
                isActive: parameters.screenAction,
                activeColor: Colors.orange,
                inactiveColor: Colors.blue,
              ),
            ],
          ),
        ),
        
        // Main content area - participants list
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Participants header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Participants (${parameters.participants.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Participants list
                Expanded(
                  child: parameters.participants.isEmpty
                      ? const Center(
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
                                'No participants in the room yet',
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
                            return _buildParticipantCard(participant, accentColor);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom action bar
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
              _buildActionButton(
                onPressed: () {
                  // Custom chat functionality
                },
                icon: Icons.chat,
                label: 'Chat',
                color: Colors.blue.shade600,
              ),
              _buildActionButton(
                onPressed: () {
                  // Custom settings functionality
                },
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.green.shade600,
              ),
              _buildActionButton(
                onPressed: () {
                  // Custom leave functionality
                },
                icon: Icons.exit_to_app,
                label: 'Leave',
                color: Colors.red.shade600,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildControlButton({
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

Widget _buildActionButton({
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

Widget _buildParticipantCard(Participant participant, Color accentColor) {
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
        // Avatar
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
        
        // Participant info
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
        
        // Status indicators
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
