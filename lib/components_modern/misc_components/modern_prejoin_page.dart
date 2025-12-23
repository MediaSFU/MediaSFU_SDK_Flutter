import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../components/misc_components/prejoin_page.dart'
    show
        CreateJoinLocalRoomResponse,
        CreateLocalRoomParameters,
        JoinLocalEventRoomParameters,
        PreJoinPageOptions;
import '../../methods/utils/check_limits_and_make_request.dart'
    show checkLimitsAndMakeRequest;
import '../../types/types.dart'
    show
        ConnectLocalSocketOptions,
        CreateJoinRoomError,
        CreateJoinRoomResponse,
        CreateMediaSFUOptions,
        CreateMediaSFURoomOptions,
        EventType,
        JoinMediaSFUOptions,
        JoinMediaSFURoomOptions,
        MeetingRoomParams,
        ResponseLocalConnection,
        ResponseLocalConnectionData;
import '../core/theme/mediasfu_borders.dart';
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_typography.dart';
import '../core/widgets/glassmorphic_container.dart';
import '../core/widgets/gradient_card.dart';

/// Modern redesigned PreJoinPage with identical business logic.
/// Only the UI layer is modernized; all callbacks and socket logic remain unchanged.
class ModernPreJoinPage extends StatefulWidget {
  final PreJoinPageOptions options;

  const ModernPreJoinPage({super.key, required this.options});

  @override
  State<ModernPreJoinPage> createState() => _ModernPreJoinPageState();
}

