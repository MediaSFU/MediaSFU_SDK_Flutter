import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show ShowAlert, ConnectSocketType, ConnectSocketOptions;

class PreJoinPageOptions {
  String? imgSrc;
  ShowAlert? showAlert;
  Function(bool) updateIsLoadingModalVisible;
  ConnectSocketType connectSocket;
  Function(io.Socket?) updateSocket;
  Function(bool) updateValidated;
  Function(String) updateApiUserName;
  Function(String) updateApiToken;
  Function(String) updateLink;
  Function(String) updateRoomName;
  Function(String) updateMember;

  PreJoinPageOptions({
    this.imgSrc = 'https://mediasfu.com/images/logo192.png',
    required this.showAlert,
    required this.updateIsLoadingModalVisible,
    required this.connectSocket,
    required this.updateSocket,
    required this.updateValidated,
    required this.updateApiUserName,
    required this.updateApiToken,
    required this.updateLink,
    required this.updateRoomName,
    required this.updateMember,
  });
}

class Credentials {
  final String apiUserName;
  final String apiKey;

  Credentials({required this.apiUserName, required this.apiKey});
}

typedef PreJoinPageType = Widget Function({
  PreJoinPageOptions? options,
  required Credentials credentials,
});

/// `PreJoinPage` is a StatefulWidget that allows users to either join an existing room
/// or create a new room. It provides validation, error handling, and alerts for user interactions.
///
/// ### Parameters:
/// - `PreJoinPageOptions` `options`: Contains functions and configurations such as alert displays,
///   socket connections, and loading state updates.
/// - `Credentials` `credentials`: Holds the `apiUserName` and `apiKey` for room creation and joining.
/// - `PreJoinPageType?` `customBuilder`: *(Optional)* A custom widget builder that overrides the default UI.
///
/// ### Example Usage:
///
/// #### Using the Default `PreJoinPage`:
/// ```dart
/// PreJoinPage(
///   options: PreJoinPageOptions(
///     showAlert: (message, type, duration) => print('Alert: $message'),
///     updateIsLoadingModalVisible: (isVisible) => print('Loading: $isVisible'),
///     connectSocket: myConnectSocketFunction,
///     updateSocket: (socket) => print('Socket Updated'),
///     updateValidated: (isValid) => print('Validated: $isValid'),
///     updateApiUserName: (userName) => print('API UserName: $userName'),
///     updateApiToken: (token) => print('API Token: $token'),
///     updateLink: (link) => print('Link: $link'),
///     updateRoomName: (roomName) => print('Room Name: $roomName'),
///     updateMember: (member) => print('Member: $member'),
///   ),
///   credentials: Credentials(
///     apiUserName: 'exampleUser',
///     apiKey: 'exampleKey',
///   ),
/// );
/// ```
///
/// #### Using a Custom `PreJoinPage`:
/// ```dart
/// // Define a custom PreJoinPage widget
/// Widget myCustomPreJoinPage({
///   required PreJoinPageOptions options,
///   required Credentials credentials,
/// }) {
///   return Scaffold(
///     appBar: AppBar(title: const Text('Custom PreJoin Page')),
///     body: Center(
///       child: Text(
///         'Welcome, ${credentials.apiUserName}!',
///         style: const TextStyle(fontSize: 24),
///       ),
///     ),
///   );
/// }
///
/// // Usage with Custom Builder
/// PreJoinPage(
///   options: PreJoinPageOptions(
///     showAlert: (message, type, duration) => print('Alert: $message'),
///     updateIsLoadingModalVisible: (isVisible) => print('Loading: $isVisible'),
///     connectSocket: myConnectSocketFunction,
///     updateSocket: (socket) => print('Socket Updated'),
///     updateValidated: (isValid) => print('Validated: $isValid'),
///     updateApiUserName: (userName) => print('API UserName: $userName'),
///     updateApiToken: (token) => print('API Token: $token'),
///     updateLink: (link) => print('Link: $link'),
///     updateRoomName: (roomName) => print('Room Name: $roomName'),
///     updateMember: (member) => print('Member: $member'),
///   ),
///   credentials: Credentials(
///     apiUserName: 'exampleUser',
///     apiKey: 'exampleKey',
///   ),
///   customBuilder: myCustomPreJoinPage, // Pass the custom builder
/// );
/// ```
///
/// ### Key Methods:
/// - `_handleCreateRoom()`: Validates inputs and sends a request to create a room. If successful,
///   it calls `_checkLimitsAndMakeRequest` to handle socket connection setup.
/// - `_handleJoinRoom()`: Similar to `_handleCreateRoom`, but for joining an existing room based on `eventID`.
/// - `_checkLimitsAndMakeRequest(...)`: Checks for rate limits and, if passed, establishes a socket connection.
/// - `_toggleMode()`: Switches between "Create" and "Join" modes.
///
/// ### UI Elements:
/// - `_buildInputFields()`: Generates input fields based on the current mode.
/// - `_buildActionButton()`: Displays either a "Create Room" or "Join Room" button based on the mode.
/// - `_buildToggleButton()`: Button to switch between "Create" and "Join" modes.
class PreJoinPage extends StatefulWidget {
  final PreJoinPageOptions? options;
  final Credentials credentials;
  final PreJoinPageType? customBuilder;

