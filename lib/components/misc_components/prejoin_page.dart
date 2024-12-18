import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/create_room_on_media_sfu.dart'
    show createRoomOnMediaSFU;
import '../../methods/utils/check_limits_and_make_request.dart'
    show checkLimitsAndMakeRequest;
import '../../methods/utils/join_room_on_media_sfu.dart'
    show joinRoomOnMediaSFU;
import '../../types/types.dart'
    show
        ConnectLocalSocketOptions,
        ConnectLocalSocketType,
        ConnectSocketType,
        CreateJoinRoomError,
        CreateJoinRoomResponse,
        CreateMediaSFUOptions,
        CreateMediaSFURoomOptions,
        CreateRoomOnMediaSFUType,
        EventType,
        JoinMediaSFUOptions,
        JoinMediaSFURoomOptions,
        JoinRoomOnMediaSFUType,
        MeetingRoomParams,
        RecordingParams,
        ResponseLocalConnection,
        ResponseLocalConnectionData,
        ShowAlert;

class JoinLocalEventRoomParameters {
  final String eventID;
  final String userName;
  final String? secureCode;
  final String? videoPreference;
  final String? audioPreference;
  final String? audioOutputPreference;

  JoinLocalEventRoomParameters({
    required this.eventID,
    required this.userName,
    this.secureCode,
    this.videoPreference,
    this.audioPreference,
    this.audioOutputPreference,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'userName': userName,
      'secureCode': secureCode,
      'videoPreference': videoPreference,
      'audioPreference': audioPreference,
      'audioOutputPreference': audioOutputPreference,
    };
  }

  // Create from JSON
  factory JoinLocalEventRoomParameters.fromJson(Map<String, dynamic> json) {
    return JoinLocalEventRoomParameters(
      eventID: json['eventID'],
      userName: json['userName'],
      secureCode: json['secureCode'],
      videoPreference: json['videoPreference'],
      audioPreference: json['audioPreference'],
      audioOutputPreference: json['audioOutputPreference'],
    );
  }
}

class JoinLocalEventRoomOptions {
  final JoinLocalEventRoomParameters joinData;
  final String? link;

  JoinLocalEventRoomOptions({
    required this.joinData,
    this.link,
  });
}

class CreateLocalRoomParameters {
  String eventID;
  int duration;
  int capacity;
  String userName;
  DateTime scheduledDate;
  String secureCode;
  bool? waitRoom;
  RecordingParams? recordingParams;
  MeetingRoomParams? eventRoomParams;
  String? videoPreference;
  String? audioPreference;
  String? audioOutputPreference;
  String? mediasfuURL;

  CreateLocalRoomParameters({
    required this.eventID,
    required this.duration,
    required this.capacity,
    required this.userName,
    required this.scheduledDate,
    required this.secureCode,
    this.waitRoom,
    this.recordingParams,
    this.eventRoomParams,
    this.videoPreference,
    this.audioPreference,
    this.audioOutputPreference,
    this.mediasfuURL,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'duration': duration,
      'capacity': capacity,
      'userName': userName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'secureCode': secureCode,
      'waitRoom': waitRoom,
      'recordingParams': recordingParams?.toMap(),
      'eventRoomParams': eventRoomParams?.toMap(),
      'videoPreference': videoPreference,
      'audioPreference': audioPreference,
      'audioOutputPreference': audioOutputPreference,
      'mediasfuURL': mediasfuURL,
    };
  }

  // Create from JSON
  factory CreateLocalRoomParameters.fromJson(Map<String, dynamic> json) {
    return CreateLocalRoomParameters(
      eventID: json['eventID'],
      duration: json['duration'],
      capacity: json['capacity'],
      userName: json['userName'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      secureCode: json['secureCode'],
      waitRoom: json['waitRoom'],
      recordingParams: json['recordingParams'] != null
          ? RecordingParams.fromJson(json['recordingParams'])
          : null,
      eventRoomParams: json['eventRoomParams'] != null
          ? MeetingRoomParams.fromJson(json['eventRoomParams'])
          : null,
      videoPreference: json['videoPreference'],
      audioPreference: json['audioPreference'],
      audioOutputPreference: json['audioOutputPreference'],
      mediasfuURL: json['mediasfuURL'],
    );
  }
}

class CreateLocalRoomOptions {
  final CreateLocalRoomParameters createData;
  final String? link;

