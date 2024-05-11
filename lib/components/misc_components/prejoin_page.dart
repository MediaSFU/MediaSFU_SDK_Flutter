import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// This file contains the implementation of the [PreJoinPage] widget.
/// The [PreJoinPage] widget is responsible for handling the pre-join logic
/// before a user joins a room in the application.
/// It includes functions for checking rate limits, making API requests,
/// and creating/joining rooms on MediaSFU.
///
/// The [PreJoinPage] widget receives parameters such as [showAlert],
/// [updateIsLoadingModalVisible], [onWeb], [connectSocket], [socket],
/// [updateSocket], [updateValidated], [updateApiUserName], [updateApiToken],
/// [updateLink], [updateRoomName], [updateMember], and [validated].
/// These parameters are used for various purposes such as displaying alerts,
/// updating the loading modal visibility, connecting to a socket,
/// updating state variables, and validating user credentials.
///
/// The [PreJoinPage] widget is a stateful widget that maintains the state
/// of various variables such as [_isCreateMode], [_name], [_duration],
/// [_eventType], [_capacity], [_eventID], [_error], and [credentials].
/// These variables store information related to the pre-join page,
/// user input, and user credentials.
///
/// The [PreJoinPage] widget also includes functions such as [_checkLimitsAndMakeRequest],
/// [joinRoomOnMediaSFU], and [createRoomOnMediaSFU]. These functions are responsible
/// for checking rate limits, making API requests to join/create rooms on MediaSFU,
/// and handling the response data.
///
/// Overall, the [PreJoinPage] widget provides the necessary functionality
/// for the pre-join page in the application.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef ConnectSocket = Future<dynamic> Function(
    String apiUserName, String apiKey, String apiToken, String link);

int maxAttempts =
    20; // Maximum number of unsuccessful attempts before rate limiting
int rateLimitDuration = 3 * 60 * 60 * 1000; // 3 hours in milliseconds
String apiKey = 'yourAPIKEY';
String apiUserName = 'yourAPIUSERNAME';
Map<String, dynamic> userCredentials = {
  'apiUserName': apiUserName,
  'apiKey': apiKey
};