class _ModernPreJoinPageState extends State<ModernPreJoinPage>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE (copied verbatim from original)
  // ─────────────────────────────────────────────────────────────────────────
  bool _isCreateMode = false;
  String _name = '';
  String _duration = '';
  String _eventType = '';
  String _capacity = '';
  String _eventID = '';
  String _error = '';

  bool localConnected = false;
  ResponseLocalConnectionData? localData;
  io.Socket? initSocket;

  bool pending = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE (initState / dispose logic copied from original)
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUSINESS LOGIC (copied verbatim from original PreJoinPage)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> checkProceed() async {
    try {
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

  Future<void> _handleCreateRoom() async {
    if (pending) return;
    pending = true;
    if (mounted) {
      setState(() {
        _error = '';
      });
    }

    if (widget.options.returnUI!) {
      if (_name.isEmpty ||
          _duration.isEmpty ||
          _eventType.isEmpty ||
          _capacity.isEmpty) {
        if (mounted) {
          setState(() => _error = 'Please fill all the fields.');
        }
        pending = false;
        return;
      }

      if (!['chat', 'broadcast', 'webinar', 'conference']
          .contains(_eventType.toLowerCase())) {
        if (mounted) {
          setState(() {
            _error =
                'Invalid event type. Please select from Chat, Broadcast, Webinar, or Conference.';
          });
        }
        pending = false;
        return;
      }

      final int? capacityInt = int.tryParse(_capacity);
      final int? durationInt = int.tryParse(_duration);

      if (capacityInt == null || capacityInt <= 0) {
        if (mounted) {
          setState(() {
            _error = 'Room capacity must be a positive integer.';
          });
        }
        pending = false;
        return;
      }

      if (durationInt == null || durationInt <= 0) {
        if (mounted) {
          setState(() {
            _error = 'Duration must be a positive integer.';
          });
        }
        pending = false;
        return;
      }

      if (_name.length < 2 || _name.length > 10) {
        if (mounted) {
          setState(() {
            _error = 'Display Name must be between 2 and 10 characters.';
          });
        }
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
      await _createLocalRoom();
    } else {
      await _createRemoteRoom();
    }
  }

  String _randomString(int length, Random random) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
        length, (_) => characters[random.nextInt(characters.length)]).join();
  }

  String _generateSecureCode() {
    final random = Random();
    return _randomString(12, random) + _randomString(12, random);
  }

  String _generateEventID() {
    final now = DateTime.now();
    final random = Random();
    final timePart = now.millisecondsSinceEpoch.toRadixString(30);
    final utcMilliseconds = now.microsecond.toString();
    final randomDigits = (10 + random.nextInt(90)).toString();
    return 'm$timePart$utcMilliseconds$randomDigits';
  }

  Future<void> _createLocalRoom() async {
    final secureCode = _generateSecureCode();
    final eventID = _generateEventID();

    MeetingRoomParams? eventRoomParams = localData?.eventRoomParams;

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

    eventRoomParams!.type = eventType.toString().split('.').last.toLowerCase();

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
      final apiUserName = localData!.apiUserName!;
      final apiKey = localData!.apiKey!;

      final roomIdentifier = 'local_create_${name}_${durationInt}_$capacityInt';
      final pendingKey = 'prejoin_pending_$roomIdentifier';
      const pendingTimeout = 30 * 1000;

      try {
        final prefs = await SharedPreferences.getInstance();
        final pendingRequest = prefs.getString(pendingKey);
        if (pendingRequest != null) {
          final pendingData = jsonDecode(pendingRequest);
          final timeSincePending = DateTime.now().millisecondsSinceEpoch -
              ((pendingData['timestamp'] as num?)?.toInt() ?? 0);
          if (timeSincePending < pendingTimeout) {
            pending = false;
            widget.options.parameters.updateIsLoadingModalVisible(false);
            if (mounted) {
              setState(() {
                _error = 'Room creation already in progress';
              });
            }
            return;
          } else {
            await prefs.remove(pendingKey);
          }
        }
      } catch (e) {
        // Ignore
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          pendingKey,
          jsonEncode({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'payload': {
              'action': 'create',
              'userName': name,
              'duration': durationInt,
              'capacity': capacityInt,
            },
          }),
        );
        Future.delayed(const Duration(milliseconds: pendingTimeout), () async {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(pendingKey);
          } catch (e) {
            // Ignore
          }
        });
      } catch (e) {
        // Ignore
      }

      final payloadMap = {
        'action': 'create',
        'duration': durationInt,
        'capacity': capacityInt,
        'eventType': eventType.toString().split('.').last.toLowerCase(),
        'userName': name,
        'recordOnly': true,
      };

      CreateMediaSFURoomOptions? payload = !widget.options.returnUI! &&
              widget.options.noUIPreJoinOptionsCreate != null
          ? widget.options.noUIPreJoinOptionsCreate!
          : CreateMediaSFURoomOptions.fromMap(payloadMap);

      try {
        final response = await widget.options.createMediaSFURoom!(
          CreateMediaSFUOptions(
            payload: payload,
            apiUserName: apiUserName,
            apiKey: apiKey,
            localLink: widget.options.localLink ?? '',
          ),
        );

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(pendingKey);
        } catch (e) {
          // Ignore
        }

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
          createData.eventID = data.roomName;
          createData.secureCode = data.secureCode;
          createData.mediasfuURL = data.publicURL;

          await _createRoomOnLocalServer(
            createData: createData,
            link: data.link,
          );
        } else {
          pending = false;
          widget.options.parameters.updateIsLoadingModalVisible(false);
          if (mounted) {
            setState(() {
              _error = 'Unable to create room on MediaSFU.';
            });
          }
        }
      } catch (error) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(pendingKey);
        } catch (e) {
          // Ignore
        }
        pending = false;
        widget.options.parameters.updateIsLoadingModalVisible(false);
        if (mounted) {
          setState(() {
            _error = 'Unable to create room on MediaSFU. $error';
          });
        }
      }
    } else {
      await _createRoomOnLocalServer(createData: createData);
      pending = false;
    }
  }

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
          if (mounted) {
            setState(() {
              _error = 'Unable to create room. ${res.reason}';
            });
          }
        }
      },
    );
  }

  Future<void> _createRemoteRoom() async {
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

    final roomIdentifier =
        'mediasfu_create_${name}_${durationInt}_$capacityInt';
    final pendingKey = 'prejoin_pending_$roomIdentifier';
    const pendingTimeout = 30 * 1000;

    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingRequest = prefs.getString(pendingKey);
      if (pendingRequest != null) {
        final pendingData = jsonDecode(pendingRequest);
        final timeSincePending = DateTime.now().millisecondsSinceEpoch -
            ((pendingData['timestamp'] as num?)?.toInt() ?? 0);
        if (timeSincePending < pendingTimeout) {
          pending = false;
          widget.options.parameters.updateIsLoadingModalVisible(false);
          if (mounted) {
            setState(() {
              _error = 'Room creation already in progress';
            });
          }
          return;
        } else {
          await prefs.remove(pendingKey);
        }
      }
    } catch (e) {
      // Ignore
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        pendingKey,
        jsonEncode({
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'payload': {
            'action': 'create',
            'userName': name,
            'duration': durationInt,
            'capacity': capacityInt,
          },
        }),
      );
      Future.delayed(const Duration(milliseconds: pendingTimeout), () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(pendingKey);
        } catch (e) {
          // Ignore
        }
      });
    } catch (e) {
      // Ignore
    }

    try {
      final response = await widget.options.createMediaSFURoom!(
        CreateMediaSFUOptions(
          payload: payload,
          apiUserName: widget.options.credentials.apiUserName,
          apiKey: widget.options.credentials.apiKey,
          localLink: widget.options.localLink ?? '',
        ),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(pendingKey);
      } catch (e) {
        // Ignore
      }

      if (response.success && response.data is CreateJoinRoomResponse) {
        final data = response.data;
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
        if (mounted) {
          setState(() {
            _error = 'Unable to create room. ${errorData.error}';
          });
        }
      } else {
        pending = false;
        if (mounted) {
          setState(() {
            _error = 'Unexpected error occurred.';
          });
        }
      }
    } catch (error) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(pendingKey);
      } catch (e) {
        // Ignore
      }
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

  Future<void> _handleJoinRoom() async {
    if (pending) return;
    pending = true;
    if (mounted) {
      setState(() {
        _error = '';
      });
    }

    if (widget.options.returnUI!) {
      if (_name.isEmpty || _eventID.isEmpty) {
        if (mounted) {
          setState(() => _error = 'Please fill all the fields.');
        }
        pending = false;
        return;
      }

      if (_name.length < 2 || _name.length > 10) {
        if (mounted) {
          setState(() {
            _error = 'Display Name must be between 2 and 10 characters.';
          });
        }
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
      await _joinLocalRoom();
      pending = false;
    } else {
      await _joinRemoteRoom();
      pending = false;
    }
  }

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
          if (mounted) {
            setState(() {
              _error = 'Unable to join room. ${res.reason}';
            });
          }
        }
      },
    );
  }

  Future<void> _joinRemoteRoom() async {
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
      final response = await widget.options.joinMediaSFURoom!(
        JoinMediaSFUOptions(
          payload: payload,
          apiUserName: widget.options.credentials.apiUserName,
          apiKey: widget.options.credentials.apiKey,
          localLink: widget.options.localLink ?? '',
        ),
      );

      if (response.success && response.data is CreateJoinRoomResponse) {
        final data = response.data;
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
        if (mounted) {
          setState(() {
            _error = 'Unable to join room. ${errorData.error}';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Unexpected error occurred.';
          });
        }
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error joining room: $error');
        print(stackTrace);
      }
      widget.options.parameters.showAlert?.call(
        message: 'Unable to join room. ${error.toString()}',
        type: 'danger',
        duration: 3000,
      );
    } finally {
      widget.options.parameters.updateIsLoadingModalVisible(false);
    }
  }

  void _toggleMode() {
    if (mounted) {
      setState(() {
        _isCreateMode = !_isCreateMode;
        _error = '';
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MODERN UI BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // If no UI is needed, return an empty container (same as original)
    if (!widget.options.returnUI!) {
      return const SizedBox();
    }

    // If a custom builder is provided, use it (same as original)
    if (widget.options.customBuilder != null) {
      return widget.options.customBuilder!(options: widget.options);
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = MediasfuTypography.textTheme(darkMode: isDark);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)]
                    : const [Color(0xFFE0E7FF), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Frosted blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(color: Colors.transparent),
          ),
          // Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: MediasfuSpacing.insetAll(MediasfuSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        // Logo with gradient ring and glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                MediasfuColors.brandGradient(darkMode: isDark),
                            boxShadow: [
                              BoxShadow(
                                color: MediasfuColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(
                              widget.options.parameters.imgSrc ??
                                  'https://mediasfu.com/images/logo192.png',
                            ),
                          ),
                        ),
                        const SizedBox(height: MediasfuSpacing.lg),

                        // Hero card
                        GradientCard(
                          title:
                              _isCreateMode ? 'Create a Room' : 'Join a Room',
                          subtitle: _isCreateMode
                              ? 'Start a new session with your audience.'
                              : 'Enter the meeting ID to connect.',
                        ),
                        const SizedBox(height: MediasfuSpacing.xl),

                        // Form container
                        GlassmorphicContainer(
                          padding: MediasfuSpacing.insetAll(MediasfuSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ModernTextField(
                                label: 'Display Name',
                                hint: '2-10 characters',
                                onChanged: (v) => _name = v,
                              ),
                              const SizedBox(height: MediasfuSpacing.md),
                              if (_isCreateMode) ...[
                                _ModernTextField(
                                  label: 'Duration (minutes)',
                                  hint: 'e.g. 30',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _duration = v,
                                ),
                                const SizedBox(height: MediasfuSpacing.md),
                                _ModernTextField(
                                  label: 'Capacity',
                                  hint: 'Max participants',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _capacity = v,
                                ),
                                const SizedBox(height: MediasfuSpacing.md),
                                _ModernDropdown(
                                  label: 'Event Type',
                                  value: _eventType.isEmpty ? null : _eventType,
                                  items: const [
                                    'chat',
                                    'broadcast',
                                    'webinar',
                                    'conference'
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _eventType = v ?? ''),
                                ),
                              ] else ...[
                                _ModernTextField(
                                  label: 'Meeting ID',
                                  hint: 'Paste your event ID',
                                  onChanged: (v) => _eventID = v,
                                ),
                              ],
                              if (_error.isNotEmpty) ...[
                                const SizedBox(height: MediasfuSpacing.md),
                                Text(
                                  _error,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: MediasfuColors.danger,
                                  ),
                                ),
                              ],
                              const SizedBox(height: MediasfuSpacing.lg),
                              _ModernPrimaryButton(
                                label:
                                    _isCreateMode ? 'Create Room' : 'Join Room',
                                loading: pending,
                                onPressed: _isCreateMode
                                    ? _handleCreateRoom
                                    : _handleJoinRoom,
                              ),
                              const SizedBox(height: MediasfuSpacing.sm),
                              Center(
                                child: Text(
                                  'OR',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: MediasfuSpacing.sm),
                              // Premium switch mode button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(MediasfuBorders.lg),
                                  border: Border.all(
                                    color: isDark
                                        ? MediasfuColors.primaryDark
                                            .withValues(alpha: 0.5)
                                        : MediasfuColors.primary
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _toggleMode,
                                    borderRadius: BorderRadius.circular(
                                        MediasfuBorders.lg),
                                    child: Padding(
                                      padding: MediasfuSpacing.insetSymmetric(
                                        horizontal: MediasfuSpacing.md,
                                        vertical: MediasfuSpacing.sm,
                                      ),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            MediasfuColors.brandGradient(
                                                    darkMode: isDark)
                                                .createShader(bounds),
                                        child: Text(
                                          _isCreateMode
                                              ? 'Switch to Join Mode'
                                              : 'Switch to Create Mode',
                                          style: textTheme.labelLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODERN FORM WIDGETS (internal)
// ─────────────────────────────────────────────────────────────────────────────

class _ModernTextField extends StatefulWidget {
  const _ModernTextField({
    required this.label,
    this.hint,
    this.keyboardType,
    required this.onChanged,
  });

  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MediasfuBorders.lg),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: MediasfuColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: TextField(
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: MediasfuTypography.bodyLarge.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            labelStyle: TextStyle(
              color: _isFocused
                  ? MediasfuColors.primary
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MediasfuBorders.lg),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MediasfuBorders.lg),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MediasfuBorders.lg),
              borderSide: BorderSide(
                color: MediasfuColors.primary,
                width: 2,
              ),
            ),
            contentPadding: MediasfuSpacing.insetSymmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernDropdown extends StatelessWidget {
  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'Select ${label.toLowerCase()}',
      decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: isDark),
        fontSize: 12,
      ),
      child: Container(
        decoration: MediasfuColors.dropdownDecoration(darkMode: isDark),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: MediasfuColors.dropdownBackground(darkMode: isDark),
          style: MediasfuColors.dropdownTextStyle(darkMode: isDark),
          icon: ShaderMask(
            shaderCallback: (bounds) =>
                MediasfuColors.brandGradient(darkMode: isDark)
                    .createShader(bounds),
            child: const Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: MediasfuSpacing.insetSymmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      _capitalize(e),
                      style: MediasfuTypography.bodyLarge.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

class _ModernPrimaryButton extends StatefulWidget {
  const _ModernPrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  State<_ModernPrimaryButton> createState() => _ModernPrimaryButtonState();
}

class _ModernPrimaryButtonState extends State<_ModernPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          decoration: BoxDecoration(
            gradient: MediasfuColors.brandGradient(darkMode: isDark),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color:
                    MediasfuColors.primary.withValues(alpha: _glowAnim.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              ...MediasfuColors.elevation(level: 2, darkMode: isDark),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.loading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: MediasfuSpacing.insetSymmetric(
              horizontal: MediasfuSpacing.xl,
              vertical: MediasfuSpacing.md,
            ),
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: MediasfuTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience builder conforming to PreJoinPageType signature.
Widget modernPreJoinPageBuilder({PreJoinPageOptions? options}) {
  if (options == null) {
    throw ArgumentError('PreJoinPageOptions is required for ModernPreJoinPage');
  }
  return ModernPreJoinPage(options: options);
}