  CreateLocalRoomOptions({
    required this.createData,
    this.link,
  });
}

class CreateJoinLocalRoomResponse {
  final bool success;
  final String secret;
  final String? reason;
  final String? url;

  CreateJoinLocalRoomResponse({
    required this.success,
    required this.secret,
    this.reason,
    this.url,
  });
}

class PreJoinPageParameters {
  String? imgSrc;
  ShowAlert? showAlert;
  Function(bool) updateIsLoadingModalVisible;
  ConnectSocketType connectSocket;
  ConnectLocalSocketType?
      connectLocalSocket; // New function for local socket connection
  Function(io.Socket?) updateSocket;
  Function(io.Socket?)?
      updateLocalSocket; // New function to update local socket
  Function(bool) updateValidated;
  Function(String) updateApiUserName;
  Function(String) updateApiToken;
  Function(String) updateLink;
  Function(String) updateRoomName;
  Function(String) updateMember;

  PreJoinPageParameters({
    this.imgSrc,
    this.showAlert,
    required this.updateIsLoadingModalVisible,
    required this.connectSocket,
    this.connectLocalSocket,
    required this.updateSocket,
    this.updateLocalSocket,
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

class PreJoinPageOptions {
  final String? localLink;
  final bool connectMediaSFU;
  final PreJoinPageParameters parameters;
  final Credentials credentials;
  final PreJoinPageType? customBuilder;
  bool? returnUI;
  CreateMediaSFURoomOptions? noUIPreJoinOptionsCreate;
  JoinMediaSFURoomOptions? noUIPreJoinOptionsJoin;
  CreateRoomOnMediaSFUType? createMediaSFURoom;
  JoinRoomOnMediaSFUType? joinMediaSFURoom;

  PreJoinPageOptions({
    this.localLink,
    this.connectMediaSFU = true,
    required this.parameters,
    required this.credentials,
    this.customBuilder,
    this.returnUI = true,
    this.noUIPreJoinOptionsCreate,
    this.noUIPreJoinOptionsJoin,
    this.createMediaSFURoom = createRoomOnMediaSFU,
    this.joinMediaSFURoom = joinRoomOnMediaSFU,
  });
}

typedef PreJoinPageType = Widget Function({
  PreJoinPageOptions? options,
});

/// **PreJoinPage**
///
/// A StatefulWidget that allows users to either join an existing room or create a new one.
/// It provides validation, error handling, and alerts for user interactions.
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
///     parameters: PreJoinPageParameters(
///     showAlert: (message, type, duration) => print('Alert: $message'),
///     updateIsLoadingModalVisible: (isVisible) => print('Loading: $isVisible'),
///     connectSocket: myConnectSocketFunction,
///     connectLocalSocket: myConnectLocalSocketFunction,
///     updateSocket: (socket) => print('Socket Updated'),
///     updateLocalSocket: (socket) => print('Local Socket Updated'),
///     updateValidated: (isValid) => print('Validated: $isValid'),
///     updateApiUserName: (userName) => print('API UserName: $userName'),
///     updateApiToken: (token) => print('API Token: $token'),
///     updateLink: (link) => print('Link: $link'),
///     updateRoomName: (roomName) => print('Room Name: $roomName'),
///     updateMember: (member) => print('Member: $member'),
///    ),
///   credentials: Credentials(
///     apiUserName: 'exampleUser',
///     apiKey: 'exampleKey',
///   ),
///   localLink: 'http://localhost:3000', // Optional local link for Community Edition
///   connectMediaSFU: true, // Connect to MediaSFU
///   customBuilder: null, // Use the default builder
///   returnUI: true, // Return the UI
///   noUIPreJoinOptionsCreate: null, // No UI PreJoin Options for Create
///   noUIPreJoinOptionsJoin: null, // No UI PreJoin Options for Join
///   createMediaSFURoom: createRoomOnMediaSFU, // Create MediaSFU Room
///  joinMediaSFURoom: joinRoomOnMediaSFU, // Join MediaSFU Room
///  ),
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
///     parameters: PreJoinPageParameters(
///     showAlert: (message, type, duration) => print('Alert: $message'),
///     updateIsLoadingModalVisible: (isVisible) => print('Loading: $isVisible'),
///     connectSocket: myConnectSocketFunction,
///     connectLocalSocket: myConnectLocalSocketFunction,
///     updateSocket: (socket) => print('Socket Updated'),
///     updateLocalSocket: (socket) => print('Local Socket Updated'),
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
///   localLink: 'http://localhost:3000', // Optional local link for Community Edition
///   connectMediaSFU: true, // Connect to MediaSFU
///   customBuilder: myCustomPreJoinPage, // Pass the custom builder
///   returnUI: true, // Return the UI
///   noUIPreJoinOptionsCreate: null, // No UI PreJoin Options for Create
///   noUIPreJoinOptionsJoin: null, // No UI PreJoin Options for Join
///   createMediaSFURoom: createRoomOnMediaSFU, // Create MediaSFU Room
///  joinMediaSFURoom: joinRoomOnMediaSFU, // Join MediaSFU Room
/// );
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
  final PreJoinPageOptions options;

  const PreJoinPage({
    super.key,
    required this.options,
  });

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

  // New variables for local connection handling
  bool localConnected = false;
  ResponseLocalConnectionData? localData;
  io.Socket? initSocket;

  bool pending = false;

  @override
  void initState() {
    super.initState();
    // Attempt local connection if localLink is provided
    if (widget.options.localLink != null &&
        widget.options.localLink!.isNotEmpty &&
        !localConnected &&
        initSocket == null) {
      _connectToLocalSocket().then((_) {
        if (widget.options.noUIPreJoinOptionsCreate != null ||
            widget.options.noUIPreJoinOptionsJoin != null) {
          checkProceed();
        }
      });
    } else {
      if (widget.options.noUIPreJoinOptionsCreate != null ||
          widget.options.noUIPreJoinOptionsJoin != null) {
        checkProceed();
      }
    }
  }

  /// Checks and proceeds with room creation or joining without a UI.
  ///
  /// Throws an exception if required parameters are missing or invalid.
  Future<void> checkProceed() async {
    try {
      // If no UI is needed and options are provided, proceed
      if (!widget.options.returnUI! &&
          (widget.options.noUIPreJoinOptionsCreate != null ||
              widget.options.noUIPreJoinOptionsJoin != null)) {
        if (widget.options.noUIPreJoinOptionsCreate
                is CreateMediaSFURoomOptions &&
            widget.options.noUIPreJoinOptionsCreate?.action == 'create') {
          await _handleCreateRoom();
        } else if (widget.options.noUIPreJoinOptionsJoin
                is JoinMediaSFURoomOptions &&
            widget.options.noUIPreJoinOptionsJoin?.action == 'join') {
          await _handleJoinRoom();
        } else {
          throw Exception(
              'Invalid options provided for creating/joining a room without UI.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  /// **_connectToLocalSocket**
  ///
  /// Connects to the local socket server using the provided localLink.
  /// It sends a request to connect to the local socket and handles the response.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _connectToLocalSocket() async {
    try {
      ResponseLocalConnection? response =
          await widget.options.parameters.connectLocalSocket?.call(
        ConnectLocalSocketOptions(
          link: widget.options.localLink!,
        ),
      );

      if (response != null) {
        localData = response.data;
        initSocket = response.socket;
        localConnected = true;
        widget.options.parameters.updateSocket(initSocket);
      }
    } catch (error) {
      widget.options.parameters.showAlert?.call(
        message: 'Unable to connect to ${widget.options.localLink}. $error',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  /// **_handleCreateRoom**
  ///
  /// Handles creating a new room.
  /// It validates the input fields and sends a request to create the room.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _handleCreateRoom() async {
    if (pending) return;
    pending = true;

    setState(() {
      _error = ''; // Clear previous errors
    });

    if (widget.options.returnUI!) {
      // Input Validation
      if (_name.isEmpty ||
          _duration.isEmpty ||
          _eventType.isEmpty ||
          _capacity.isEmpty) {
        setState(() => _error = 'Please fill all the fields.');
        pending = false;
        return;
      }

      if (!['chat', 'broadcast', 'webinar', 'conference']
          .contains(_eventType.toLowerCase())) {
        setState(() {
          _error =
              'Invalid event type. Please select from Chat, Broadcast, Webinar, or Conference.';
        });
        pending = false;
        return;
      }

      final int? capacityInt = int.tryParse(_capacity);
      final int? durationInt = int.tryParse(_duration);

      if (capacityInt == null || capacityInt <= 0) {
        setState(() {
          _error = 'Room capacity must be a positive integer.';
        });
        pending = false;
        return;
      }

      if (durationInt == null || durationInt <= 0) {
        setState(() {
          _error = 'Duration must be a positive integer.';
        });
        pending = false;
        return;
      }

      if (_name.length < 2 || _name.length > 10) {
        setState(() {
          _error = 'Display Name must be between 2 and 10 characters.';
        });
        pending = false;
        return;
      }
    } else {
      pending = false;
      if (widget.options.noUIPreJoinOptionsCreate == null) {
        throw Exception('No UI PreJoin Options are missing.');
      }
    }

    widget.options.parameters.updateIsLoadingModalVisible(true);

    if (widget.options.localLink != null &&
        widget.options.localLink!.isNotEmpty) {
      // Handle local room creation
      await _createLocalRoom();
    } else {
      // Handle remote (MediaSFU) room creation
      await _createRemoteRoom();
    }
  }

  /// Generates a random alphanumeric string of the given length.
  String _randomString(int length, Random random) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
        length, (_) => characters[random.nextInt(characters.length)]).join();
  }

  /// Generates a secure code by concatenating two random alphanumeric strings.
  String _generateSecureCode() {
    final random = Random();
    return _randomString(12, random) + _randomString(12, random);
  }

  /// Generates an event ID based on the current timestamp, UTC milliseconds, and random digits.
  String _generateEventID() {
    final now = DateTime.now();
    final random = Random();

    final timePart = now.millisecondsSinceEpoch.toRadixString(30);
    final utcMilliseconds = now.microsecond.toString();
    final randomDigits = (10 + random.nextInt(90)).toString();

    return 'm$timePart$utcMilliseconds$randomDigits';
  }

  /// **_createLocalRoom**
  ///
  /// Creates a new room on the local server using the provided inputs.
  /// It emits a 'createRoom' event to the local socket and handles the response.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _createLocalRoom() async {
    // Generate secureCode and eventID
    final secureCode = _generateSecureCode();
    final eventID = _generateEventID();

    // Prepare eventRoomParams and recordingParams if available
    MeetingRoomParams? eventRoomParams = localData?.eventRoomParams;
    eventRoomParams!.type = _eventType.toLowerCase();

    int? durationInt = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.duration
        : int.tryParse(_duration);
    int? capacityInt = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.capacity
        : int.tryParse(_capacity);
    String? name = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.userName
        : _name;
    EventType? eventType = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.eventType
        : _eventType == 'chat'
            ? EventType.chat
            : _eventType == 'broadcast'
                ? EventType.broadcast
                : _eventType == 'webinar'
                    ? EventType.webinar
                    : EventType.conference;

    final createData = CreateLocalRoomParameters(
      eventID: eventID,
      duration: durationInt ?? 0,
      capacity: capacityInt ?? 0,
      userName: name,
      scheduledDate: DateTime.now(),
      secureCode: secureCode,
      waitRoom: false,
      recordingParams: localData?.recordingParams,
      eventRoomParams: eventRoomParams,
      videoPreference: null,
      audioPreference: null,
      audioOutputPreference: null,
      mediasfuURL: '',
    );

    if (widget.options.connectMediaSFU &&
        initSocket != null &&
        localData != null &&
        localData!.apiUserName != null &&
        localData!.apiUserName!.isNotEmpty &&
        localData!.apiKey != null &&
        localData!.apiKey!.isNotEmpty) {
      // Prepare payload for MediaSFU

      final payloadMap = {
        'action': 'create',
        'duration': durationInt,
        'capacity': capacityInt,
        'eventType': eventType.toString().split('.').last.toLowerCase(),
        'userName': name,
        'recordOnly': true, // Allow production to mediasfu only; no consumption
      };

      CreateMediaSFURoomOptions? payload = !widget.options.returnUI! &&
              widget.options.noUIPreJoinOptionsCreate != null
          ? widget.options.noUIPreJoinOptionsCreate!
          : CreateMediaSFURoomOptions.fromMap(payloadMap);
      // Create room on MediaSFU
      final response = await createRoomOnMediaSFU(
        CreateMediaSFUOptions(
          payload: payload,
          apiUserName: localData!.apiUserName!,
          apiKey: localData!.apiKey!,
          localLink: widget.options.localLink ?? '',
        ),
      );

      if (response.success && response.data is CreateJoinRoomResponse) {
        await checkLimitsAndMakeRequest(
          apiUserName: response.data.roomName,
          apiToken: response.data.secret,
          link: response.data.link,
          userName: createData.userName,
          parameters: widget.options.parameters,
          validate: false,
        );
        final data = response.data;
        // Update createData with MediaSFU details
        createData.eventID = data.roomName;
        createData.secureCode = data.secureCode;
        createData.mediasfuURL = data.publicURL;

        // Proceed to create local room
        await _createRoomOnLocalServer(
          createData: createData,
          link: data.link,
        );
      } else {
        pending = false;
        widget.options.parameters.updateIsLoadingModalVisible(false);
        setState(() {
          _error = 'Unable to create room on MediaSFU.';
        });
      }
    } else {
      // Create room locally without MediaSFU connection
      await _createRoomOnLocalServer(createData: createData);
      pending = false;
    }
  }

  /// **_createRoomOnLocalServer**
  ///
  /// Creates a new room on the local server using the provided inputs.
  /// It emits a 'createRoom' event to the local socket and handles the response.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _createRoomOnLocalServer({
    required CreateLocalRoomParameters createData,
    String? link,
  }) async {
    final createDataMap = createData.toJson();
    initSocket?.emitWithAck(
      'createRoom',
      createDataMap,
      ack: (response) {
        final res = CreateJoinLocalRoomResponse(
          success: response['success'],
          secret: response['secret'],
          reason: response['reason'],
          url: response['url'],
        );

        if (res.success) {
          widget.options.parameters.updateSocket(initSocket);
          widget.options.parameters
              .updateApiUserName(localData?.apiUserName ?? '');
          widget.options.parameters.updateApiToken(res.secret);
          widget.options.parameters
              .updateLink(link ?? widget.options.localLink!);
          widget.options.parameters.updateRoomName(createData.eventID);
          widget.options.parameters.updateMember('${createData.userName}_2');
          widget.options.parameters.updateIsLoadingModalVisible(false);
          widget.options.parameters.updateValidated(true);
        } else {
          widget.options.parameters.updateIsLoadingModalVisible(false);
          setState(() {
            _error = 'Unable to create room. ${res.reason}';
          });
        }
      },
    );
  }

  /// **_createRemoteRoom**
  ///
  /// Creates a new room on MediaSFU using the provided inputs.
  /// It sends a request to create the room and handles the response.
  /// If successful, it calls `_checkLimitsAndMakeRequest` to handle socket connection setup.
  /// Otherwise, it displays an error message.

  Future<void> _createRemoteRoom() async {
    // Prepare payload

    int? durationInt = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.duration
        : int.tryParse(_duration);
    int? capacityInt = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.capacity
        : int.tryParse(_capacity);
    String? name = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.userName
        : _name;
    EventType? eventType = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!.eventType
        : _eventType == 'chat'
            ? EventType.chat
            : _eventType == 'broadcast'
                ? EventType.broadcast
                : _eventType == 'webinar'
                    ? EventType.webinar
                    : EventType.conference;

    final payloadMap = {
      'action': 'create',
      'duration': durationInt,
      'capacity': capacityInt,
      'eventType': eventType.toString().split('.').last.toLowerCase(),
      'userName': name,
    };

    final payload = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsCreate != null
        ? widget.options.noUIPreJoinOptionsCreate!
        : CreateMediaSFURoomOptions.fromMap(payloadMap);

    try {
      final response = await createRoomOnMediaSFU(
        CreateMediaSFUOptions(
          payload: payload,
          apiUserName: widget.options.credentials.apiUserName,
          apiKey: widget.options.credentials.apiKey,
          localLink: widget.options.localLink ?? '',
        ),
      );

      if (response.success && response.data is CreateJoinRoomResponse) {
        final data = response.data;

        // Handle rate limiting and socket connection
        await checkLimitsAndMakeRequest(
          apiUserName: data.roomName,
          apiToken: data.secret,
          link: data.link,
          userName: name,
          parameters: widget.options.parameters,
        );
      } else if (response.success == false &&
          response.data is CreateJoinRoomError) {
        final errorData = response.data;
        pending = false;
        setState(() {
          _error = 'Unable to create room. ${errorData.error}';
        });
      } else {
        pending = false;
        setState(() {
          _error = 'Unexpected error occurred.';
        });
      }
    } catch (error) {
      pending = false;
      widget.options.parameters.showAlert?.call(
        message: 'Unable to create room. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      pending = false;
      widget.options.parameters.updateIsLoadingModalVisible(false);
    }
  }

  /// **_toggleMode**
  /// Toggles between Create and Join modes.

  void _toggleMode() {
    setState(() {
      _isCreateMode = !_isCreateMode;
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // If no UI is needed, return an empty container
    if (!widget.options.returnUI!) {
      return const SizedBox();
    }

    // If a custom builder is provided, use it
    if (widget.options.customBuilder != null) {
      return widget.options.customBuilder!(
        options: widget.options,
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
                  backgroundImage: NetworkImage(
                      widget.options.parameters.imgSrc ??
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

  /// **_buildInputFields**
  ///
  /// Generates input fields based on the current mode (Create or Join).
  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(
          hintText: 'Display Name',
          onChanged: (value) => _name = value,
        ),
        if (_isCreateMode) ...[
          _buildTextField(
            hintText: 'Duration (minutes)',
            onChanged: (value) => _duration = value,
            keyboardType: TextInputType.number,
          ),
          _buildDropdownField(),
          _buildTextField(
            hintText: 'Room Capacity',
            onChanged: (value) => _capacity = value,
            keyboardType: TextInputType.number,
          ),
        ],
        if (!_isCreateMode)
          _buildTextField(
            hintText: 'Event ID',
            onChanged: (value) => _eventID = value,
          ),
      ],
    );
  }

  /// **_buildTextField**
  ///
  /// Creates a styled text field.
  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        keyboardType: keyboardType,
      ),
    );
  }

  /// **_buildDropdownField**
  ///
  /// Creates a dropdown field for selecting the event type.
  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        value: _eventType.isEmpty ? null : _eventType,
        hint: const Text('Select Event Type'),
        items: const [
          DropdownMenuItem(value: 'chat', child: Text('Chat')),
          DropdownMenuItem(value: 'broadcast', child: Text('Broadcast')),
          DropdownMenuItem(value: 'webinar', child: Text('Webinar')),
          DropdownMenuItem(value: 'conference', child: Text('Conference')),
        ],
        onChanged: (value) {
          setState(() {
            _eventType = value ?? '';
          });
        },
      ),
    );
  }

  /// **_buildActionButton**
  ///
  /// Creates the main action button, which either creates or joins a room based on the current mode.
  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isCreateMode ? _handleCreateRoom : _handleJoinRoom,
      child: Text(_isCreateMode ? 'Create Room' : 'Join Room'),
    );
  }