  const PreJoinPage(
      {super.key, this.options, required this.credentials, this.customBuilder});

  @override
  _PreJoinPageState createState() => _PreJoinPageState();
}

class _PreJoinPageState extends State<PreJoinPage> {
  bool _isCreateMode = false;
  String _name = '';
  String _duration = '';
  String _eventType = '';
  String _capacity = '';
  String _eventID = '';
  String _error = '';

  final int maxAttempts = 10;
  final int rateLimitDuration = 3 * 60 * 60 * 1000; // 3 hours

  Future<void> _checkLimitsAndMakeRequest({
    required String apiUserName,
    String apiToken = '',
    required String link,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int unsuccessfulAttempts = prefs.getInt('unsuccessfulAttempts') ?? 0;
    int lastRequestTimestamp = prefs.getInt('lastRequestTimestamp') ?? 0;

    if (unsuccessfulAttempts >= maxAttempts &&
        DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
            rateLimitDuration) {
      widget.options!.showAlert!(
        message: 'Too many unsuccessful attempts. Please try again later.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    try {
      widget.options!.updateIsLoadingModalVisible(true);
      final socketWithTimeout = await widget.options!
          .connectSocket(
        ConnectSocketOptions(
          apiUserName: apiUserName,
          apiKey:
              "", // connectSocket does not require an API key if the API token is provided with the room name as the apiusername
          apiToken: apiToken,
          link: link,
        ),
      )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('Socket connection timed out');
      });

      if (socketWithTimeout.id!.isNotEmpty) {
        prefs.setInt('unsuccessfulAttempts', 0);
        prefs.setInt(
            'lastRequestTimestamp', DateTime.now().millisecondsSinceEpoch);

        widget.options!.updateSocket(socketWithTimeout);
        widget.options!.updateApiUserName(apiUserName);
        widget.options!.updateApiToken(apiToken);
        widget.options!.updateLink(link);
        widget.options!.updateRoomName(apiUserName);
        widget.options!.updateMember(userName);
        widget.options!.updateValidated(true);
      } else {
        prefs.setInt('unsuccessfulAttempts', ++unsuccessfulAttempts);
        widget.options!.showAlert!(
          message: 'Invalid credentials. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
      }
    } catch (error) {
      widget.options!.updateIsLoadingModalVisible(false);
      prefs.setInt('unsuccessfulAttempts', ++unsuccessfulAttempts);
      prefs.setInt(
          'lastRequestTimestamp', DateTime.now().millisecondsSinceEpoch);
      widget.options!.showAlert!(
        message: 'Unable to connect. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      widget.options!.updateIsLoadingModalVisible(false);
    }
  }

  Future<Map<String, dynamic>> createRoomOnMediaSFU(
      Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse('https://mediasfu.com/v1/rooms/');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${widget.credentials.apiUserName}:${widget.credentials.apiKey}',
      };

      final response =
          await http.post(url, headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'data': jsonDecode(response.body), 'success': true};
      } else {
        return {'data': jsonDecode(response.body), 'success': false};
      }
    } catch (error) {
      return {'data': null, 'success': false};
    }
  }

  Future<Map<String, dynamic>> joinRoomOnMediaSFU(
      Map<String, dynamic> payload) async {
    return await createRoomOnMediaSFU(payload);
  }

  void _handleCreateRoom() async {
    try {
      setState(() {
        _error = ''; // Clear any previous error message
      });
      if (_name.isEmpty ||
          _duration.isEmpty ||
          _eventType.isEmpty ||
          _capacity.isEmpty) {
        setState(() => _error = 'Please fill all the fields.');
        return;
      }

      if (!['broadcast', 'chat', 'webinar', 'conference']
          .contains(_eventType.toLowerCase())) {
        setState(() {
          _error =
              'Invalid event type. Please use one of: broadcast, chat, webinar, conference';
        });
        return;
      }

      // Validate capacity; must be a positive integer
      if (int.tryParse(_capacity) == null || int.parse(_capacity) <= 0) {
        setState(() {
          _error = 'Invalid room capacity. Please use a positive integer.';
        });
        return;
      }

      // Validate duration; must be a positive integer
      if (int.tryParse(_duration) == null || int.parse(_duration) <= 0) {
        setState(() {
          _error = 'Invalid room duration. Please use a positive integer.';
        });
        return;
      }

      // Validate name; must not be empty and be alphanumeric of 2 to 10 characters
      if (_name.isEmpty || _name.length < 2 || _name.length > 10) {
        setState(() {
          _error =
              'Invalid name. Please use an alphanumeric name of 2 to 10 characters.';
        });
        return;
      }

      // Call API to create room
      final payload = {
        'action': 'create',
        'duration': int.parse(_duration),
        'capacity': int.parse(_capacity),
        'eventType': _eventType.toLowerCase(),
        'userName': _name,
      };

      widget.options!.updateIsLoadingModalVisible(true);
      final response = await createRoomOnMediaSFU(payload);

      if (response['success']) {
        final data = response['data'];
        await _checkLimitsAndMakeRequest(
          apiUserName: data['roomName'],
          apiToken: data['secret'],
          link: data['link'],
          userName: _name,
        );
      } else {
        widget.options!.updateIsLoadingModalVisible(false);
        setState(() =>
            _error = 'Unable to create room. ${response['data']['error']}');
      }
    } catch (error) {
      widget.options!.showAlert!(
        message: 'Unable to create room. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  void _handleJoinRoom() async {
    try {
      setState(() {
        _error = ''; // Clear any previous error message
      });

      if (_name.isEmpty || _eventID.isEmpty) {
        setState(() => _error = 'Please fill all the fields.');
        return;
      }

      if (_name.isEmpty || _name.length < 2 || _name.length > 10) {
        setState(() {
          _error =
              'Invalid name. Please use an alphanumeric name of 2 to 10 characters.';
        });
        return;
      }

      final payload = {
        'action': 'join',
        'meetingID': _eventID,
        'userName': _name,
      };

      widget.options!.updateIsLoadingModalVisible(true);
      final response = await joinRoomOnMediaSFU(payload);

      if (response['success']) {
        final data = response['data'];
        await _checkLimitsAndMakeRequest(
          apiUserName: data['roomName'],
          apiToken: data['secret'],
          link: data['link'],
          userName: _name,
        );
      } else {
        widget.options!.updateIsLoadingModalVisible(false);
        setState(() =>
            _error = 'Unable to connect to room. ${response['data']['error']}');
      }
    } catch (error) {
      widget.options!.showAlert!(
        message: 'Unable to connect to room. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isCreateMode = !_isCreateMode;
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // If a custom builder is provided, use it
    if (widget.customBuilder != null) {
      return widget.customBuilder!(
        options: widget.options,
        credentials: widget.credentials,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF53C6E0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.options!.imgSrc ??
                      'https://mediasfu.com/images/logo192.png'),
                ),
                const SizedBox(height: 10),
                _buildInputFields(),
                if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                _buildActionButton(),
                const SizedBox(height: 10),
                const Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField('Display Name', (value) => _name = value),
        if (_isCreateMode) ...[
          _buildTextField('Duration (minutes)', (value) => _duration = value),
          _buildTextField('Event Type', (value) => _eventType = value),
          _buildTextField('Room Capacity', (value) => _capacity = value),
        ],
        if (!_isCreateMode)
          _buildTextField('Event ID', (value) => _eventID = value),
      ],
    );
  }

  Widget _buildTextField(String hintText, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isCreateMode ? _handleCreateRoom : _handleJoinRoom,
      child: Text(_isCreateMode ? 'Create Room' : 'Join Room'),
    );
  }

  Widget _buildToggleButton() {
    return ElevatedButton(
      onPressed: _toggleMode,
      child:
          Text(_isCreateMode ? 'Switch to Join Mode' : 'Switch to Create Mode'),
    );
  }
}