class PreJoinPage extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> credentials;

  const PreJoinPage(
      {super.key, required this.parameters, required this.credentials});

  @override
  // ignore: library_private_types_in_public_api
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

  Map<String, dynamic> credentials = userCredentials;

  late final ShowAlert showAlert;
  late final Function(bool) updateIsLoadingModalVisible;
  late bool onWeb;
  late final ConnectSocket connectSocket;
  late dynamic socket;
  late Function(dynamic) updateSocket;
  late Function(bool) updateValidated;
  late Function(String) updateApiUserName;
  late Function(String) updateApiToken;
  late Function(String) updateLink;
  late Function(String) updateRoomName;
  late Function(String) updateMember;
  late bool validated;

  @override
  void initState() {
    super.initState();
    // Extract showAlert and updateIsLoadingModalVisible from parameters
    showAlert = widget.parameters['showAlert'];
    updateIsLoadingModalVisible =
        widget.parameters['updateIsLoadingModalVisible'];
    onWeb = widget.parameters['onWeb'];
    connectSocket = widget.parameters['connectSocket'];
    socket = widget.parameters['socket'];
    updateSocket = widget.parameters['updateSocket'];
    updateValidated = widget.parameters['updateValidated'];
    updateApiUserName = widget.parameters['updateApiUserName'];
    updateApiToken = widget.parameters['updateApiToken'];
    updateLink = widget.parameters['updateLink'];
    updateRoomName = widget.parameters['updateRoomName'];
    updateMember = widget.parameters['updateMember'];
    validated = widget.parameters['validated'];
  }

  Future<void> _checkLimitsAndMakeRequest({
    required String apiUserName,
    String apiToken = "",
    String apiKey = "",
    required String link,
    required String userName,
  }) async {
    const int duration = 20000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unsuccessfulAttempts = prefs.getInt('unsuccessfulAttempts') ?? 0;
    int lastRequestTimestamp = prefs.getInt('lastRequestTimestamp') ?? 0;

    if (unsuccessfulAttempts >= maxAttempts) {
      if (DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
          rateLimitDuration) {
        showAlert(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        return;
      } else {
        unsuccessfulAttempts = 0;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    try {
      updateIsLoadingModalVisible(true);

      final socketPromise = connectSocket(apiUserName, apiKey, apiToken, link);
      const timeoutDuration = Duration(milliseconds: duration);

      final socketWithTimeout = await socketPromise.timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Socket connection timed out');
        },
      );

      if (socketWithTimeout != null && socketWithTimeout.id != null) {
        unsuccessfulAttempts = 0;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        // Update state or perform other actions on successful request
        await updateSocket(socketWithTimeout);
        await updateApiUserName(apiUserName);
        await updateApiToken(apiToken);
        await updateLink(link);
        await updateRoomName(apiUserName);
        await updateMember(userName);
        updateIsLoadingModalVisible(false);
        await updateValidated(true);
      } else {
        updateIsLoadingModalVisible(false);
        unsuccessfulAttempts++;
        await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
        await prefs.setInt(
          'lastRequestTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        if (unsuccessfulAttempts >= maxAttempts) {
          showAlert(
            message: 'Too many unsuccessful attempts. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        } else {
          showAlert(
            message: 'Invalid credentials. Please try again later.',
            type: 'danger',
            duration: 3000,
          );
        }
      }
    } catch (error) {
      updateIsLoadingModalVisible(false);

      await prefs.setInt('unsuccessfulAttempts', unsuccessfulAttempts);
      await prefs.setInt(
        'lastRequestTimestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (unsuccessfulAttempts >= maxAttempts) {
        showAlert(
          message: 'Too many unsuccessful attempts. Please try again later.',
          type: 'danger',
          duration: 3000,
        );
      } else {
        showAlert(
          message: 'Unable to connect. ${error.toString()}',
          type: 'danger',
          duration: 3000,
        );
      }
    }
  }

  Future<Map<String, dynamic>> joinRoomOnMediaSFU(
      Map<String, dynamic> payload, String apiUserName, String apiKey) async {
    try {
      if (apiUserName.isEmpty ||
          apiKey.isEmpty ||
          apiUserName.isEmpty ||
          apiKey.isEmpty) {
        return {'data': null, 'success': false};
      }

      if (apiUserName == 'yourAPIUSERNAME' || apiKey == 'yourAPIKEY') {
        return {'data': null, 'success': false};
      }

      if (apiKey.length != 64) {
        return {'data': null, 'success': false};
      }

      if (apiUserName.length < 6) {
        return {'data': null, 'success': false};
      }

      final url = Uri.parse('https://mediasfu.com/v1/rooms/');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiUserName:$apiKey',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);
      return {'data': responseData, 'success': true};
    } catch (error) {
      return {'data': null, 'success': false};
    }
  }

  Future<Map<String, dynamic>> createRoomOnMediaSFU(
      Map<String, dynamic> payload, String apiUserName, String apiKey) async {
    try {
      if (apiUserName.isEmpty || apiKey.isEmpty) {
        return {'data': null, 'success': false};
      }

      if (apiUserName == 'yourAPIUSERNAME' || apiKey == 'yourAPIKEY') {
        return {'data': null, 'success': false};
      }

      if (apiKey.length != 64) {
        return {'data': null, 'success': false};
      }

      if (apiUserName.length < 6) {
        return {'data': null, 'success': false};
      }

      final url = Uri.parse('https://mediasfu.com/v1/rooms/');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiUserName:$apiKey',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);
      return {'data': responseData, 'success': true};
    } catch (error) {
      return {'data': null, 'success': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF53C6E0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 300, // Max width for content area
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage('https://mediasfu.com/images/logo192.png'),
                ),
                const SizedBox(height: 10),
                _buildInputFields(),
                if (_error.isNotEmpty)
                  Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 10),
                _buildActionButton(),
                const SizedBox(height: 10),
                _buildOrText(),
                const SizedBox(height: 10),
                _buildToggleButton(),
                const SizedBox(height: 10),
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
        _buildTextField('Display Name', _name, (value) => _name = value),
        if (_isCreateMode) ...[
          _buildTextField(
              'Duration (minutes)', _duration, (value) => _duration = value),
          _buildTextField(
              'Event Type', _eventType, (value) => _eventType = value),
          _buildTextField(
              'Room Capacity', _capacity, (value) => _capacity = value),
        ],
        if (!_isCreateMode)
          _buildTextField('Event ID', _eventID, (value) => _eventID = value),
      ],
    );
  }

  Widget _buildTextField(
      String hintText, String value, Function(String) onChanged) {
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

  Widget _buildOrText() {
    return const Text(
      'OR',
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildToggleButton() {
    return ElevatedButton(
      onPressed: _toggleMode,
      child:
          Text(_isCreateMode ? 'Switch to Join Mode' : 'Switch to Create Mode'),
    );
  }

  void _toggleMode() {
    setState(() {
      _isCreateMode = !_isCreateMode;
      _error = ''; // Reset error message
    });
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
        setState(() {
          _error = 'Please fill all the fields.';
        });
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

      updateIsLoadingModalVisible(true);

      // Perform room creation logic
      final response = await createRoomOnMediaSFU(payload,
          widget.credentials['apiUserName'], widget.credentials['apiKey']);

      if (response['success']) {
        // Handle successful room creation
        await _checkLimitsAndMakeRequest(
            apiUserName: response['data']['roomName'],
            apiToken: response['data']['secret'],
            link: response['data']['link'],
            userName: _name);
        setState(() {
          _error = ''; // Clear any previous error message
        });
      } else {
        // Handle failed room creation
        updateIsLoadingModalVisible(false);
        setState(() {
          _error =
              'Unable to create room. ${response['data'] != null ? response['data']['message'] : ''}';
        });
      }
    } catch (error) {
      updateIsLoadingModalVisible(false);
      setState(() {
        _error = 'Unable to connect. ${error.toString()}';
      });
    }
  }

  void _handleJoinRoom() async {
    try {
      setState(() {
        _error = ''; // Clear any previous error message
      });

      if (_name.isEmpty || _eventID.isEmpty) {
        setState(() {
          _error = 'Please fill all the fields.';
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

      // Call API to join room
      final payload = {
        'action': 'join',
        'meetingID': _eventID,
        'userName': _name,
      };

      updateIsLoadingModalVisible(true);

      // Perform room join logic
      final response = await joinRoomOnMediaSFU(payload,
          widget.credentials['apiUserName'], widget.credentials['apiKey']);

      if (response['success']) {
        // Handle successful room join
        await _checkLimitsAndMakeRequest(
            apiUserName: response['data']['roomName'],
            apiToken: response['data']['secret'],
            link: response['data']['link'],
            userName: _name);
        setState(() {
          _error = ''; // Clear any previous error message
        });
      } else {
        updateIsLoadingModalVisible(false);
        // Handle failed room join
        setState(() {
          _error =
              'Unable to connect to room. ${response['data'] != null ? response['data']['message'] : ''}';
        });
      }
    } catch (error) {
      updateIsLoadingModalVisible(false);
      setState(() {
        _error = 'Unable to connect. ${error.toString()}';
      });
    }
  }
}