  /// **_buildToggleButton**
  ///
  /// Creates a button to toggle between Create and Join modes.
  Widget _buildToggleButton() {
    return ElevatedButton(
      onPressed: _toggleMode,
      child: Text(
        _isCreateMode ? 'Switch to Join Mode' : 'Switch to Create Mode',
      ),
    );
  }

  /// **_handleJoinRoom**
  ///
  /// Handles joining an existing room.
  /// It validates the input fields and sends a request to join the room.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _handleJoinRoom() async {
    if (pending) return;
    pending = true;
    setState(() {
      _error = ''; // Clear previous errors
    });

    if (widget.options.returnUI!) {
      // Input Validation
      if (_name.isEmpty || _eventID.isEmpty) {
        setState(() => _error = 'Please fill all the fields.');
        pending = false;
        return;
      }

      if (_name.length < 2 || _name.length > 10) {
        setState(() {
          _error = 'Display Name must be between 2 and 10 characters.';
        });
        pending = false;
        return;
      }
    } else {
      if (widget.options.noUIPreJoinOptionsJoin == null) {
        pending = false;
        throw Exception('No UI PreJoin Options are missing.');
      }
    }

    widget.options.parameters.updateIsLoadingModalVisible(true);

    if (widget.options.localLink != null &&
        widget.options.localLink!.isNotEmpty &&
        !widget.options.localLink!.contains('mediasfu.com')) {
      // Handle local room joining
      await _joinLocalRoom();
      pending = false;
    } else {
      // Handle remote (MediaSFU) room joining
      await _joinRemoteRoom();
      pending = false;
    }
  }

  /// **_joinLocalRoom**
  ///
  /// Joins a local room using the provided eventID.
  /// This function is called when the localLink is provided and not empty.
  /// It emits a 'joinEventRoom' event to the local socket.
  /// If successful, it updates the socket and other parameters.
  /// Otherwise, it displays an error message.

  Future<void> _joinLocalRoom() async {
    String? name = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsJoin != null
        ? widget.options.noUIPreJoinOptionsJoin!.userName
        : _name;

    String? eventID = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsJoin != null
        ? widget.options.noUIPreJoinOptionsJoin!.meetingID
        : _eventID;

    final joinData = JoinLocalEventRoomParameters(
      eventID: eventID,
      userName: name,
      secureCode: '',
      videoPreference: null,
      audioPreference: null,
      audioOutputPreference: null,
    );

    initSocket?.emitWithAck(
      'joinEventRoom',
      joinData.toJson(),
      ack: (response) {
        final res = CreateJoinLocalRoomResponse(
          success: response['success'],
          secret: response['secret'],
          reason: response['reason'],
          url: response['url'],
        );

        if (res.success) {
          widget.options.parameters.updateSocket(initSocket);
          widget.options.parameters
              .updateApiUserName(localData?.apiUserName ?? '');
          widget.options.parameters.updateApiToken(res.secret);
          widget.options.parameters.updateLink(widget.options.localLink!);
          widget.options.parameters.updateRoomName(eventID);
          widget.options.parameters.updateMember(name);
          widget.options.parameters.updateIsLoadingModalVisible(false);
          widget.options.parameters.updateValidated(true);
        } else {
          widget.options.parameters.updateIsLoadingModalVisible(false);
          setState(() {
            _error = 'Unable to join room. ${res.reason}';
          });
        }
      },
    );
  }

  /// **_joinRemoteRoom**
  ///
  /// Joins a remote room using the provided eventID.
  /// This function is called when the localLink is not provided or empty.
  /// It sends a request to join the room on MediaSFU.
  /// If successful, it calls `_checkLimitsAndMakeRequest` to handle socket connection setup.
  /// Otherwise, it displays an error message.

  Future<void> _joinRemoteRoom() async {
    // Prepare payload

    String? name = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsJoin != null
        ? widget.options.noUIPreJoinOptionsJoin!.userName
        : _name;

    final payloadMap = {
      'action': 'join',
      'meetingID': _eventID,
      'userName': _name,
    };

    final payload = !widget.options.returnUI! &&
            widget.options.noUIPreJoinOptionsJoin != null
        ? widget.options.noUIPreJoinOptionsJoin!
        : JoinMediaSFURoomOptions.fromMap(payloadMap);

    try {
      final response = await joinRoomOnMediaSFU(
        JoinMediaSFUOptions(
          payload: payload,
          apiUserName: widget.options.credentials.apiUserName,
          apiKey: widget.options.credentials.apiKey,
          localLink: widget.options.localLink ?? '',
        ),
      );

      if (response.success && response.data is CreateJoinRoomResponse) {
        final data = response.data;

        // Handle rate limiting and socket connection
        await checkLimitsAndMakeRequest(
          apiUserName: data.roomName,
          apiToken: data.secret,
          link: data.link,
          userName: name,
          parameters: widget.options.parameters,
        );
      } else if (response.success == false &&
          response.data is CreateJoinRoomError) {
        final errorData = response.data;
        setState(() {
          _error = 'Unable to join room. ${errorData.error}';
        });
      } else {
        setState(() {
          _error = 'Unexpected error occurred.';
        });
      }
    } catch (error) {
      widget.options.parameters.showAlert?.call(
        message: 'Unable to join room. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      widget.options.parameters.updateIsLoadingModalVisible(false);
    }
  }
}
