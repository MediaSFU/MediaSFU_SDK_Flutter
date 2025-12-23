import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../types/types.dart'
    show
        ShowAlert,
        WhiteboardUser,
        Participant,
        OnScreenChangesType,
        OnScreenChangesOptions,
        OnScreenChangesParameters,
        CaptureCanvasStreamType,
        CaptureCanvasStreamOptions,
        CaptureCanvasStreamParameters;
import 'whiteboard_shape.dart';
import 'whiteboard_painter.dart';
import 'whiteboard_toolbar.dart';

/// Parameters for the Whiteboard widget.
///
/// Contains all the state and callbacks needed for whiteboard functionality.
abstract class WhiteboardParameters {
  io.Socket? get socket;
  ShowAlert? get showAlert;
  String get islevel;
  String get roomName;
  List<WhiteboardShape> get shapes;
  bool get useImageBackground;
  List<WhiteboardShape> get redoStack;
  List<String> get undoStack;
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  List<WhiteboardUser> get whiteboardUsers;
  List<Participant> get participants;
  List<Participant> get participantsAll;
  String get screenId;
  bool get recordStarted;
  bool get recordStopped;
  bool get recordPaused;
  bool get recordResumed;
  String get recordingMediaOptions;
  String get member;
  bool get shareScreenStarted;
  String? get targetResolution;
  String? get targetResolutionHost;

  void Function(List<WhiteboardShape>) get updateShapes;
  void Function(bool) get updateUseImageBackground;
  void Function(List<WhiteboardShape>) get updateRedoStack;
  void Function(List<String>) get updateUndoStack;
  void Function(bool) get updateWhiteboardStarted;
  void Function(bool) get updateWhiteboardEnded;
  void Function(List<WhiteboardUser>) get updateWhiteboardUsers;
  void Function(List<Participant>) get updateParticipants;
  void Function(String) get updateScreenId;
  void Function(bool) get updateShareScreenStarted;
  void Function(GlobalKey?) get updateCanvasWhiteboard;

  // Mediasfu functions
  OnScreenChangesType get onScreenChanges;
  CaptureCanvasStreamType? get captureCanvasStream;

  WhiteboardParameters Function() get getUpdatedAllParams;
}

/// Options for configuring the Whiteboard widget.
class WhiteboardOptions {
  /// Width of the whiteboard canvas.
  final double customWidth;

  /// Height of the whiteboard canvas.
  final double customHeight;

  /// Whiteboard parameters containing state and callbacks.
  final WhiteboardParameters parameters;

  /// Whether to show aspect ratio indicator.
  final bool showAspect;

  WhiteboardOptions({
    required this.customWidth,
    required this.customHeight,
    required this.parameters,
    this.showAspect = true,
  });
}

/// Type definition for Whiteboard widget builder.
typedef WhiteboardType = Widget Function({required WhiteboardOptions options});

/// Whiteboard - Real-time collaborative drawing and annotation canvas
///
/// A feature-rich whiteboard component for collaborative drawing, annotations, and visual brainstorming.
/// Supports freehand drawing, shapes, text, images, erasers, undo/redo, zoom/pan, and real-time
/// synchronization across participants. Perfect for virtual classrooms, design reviews, workshops,
/// and interactive presentations.
///
/// Features:
/// - Freehand drawing with customizable brush and thickness
/// - Shape tools (rectangle, circle, line, triangle, polygon, etc.)
/// - Text annotations with font customization
/// - Image uploads and background images
/// - Eraser tool with adjustable size
/// - Undo/redo functionality
/// - Zoom in/out with pan navigation
/// - Color palette selection
/// - Line type selection (solid, dashed, dotted)
/// - Real-time socket synchronization
/// - Multi-user collaboration with user tracking
/// - Touch and mouse input support
///
/// Example:
/// ```dart
/// Whiteboard(
///   options: WhiteboardOptions(
///     customWidth: 1280,
///     customHeight: 720,
///     parameters: whiteboardParameters,
///     showAspect: true,
///   ),
/// )
/// ```
class Whiteboard extends StatefulWidget {
  final WhiteboardOptions options;

  const Whiteboard({super.key, required this.options});

  @override
  State<Whiteboard> createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboard> {
  // Drawing state
  WhiteboardMode _mode = WhiteboardMode.pan;
  WhiteboardShapeType _currentShapeType = WhiteboardShapeType.rectangle;
  bool _isDrawing = false;
  Offset? _startPoint;
  Offset? _currentPoint;
  List<Offset> _freehandPoints = [];
  WhiteboardShape? _selectedShape;

  // Canvas state
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  static const double _minScale = 0.25;
  static const double _maxScale = 1.75;

  // Tool settings
  Color _currentColor = Colors.black;
  double _brushThickness = 6.0;
  double _lineThickness = 6.0;
  double _eraserThickness = 10.0;
  LineType _lineType = LineType.solid;
  final String _fontFamily = 'Arial';
  double _fontSize = 20.0;

  // Canvas dimensions
  late double _maxWidth;
  late double _maxHeight;

  // Background
  ui.Image? _backgroundImage;
  bool _useImageBackground = false;

  // Undo/Redo stacks
  final List<List<WhiteboardShape>> _undoStack = [];
  final List<List<WhiteboardShape>> _redoStack = [];

  // Canvas key for capturing
  final GlobalKey _canvasKey = GlobalKey();

  // Toolbar visibility
  bool _toolbarVisible = true;

  // Text input controller
  final TextEditingController _textController = TextEditingController();
  bool _showTextInput = false;
  Offset _textInputPosition = Offset.zero;

  // Eraser cursor position (for visual feedback) - use ValueNotifier for efficient updates
  final ValueNotifier<Offset?> _eraserCursorNotifier =
      ValueNotifier<Offset?>(null);
  // ignore: unused_element
  Offset? get _eraserCursorPosition => _eraserCursorNotifier.value;
  set _eraserCursorPosition(Offset? value) =>
      _eraserCursorNotifier.value = value;

  // Track if erasing occurred during current pan (for debounced emission)
  bool _eraserChangeOccurred = false;

  // Select mode state
  bool _isMovingShape = false;
  bool _isResizingShape = false;
  Offset? _selectStartPoint;
  String? _selectedHandle; // 'tl', 'tr', 'bl', 'br', 'center', etc.

  // Local shapes list
  List<WhiteboardShape> _shapes = [];

  // Get parameters
  WhiteboardParameters get _params => widget.options.parameters;

  // Socket listener subscriptions
  bool _socketListenersAttached = false;

  @override
  void initState() {
    super.initState();
    _initializeCanvas();
    _loadBackgroundImage();
    _syncShapesFromParams();
    _params.updateCanvasWhiteboard(_canvasKey);
    _setupSocketListeners();
  }

  /// Sets up socket listeners for real-time whiteboard synchronization
  void _setupSocketListeners() {
    final socket = _params.socket;
    if (socket == null || _socketListenersAttached) return;
    _socketListenersAttached = true;

    // Listen for real-time whiteboard actions from other participants
    socket.on('whiteboardAction', _handleWhiteboardAction);

    // Listen for whiteboard state updates (users, data, status)
    socket.on('whiteboardUpdated', _handleWhiteboardUpdated);
  }

  /// Handles real-time whiteboard actions from the server
  void _handleWhiteboardAction(dynamic data) {
    if (!mounted) return;

    try {
      final action = data['action'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;

      if (action == null) return;

      // Schedule the state update on the next frame to ensure UI rebuild
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _processWhiteboardAction(action, payload);
      });
    } catch (e) {
      if (kDebugMode) print('Error in whiteboardAction: $e');
    }
  }

  /// Processes the whiteboard action and updates state
  void _processWhiteboardAction(String action, Map<String, dynamic>? payload) {
    // Process action and update state - each case triggers UI update
    switch (action) {
      case 'draw':
        _handleDrawAction(payload);
        break;
      case 'shape':
        _handleShapeAction(payload);
        break;
      case 'erase':
        _handleEraseAction(payload);
        break;
      case 'clear':
        setState(() {
          _shapes = [];
          _params.updateShapes(_shapes);
        });
        break;
      case 'uploadImage':
        _handleUploadImageAction(payload);
        break;
      case 'toggleBackground':
        setState(() {
          _useImageBackground = !_useImageBackground;
          _params.updateUseImageBackground(_useImageBackground);
        });
        break;
      case 'undo':
        setState(() {
          if (_shapes.isNotEmpty) {
            _redoStack.add(List.from(_shapes));
            _shapes = List.from(_shapes)..removeLast();
            _params.updateShapes(_shapes);
          }
        });
        break;
      case 'redo':
        setState(() {
          if (_redoStack.isNotEmpty) {
            _undoStack.add(List.from(_shapes));
            final lastState = _redoStack.removeLast();
            _shapes = lastState;
            _params.updateShapes(_shapes);
          }
        });
        break;
      case 'text':
        _handleTextAction(payload);
        break;
      case 'deleteShape':
        _handleDeleteShapeAction(payload);
        break;
      case 'shapes':
        _handleShapesAction(payload);
        break;
    }
  }

  void _handleDrawAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final type = payload['type'] as String?;
    if (type == 'freehand') {
      final pointsList = payload['points'] as List<dynamic>?;
      if (pointsList != null) {
        final points = pointsList.map((p) {
          if (p is Map) {
            return Offset(
              (p['x'] as num?)?.toDouble() ?? 0,
              (p['y'] as num?)?.toDouble() ?? 0,
            );
          }
          return Offset.zero;
        }).toList();

        final shape = WhiteboardShape(
          type: WhiteboardShapeType.freehand,
          points: points,
          color: _parseColor(payload['color']),
          thickness: (payload['thickness'] as num?)?.toDouble() ?? 6.0,
        );
        setState(() {
          _shapes = List.from(_shapes)..add(shape);
          _params.updateShapes(_shapes);
        });
      }
    } else {
      // Line
      final shape = WhiteboardShape(
        type: WhiteboardShapeType.line,
        start: Offset(
          (payload['x1'] as num?)?.toDouble() ?? 0,
          (payload['y1'] as num?)?.toDouble() ?? 0,
        ),
        end: Offset(
          (payload['x2'] as num?)?.toDouble() ?? 0,
          (payload['y2'] as num?)?.toDouble() ?? 0,
        ),
        color: _parseColor(payload['color']),
        thickness: (payload['thickness'] as num?)?.toDouble() ?? 6.0,
        lineType: _parseLineType(payload['lineType']),
      );
      setState(() {
        _shapes = List.from(_shapes)..add(shape);
        _params.updateShapes(_shapes);
      });
    }
  }

  void _handleShapeAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final shapeType = _parseShapeType(payload['type'] as String?);
    final shape = WhiteboardShape(
      type: shapeType,
      start: Offset(
        (payload['x1'] as num?)?.toDouble() ?? 0,
        (payload['y1'] as num?)?.toDouble() ?? 0,
      ),
      end: Offset(
        (payload['x2'] as num?)?.toDouble() ?? 0,
        (payload['y2'] as num?)?.toDouble() ?? 0,
      ),
      color: _parseColor(payload['color']),
      thickness: (payload['thickness'] as num?)?.toDouble() ?? 6.0,
      lineType: _parseLineType(payload['lineType']),
    );
    setState(() {
      _shapes = List.from(_shapes)..add(shape);
      _params.updateShapes(_shapes);
    });
  }

  void _handleEraseAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final x = (payload['x'] as num?)?.toDouble() ?? 0;
    final y = (payload['y'] as num?)?.toDouble() ?? 0;
    _erase(Offset(x, y), isRemote: true);
  }

  void _handleUploadImageAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final shape = WhiteboardShape(
      type: WhiteboardShapeType.image,
      start: Offset(
        (payload['x1'] as num?)?.toDouble() ?? 0,
        (payload['y1'] as num?)?.toDouble() ?? 0,
      ),
      end: Offset(
        (payload['x2'] as num?)?.toDouble() ?? 0,
        (payload['y2'] as num?)?.toDouble() ?? 0,
      ),
      imageSrc: payload['src'] as String?,
      color: Colors.black,
      thickness: 1.0,
    );
    setState(() {
      _shapes = List.from(_shapes)..add(shape);
      _params.updateShapes(_shapes);
    });
  }

  void _handleTextAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final shape = WhiteboardShape(
      type: WhiteboardShapeType.text,
      start: Offset(
        (payload['x'] as num?)?.toDouble() ?? 0,
        (payload['y'] as num?)?.toDouble() ?? 0,
      ),
      text: payload['text'] as String?,
      color: _parseColor(payload['color']),
      thickness: 1.0,
      fontFamily: payload['font'] as String?,
      fontSize: (payload['fontSize'] as num?)?.toDouble() ?? 20.0,
    );
    setState(() {
      _shapes = List.from(_shapes)..add(shape);
      _params.updateShapes(_shapes);
    });
  }

  void _handleDeleteShapeAction(Map<String, dynamic>? payload) {
    if (payload == null) return;

    setState(() {
      // Find and remove the shape matching the payload
      _shapes = List.from(_shapes)
        ..removeWhere((shape) {
          return shape.toMap().toString() == payload.toString();
        });
      _params.updateShapes(_shapes);
    });
  }

  void _handleShapesAction(Map<String, dynamic>? payload,
      {bool shouldSetState = true}) {
    if (payload == null) return;

    final shapesList = payload['shapes'] as List<dynamic>?;
    if (shapesList == null) return;

    final newShapes = shapesList.map((shapeData) {
      if (shapeData is Map<String, dynamic>) {
        return WhiteboardShape.fromMap(shapeData);
      }
      return WhiteboardShape(
        type: WhiteboardShapeType.line,
        color: Colors.black,
        thickness: 6.0,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _shapes = newShapes;
        _params.updateShapes(_shapes);
      });
    }
  }

  /// Handles whiteboard state updates from the server
  Future<void> _handleWhiteboardUpdated(dynamic data) async {
    if (!mounted) return;

    try {
      final params = _params.getUpdatedAllParams();

      // Update participants if host
      if (params.islevel == '2' && data['members'] != null) {
        final membersList = data['members'] as List<dynamic>?;
        if (membersList != null) {
          final filteredParticipants = membersList
              .where((p) => p is Map && p['isBanned'] != true)
              .map((p) => Participant.fromMap(p as Map<String, dynamic>))
              .toList();
          params.updateParticipants(filteredParticipants);
        }
      }

      // Update whiteboard users
      if (data['whiteboardUsers'] != null) {
        final usersList = data['whiteboardUsers'] as List<dynamic>?;
        if (usersList != null) {
          final whiteboardUsers = usersList.map((u) {
            if (u is Map) {
              return WhiteboardUser(
                name: u['name'] as String? ?? '',
                useBoard: u['useBoard'] as bool? ?? false,
              );
            }
            return WhiteboardUser(name: '', useBoard: false);
          }).toList();
          params.updateWhiteboardUsers(whiteboardUsers);

          // Check if current user can use the board
          final useBoard = whiteboardUsers.any(
            (user) => user.name == params.member && user.useBoard,
          );
          if (params.islevel != '2' && !useBoard && !params.whiteboardEnded) {
            setState(() {
              _mode = WhiteboardMode.pan;
            });
          }
        }
      }

      // Update whiteboard data (shapes, background, stacks)
      if (data['whiteboardData'] != null &&
          data['whiteboardData'] is Map &&
          (data['whiteboardData'] as Map).isNotEmpty) {
        final whiteboardData = data['whiteboardData'] as Map<String, dynamic>;

        if (whiteboardData['shapes'] != null) {
          _handleShapesAction({'shapes': whiteboardData['shapes']},
              shouldSetState: true);
        }

        if (whiteboardData['useImageBackground'] != null) {
          setState(() {
            _useImageBackground =
                whiteboardData['useImageBackground'] as bool? ?? true;
          });
          params.updateUseImageBackground(_useImageBackground);
        }

        if (whiteboardData['redoStack'] != null) {
          final redoList = whiteboardData['redoStack'] as List<dynamic>;
          params.updateRedoStack(redoList.map((s) {
            if (s is Map<String, dynamic>) {
              return WhiteboardShape.fromMap(s);
            }
            return WhiteboardShape(
              type: WhiteboardShapeType.line,
              color: Colors.black,
              thickness: 6.0,
            );
          }).toList());
        }

        if (whiteboardData['undoStack'] != null) {
          final undoList = whiteboardData['undoStack'] as List<dynamic>;
          params.updateUndoStack(undoList.map((s) => s.toString()).toList());
        }
      }

      // Handle status changes
      if (data['status'] == 'started' && !params.whiteboardStarted) {
        params.updateWhiteboardStarted(true);
        params.updateWhiteboardEnded(false);
        params.updateScreenId('whiteboard-${params.roomName}');

        if (params.islevel != '2') {
          params.updateShareScreenStarted(true);
          await params.onScreenChanges(OnScreenChangesOptions(
            changed: true,
            parameters: params as OnScreenChangesParameters,
          ));
        }
      } else if (data['status'] == 'ended') {
        final prevWhiteboardEnded = params.whiteboardEnded;
        final prevWhiteboardStarted = params.whiteboardStarted;

        params.updateWhiteboardEnded(true);
        params.updateWhiteboardStarted(false);

        if (params.islevel == '2' && prevWhiteboardEnded) {
          // do nothing
        } else {
          params.updateShareScreenStarted(false);
          params.updateScreenId('');
          await params.onScreenChanges(OnScreenChangesOptions(
            changed: true,
            parameters: params as OnScreenChangesParameters,
          ));
        }

        // Handle recording - stop canvas stream capture when whiteboard ends
        try {
          if (prevWhiteboardStarted &&
              params.islevel == '2' &&
              (params.recordStarted || params.recordResumed)) {
            if (!(params.recordPaused || params.recordStopped)) {
              if (params.recordingMediaOptions == 'video') {
                // Pass start: false to stop the canvas stream capture
                await params.captureCanvasStream?.call(
                  CaptureCanvasStreamOptions(
                    parameters: params as CaptureCanvasStreamParameters,
                    start: false,
                  ),
                );
              }
            }
          }
        } catch (e) {
          if (kDebugMode) print('Error stopping canvas capture: $e');
        }
      } else if (data['status'] == 'started' && params.whiteboardStarted) {
        params.updateWhiteboardStarted(true);
        params.updateWhiteboardEnded(false);
        params.updateShareScreenStarted(true);
        params.updateScreenId('whiteboard-${params.roomName}');
        await params.onScreenChanges(OnScreenChangesOptions(
          changed: true,
          parameters: params as OnScreenChangesParameters,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('Error in whiteboardUpdated: $e');
    }
  }

  /// Parse color from various formats
  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Colors.black;

    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        try {
          final hex = colorValue.replaceFirst('#', '');
          if (hex.length == 6) {
            return Color(int.parse('FF$hex', radix: 16));
          } else if (hex.length == 8) {
            return Color(int.parse(hex, radix: 16));
          }
        } catch (_) {}
      }
      // Try named colors
      switch (colorValue.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'white':
          return Colors.white;
        case 'black':
          return Colors.black;
      }
    }

    return Colors.black;
  }

  /// Parse line type from string
  LineType _parseLineType(dynamic lineTypeValue) {
    if (lineTypeValue == null) return LineType.solid;

    final typeStr = lineTypeValue.toString().toLowerCase();
    switch (typeStr) {
      case 'dashed':
        return LineType.dashed;
      case 'dotted':
        return LineType.dotted;
      case 'dashDot':
      case 'dashdot':
        return LineType.dashDot;
      default:
        return LineType.solid;
    }
  }

  /// Parse shape type from string
  WhiteboardShapeType _parseShapeType(String? typeStr) {
    if (typeStr == null) return WhiteboardShapeType.rectangle;

    switch (typeStr.toLowerCase()) {
      case 'line':
        return WhiteboardShapeType.line;
      case 'circle':
        return WhiteboardShapeType.circle;
      case 'rectangle':
      case 'rect':
        return WhiteboardShapeType.rectangle;
      case 'triangle':
        return WhiteboardShapeType.triangle;
      case 'freehand':
        return WhiteboardShapeType.freehand;
      case 'text':
        return WhiteboardShapeType.text;
      case 'image':
        return WhiteboardShapeType.image;
      case 'rhombus':
        return WhiteboardShapeType.rhombus;
      case 'pentagon':
        return WhiteboardShapeType.pentagon;
      case 'hexagon':
        return WhiteboardShapeType.hexagon;
      case 'octagon':
        return WhiteboardShapeType.octagon;
      case 'parallelogram':
        return WhiteboardShapeType.parallelogram;
      case 'oval':
        return WhiteboardShapeType.oval;
      default:
        return WhiteboardShapeType.rectangle;
    }
  }

  @override
  void didUpdateWidget(Whiteboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncShapesFromParams();
  }

  void _initializeCanvas() {
    final targetRes = _params.targetResolution ?? '';
    final targetResHost = _params.targetResolutionHost ?? '';

    if (targetRes == 'qhd' || targetResHost == 'qhd') {
      _maxWidth = 1920;
      _maxHeight = 1080;
    } else if (targetRes == 'fhd' || targetResHost == 'fhd') {
      _maxWidth = 1920;
      _maxHeight = 1080;
    } else {
      _maxWidth = 1280;
      _maxHeight = 720;
    }
  }

  void _loadBackgroundImage() {
    // Load graph paper background image
    const imageUrl = 'https://mediasfu.com/images/svg/graph_paper.jpg';
    _loadNetworkImage(imageUrl).then((image) {
      if (mounted) {
        setState(() {
          _backgroundImage = image;
        });
      }
    }).catchError((e) {
      if (kDebugMode) print('Error loading background image: $e');
    });
  }

  Future<ui.Image> _loadNetworkImage(String url) async {
    final completer = Completer<ui.Image>();
    final imageStream = NetworkImage(url).resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.complete(info.image);
        imageStream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        completer.completeError(error);
        imageStream.removeListener(listener);
      },
    );

    imageStream.addListener(listener);
    return completer.future;
  }

  void _syncShapesFromParams() {
    _shapes = List.from(_params.shapes);
    _useImageBackground = _params.useImageBackground;
  }

  bool _checkBoardAccess() {
    if (_params.whiteboardStarted && !_params.whiteboardEnded) {
      final user = _params.whiteboardUsers.firstWhere(
        (u) => u.name == _params.member,
        orElse: () => WhiteboardUser(name: '', useBoard: false),
      );

      if ((!user.useBoard || user.name.isEmpty) && _params.islevel != '2') {
        _params.showAlert?.call(
          message:
              'You are not allowed to use the whiteboard. Please ask the host to assign you.',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }
    }
    return true;
  }

  void _changeMode(WhiteboardMode newMode) {
    if (newMode != WhiteboardMode.pan && !_checkBoardAccess()) return;

    setState(() {
      _mode = newMode;

      // Finalize any pending freehand drawing
      if (newMode != WhiteboardMode.freehand && _freehandPoints.isNotEmpty) {
        _finalizeShape();
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    final localPos = _transformPoint(details.localPosition);

    setState(() {
      _isDrawing = true;
      _startPoint = localPos;
      _currentPoint = localPos;

      if (_mode == WhiteboardMode.freehand) {
        _freehandPoints = [localPos];
      } else if (_mode == WhiteboardMode.erase) {
        // Set eraser cursor position for visual feedback during erase
        _eraserCursorPosition = details.localPosition;
        _erase(localPos);
      } else if (_mode == WhiteboardMode.select) {
        // Check if clicking on handle of already selected shape
        if (_selectedShape != null) {
          final handle = _getHandleAtPosition(localPos);
          if (handle != null) {
            _selectedHandle = handle;
            _isResizingShape = true;
            _selectStartPoint = localPos;
            return;
          }
        }
        // Try to find a shape at click position
        final found = _findShapeAt(localPos);
        if (found != null) {
          _selectedShape = found;
          _isMovingShape = true;
          _selectStartPoint = localPos;
        } else {
          _selectedShape = null;
          _isMovingShape = false;
        }
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    final localPos = _transformPoint(details.localPosition);

    setState(() {
      _currentPoint = localPos;

      if (_mode == WhiteboardMode.pan) {
        _panOffset += details.delta;
        _clampPan();
      } else if (_mode == WhiteboardMode.freehand) {
        _freehandPoints.add(localPos);
      } else if (_mode == WhiteboardMode.erase) {
        // Update eraser cursor position during drag for visual feedback
        _eraserCursorPosition = details.localPosition;
        _erase(localPos);
      } else if (_mode == WhiteboardMode.select && _selectedShape != null) {
        if (_isMovingShape && _selectStartPoint != null) {
          // Move the selected shape
          final dx = localPos.dx - _selectStartPoint!.dx;
          final dy = localPos.dy - _selectStartPoint!.dy;
          _moveShape(_selectedShape!, dx, dy);
          _selectStartPoint = localPos;
        } else if (_isResizingShape &&
            _selectedHandle != null &&
            _selectStartPoint != null) {
          // Resize the selected shape
          _resizeShape(_selectedShape!, _selectedHandle!, localPos);
          _selectStartPoint = localPos;
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _isDrawing = false;

      if (_mode == WhiteboardMode.draw ||
          _mode == WhiteboardMode.shape ||
          _mode == WhiteboardMode.freehand) {
        _finalizeShape();
      } else if (_mode == WhiteboardMode.select) {
        // If we moved or resized, emit the update
        if (_isMovingShape || _isResizingShape) {
          _params.updateShapes(_shapes);
          _emitShapesUpdate();
        }
        _isMovingShape = false;
        _isResizingShape = false;
        _selectStartPoint = null;
        _selectedHandle = null;
      } else if (_mode == WhiteboardMode.erase) {
        // Emit the shapes update only once after erasing is complete
        if (_eraserChangeOccurred) {
          _emitShapesUpdate();
          _eraserChangeOccurred = false;
        }
      }

      _startPoint = null;
      _currentPoint = null;
    });
  }

  Offset _transformPoint(Offset point) {
    return (point - _panOffset) / _scale;
  }

  void _clampPan() {
    // Clamp pan to prevent going too far off canvas
    final maxPanX = (_maxWidth * (_scale - 1)) / _scale;
    final maxPanY = (_maxHeight * (_scale - 1)) / _scale;

    _panOffset = Offset(
      _panOffset.dx.clamp(-maxPanX, 0),
      _panOffset.dy.clamp(-maxPanY, 0),
    );
  }

  void _finalizeShape() {
    if (_startPoint == null) return;

    WhiteboardShape? newShape;
    String action = 'draw'; // Default action for lines and freehand

    if (_mode == WhiteboardMode.freehand && _freehandPoints.length >= 2) {
      newShape = WhiteboardShape(
        type: WhiteboardShapeType.freehand,
        points: List.from(_freehandPoints),
        color: _currentColor,
        thickness: _brushThickness,
      );
      action = 'draw';
    } else if (_mode == WhiteboardMode.draw &&
        _startPoint != null &&
        _currentPoint != null) {
      newShape = WhiteboardShape(
        type: WhiteboardShapeType.line,
        start: _startPoint,
        end: _currentPoint,
        color: _currentColor,
        thickness: _lineThickness,
        lineType: _lineType,
      );
      action = 'draw';
    } else if (_mode == WhiteboardMode.shape &&
        _startPoint != null &&
        _currentPoint != null) {
      newShape = WhiteboardShape(
        type: _currentShapeType,
        start: _startPoint,
        end: _currentPoint,
        color: _currentColor,
        thickness: _lineThickness,
        lineType: _lineType,
      );
      action =
          'shape'; // Use 'shape' action for shapes (rectangle, circle, etc.)
    }

    if (newShape != null) {
      _saveState();
      _shapes.add(newShape);
      _params.updateShapes(_shapes);
      _emitBoardAction(action, newShape);
    }

    _freehandPoints = [];
  }

  void _erase(Offset point, {bool isRemote = false}) {
    bool changeOccurred = false;

    _shapes = _shapes
        .map((shape) {
          if (shape.type == WhiteboardShapeType.freehand &&
              shape.points != null) {
            final newPoints = shape.points!.where((p) {
              final distance = (p - point).distance;
              if (distance <= _eraserThickness / 2) {
                changeOccurred = true;
                return false;
              }
              return true;
            }).toList();

            if (newPoints.isEmpty) return null;
            return shape.copyWith(points: newPoints);
          } else if (shape.start != null && shape.end != null) {
            final bounds = Rect.fromPoints(shape.start!, shape.end!);
            if (bounds.contains(point)) {
              changeOccurred = true;
              return null;
            }
          }
          return shape;
        })
        .whereType<WhiteboardShape>()
        .toList();

    if (changeOccurred) {
      if (isRemote) {
        // Remote erase - update UI immediately
        setState(() {
          _params.updateShapes(_shapes);
        });
      } else {
        // Local erase - mark flag, emit on pan end
        _eraserChangeOccurred = true;
        _params.updateShapes(_shapes);
      }
    }
  }

  WhiteboardShape? _findShapeAt(Offset point) {
    for (int i = _shapes.length - 1; i >= 0; i--) {
      final shape = _shapes[i];

      if (shape.start != null && shape.end != null) {
        final bounds = Rect.fromPoints(shape.start!, shape.end!).inflate(10);
        if (bounds.contains(point)) return shape;
      } else if (shape.points != null) {
        for (final p in shape.points!) {
          if ((p - point).distance <= 10) return shape;
        }
      }
    }
    return null;
  }

  /// Gets the resize handle at the given position for the selected shape
  String? _getHandleAtPosition(Offset point) {
    if (_selectedShape == null) return null;

    final handles = _getResizeHandles(_selectedShape!);
    for (final entry in handles.entries) {
      if ((entry.value - point).distance <= 12) {
        return entry.key;
      }
    }
    return null;
  }

  /// Gets all resize handle positions for a shape
  Map<String, Offset> _getResizeHandles(WhiteboardShape shape) {
    final handles = <String, Offset>{};

    if (shape.start != null && shape.end != null) {
      final bounds = Rect.fromPoints(shape.start!, shape.end!);
      handles['tl'] = bounds.topLeft;
      handles['tr'] = bounds.topRight;
      handles['bl'] = bounds.bottomLeft;
      handles['br'] = bounds.bottomRight;
      handles['center'] = bounds.center;
    } else if (shape.points != null && shape.points!.isNotEmpty) {
      // For freehand, just provide a center handle for moving
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final point in shape.points!) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }

      handles['center'] = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    }

    return handles;
  }

  /// Moves a shape by the given delta
  void _moveShape(WhiteboardShape shape, double dx, double dy) {
    final index = _shapes.indexOf(shape);
    if (index == -1) return;

    if (shape.points != null) {
      // Move all points for freehand
      final newPoints =
          shape.points!.map((p) => Offset(p.dx + dx, p.dy + dy)).toList();
      _shapes[index] = shape.copyWith(points: newPoints);
    } else if (shape.start != null && shape.end != null) {
      // Move start and end for other shapes
      _shapes[index] = shape.copyWith(
        start: Offset(shape.start!.dx + dx, shape.start!.dy + dy),
        end: Offset(shape.end!.dx + dx, shape.end!.dy + dy),
      );
    }

    // Update selected shape reference
    _selectedShape = _shapes[index];
  }

  /// Resizes a shape based on the handle being dragged
  void _resizeShape(WhiteboardShape shape, String handle, Offset newPos) {
    final index = _shapes.indexOf(shape);
    if (index == -1) return;

    if (shape.start == null || shape.end == null) return;

    Offset newStart = shape.start!;
    Offset newEnd = shape.end!;

    switch (handle) {
      case 'tl':
        newStart = newPos;
        break;
      case 'tr':
        newStart = Offset(shape.start!.dx, newPos.dy);
        newEnd = Offset(newPos.dx, shape.end!.dy);
        break;
      case 'bl':
        newStart = Offset(newPos.dx, shape.start!.dy);
        newEnd = Offset(shape.end!.dx, newPos.dy);
        break;
      case 'br':
        newEnd = newPos;
        break;
      case 'center':
        // Center handle moves the shape
        final dx = newPos.dx - (shape.start!.dx + shape.end!.dx) / 2;
        final dy = newPos.dy - (shape.start!.dy + shape.end!.dy) / 2;
        newStart = Offset(shape.start!.dx + dx, shape.start!.dy + dy);
        newEnd = Offset(shape.end!.dx + dx, shape.end!.dy + dy);
        break;
    }

    _shapes[index] = shape.copyWith(start: newStart, end: newEnd);
    _selectedShape = _shapes[index];
  }

  void _saveState() {
    _undoStack.add(List.from(_shapes));
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;

    setState(() {
      _redoStack.add(List.from(_shapes));
      _shapes = _undoStack.removeLast();
      _params.updateShapes(_shapes);
    });

    _emitShapesUpdate();
  }

  void _redo() {
    if (_redoStack.isEmpty) return;

    setState(() {
      _undoStack.add(List.from(_shapes));
      _shapes = _redoStack.removeLast();
      _params.updateShapes(_shapes);
    });

    _emitShapesUpdate();
  }

  void _clearCanvas() {
    _saveState();
    setState(() {
      _shapes = [];
      _selectedShape = null;
      _params.updateShapes(_shapes);
    });

    _params.socket?.emit('updateBoardAction', {'action': 'clear'});
  }

  void _deleteSelectedShape() {
    if (_selectedShape == null) return;

    _saveState();
    setState(() {
      _shapes.remove(_selectedShape);
      _selectedShape = null;
      _params.updateShapes(_shapes);
    });

    _emitShapesUpdate();
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(_minScale, _maxScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale * 0.8).clamp(_minScale, _maxScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _panOffset = Offset.zero;
    });
  }

  void _toggleBackground() {
    setState(() {
      _useImageBackground = !_useImageBackground;
      _params.updateUseImageBackground(_useImageBackground);
    });
  }

  /// Saves the current canvas as an image and shares it
  /// Note: Only works on mobile/desktop platforms (not web)
  Future<void> _saveCanvas() async {
    // Web is not supported - share_plus doesn't work on web for files
    if (kIsWeb) {
      _params.showAlert?.call(
        message: 'Save is not supported on web. Use mobile or desktop app.',
        type: 'warning',
        duration: 3000,
      );
      return;
    }

    try {
      // Capture the canvas using RenderRepaintBoundary
      final RenderRepaintBoundary? boundary = _canvasKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        _params.showAlert?.call(
          message: 'Unable to capture canvas',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      // Capture at higher resolution for quality
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        _params.showAlert?.call(
          message: 'Failed to convert canvas to image',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'whiteboard_$timestamp.png';

      // Use share_plus for mobile/desktop
      final XFile xFile = XFile.fromData(
        pngBytes,
        mimeType: 'image/png',
        name: fileName,
      );

      final ShareResult result = await Share.shareXFiles(
        [xFile],
        subject: 'Whiteboard Image',
        text: 'Whiteboard snapshot from MediaSFU',
      );

      if (result.status == ShareResultStatus.success) {
        _params.showAlert?.call(
          message: 'Image shared successfully!',
          type: 'success',
          duration: 3000,
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        // User dismissed the share sheet - no error needed
        if (kDebugMode) print('Share dismissed by user');
      }
    } catch (e) {
      if (kDebugMode) print('Error saving canvas: $e');
      _params.showAlert?.call(
        message: 'Error saving image: $e',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  /// Picks an image and uploads it to the canvas
  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (imageFile == null) return;

      // Check file size (max 1MB)
      final int fileSize = await imageFile.length();
      if (fileSize > 1024 * 1024) {
        _params.showAlert?.call(
          message: 'File size must be less than 1MB',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      // Read the image bytes
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String dataUrl = 'data:image/png;base64,$base64Image';

      // Decode image to get dimensions
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Calculate dimensions maintaining aspect ratio
      double imageWidth = 350;
      final double aspectRatio = image.height / image.width;
      double imageHeight = imageWidth * aspectRatio;
      const double maxHeight = 600;

      if (imageHeight > maxHeight) {
        imageHeight = maxHeight;
        imageWidth = imageHeight / aspectRatio;
        if (imageWidth > 600) {
          imageWidth = 600;
        }
      }

      // Create image shape
      final imageShape = WhiteboardShape(
        type: WhiteboardShapeType.image,
        start: const Offset(50, 50),
        end: Offset(50 + imageWidth, 50 + imageHeight),
        imageSrc: dataUrl,
        image: image,
        color: Colors.black,
        thickness: 1.0,
      );

      _saveState();
      setState(() {
        _shapes.add(imageShape);
        _params.updateShapes(_shapes);
      });

      // Emit to other participants
      _params.socket?.emit('updateBoardAction', {
        'action': 'uploadImage',
        'payload': {
          'src': dataUrl,
          'x1': 50,
          'y1': 50,
          'x2': 50 + imageWidth,
          'y2': 50 + imageHeight,
        },
      });
    } catch (e) {
      if (kDebugMode) print('Error uploading image: $e');
      _params.showAlert?.call(
        message: 'Error uploading image: $e',
        type: 'danger',
        duration: 3000,
      );
    }
  }

  void _showTextInputDialog(Offset position) {
    setState(() {
      _showTextInput = true;
      _textInputPosition = position;
      _textController.clear();
    });
  }

  void _addText() {
    if (_textController.text.isEmpty) return;

    _saveState();
    final textShape = WhiteboardShape(
      type: WhiteboardShapeType.text,
      start: _textInputPosition,
      text: _textController.text,
      color: _currentColor,
      thickness: 1,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
    );

    _shapes.add(textShape);
    _params.updateShapes(_shapes);
    _emitBoardAction('text', textShape);

    setState(() {
      _showTextInput = false;
      _textController.clear();
    });
  }

  void _onCanvasTap(TapUpDetails details) {
    if (_mode == WhiteboardMode.text) {
      final localPos = _transformPoint(details.localPosition);
      _showTextInputDialog(localPos);
    }
  }

  void _emitBoardAction(String action, WhiteboardShape shape) {
    _params.socket?.emit('updateBoardAction', {
      'action': action,
      'payload': shape.toMap(),
    });
  }

  void _emitShapesUpdate() {
    _params.socket?.emit('updateBoardAction', {
      'action': 'shapes',
      'payload': {
        'shapes': _shapes.map((s) => s.toMap()).toList(),
      },
    });
  }

  WhiteboardShape? get _currentShape {
    if (!_isDrawing || _startPoint == null || _currentPoint == null) {
      if (_mode == WhiteboardMode.freehand && _freehandPoints.length >= 2) {
        return WhiteboardShape(
          type: WhiteboardShapeType.freehand,
          points: _freehandPoints,
          color: _currentColor,
          thickness: _brushThickness,
        );
      }
      return null;
    }

    if (_mode == WhiteboardMode.draw) {
      return WhiteboardShape(
        type: WhiteboardShapeType.line,
        start: _startPoint,
        end: _currentPoint,
        color: _currentColor,
        thickness: _lineThickness,
        lineType: _lineType,
      );
    } else if (_mode == WhiteboardMode.shape) {
      return WhiteboardShape(
        type: _currentShapeType,
        start: _startPoint,
        end: _currentPoint,
        color: _currentColor,
        thickness: _lineThickness,
        lineType: _lineType,
      );
    } else if (_mode == WhiteboardMode.freehand &&
        _freehandPoints.length >= 2) {
      return WhiteboardShape(
        type: WhiteboardShapeType.freehand,
        points: _freehandPoints,
        color: _currentColor,
        thickness: _brushThickness,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if showAspect is false
    if (!widget.options.showAspect) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Toolbar
        if (_toolbarVisible)
          WhiteboardToolbar(
            currentMode: _mode,
            currentShapeType: _currentShapeType,
            currentColor: _currentColor,
            brushThickness: _brushThickness,
            lineThickness: _lineThickness,
            eraserThickness: _eraserThickness,
            lineType: _lineType,
            fontSize: _fontSize,
            useImageBackground: _useImageBackground,
            canUndo: _undoStack.isNotEmpty,
            canRedo: _redoStack.isNotEmpty,
            onModeChanged: _changeMode,
            onShapeTypeChanged: (type) =>
                setState(() => _currentShapeType = type),
            onColorChanged: (color) => setState(() => _currentColor = color),
            onBrushThicknessChanged: (t) => setState(() => _brushThickness = t),
            onLineThicknessChanged: (t) => setState(() => _lineThickness = t),
            onEraserThicknessChanged: (t) =>
                setState(() => _eraserThickness = t),
            onLineTypeChanged: (type) => setState(() => _lineType = type),
            onFontSizeChanged: (size) => setState(() => _fontSize = size),
            onUndo: _undo,
            onRedo: _redo,
            onDeleteShape: _deleteSelectedShape,
            hasSelectedShape: _selectedShape != null,
            onClear: _clearCanvas,
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onResetZoom: _resetZoom,
            onToggleBackground: _toggleBackground,
            onSave: _saveCanvas,
            onUploadImage: _pickAndUploadImage,
            onToggleToolbar: () => setState(() => _toolbarVisible = false),
          ),

        // Canvas
        Expanded(
          child: Stack(
            children: [
              // Main canvas
              RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onTapUp: _onCanvasTap,
                  child: Listener(
                    onPointerHover: (event) {
                      if (_mode == WhiteboardMode.erase) {
                        // Use ValueNotifier to avoid full widget rebuild
                        _eraserCursorNotifier.value = event.localPosition;
                      }
                    },
                    onPointerMove: (event) {
                      if (_mode == WhiteboardMode.erase && event.down) {
                        _eraserCursorNotifier.value = event.localPosition;
                      }
                    },
                    child: MouseRegion(
                      cursor: _getCursor(),
                      onExit: (_) {
                        if (_mode == WhiteboardMode.erase) {
                          _eraserCursorNotifier.value = null;
                        }
                      },
                      child: Container(
                        width: widget.options.customWidth,
                        height: widget.options.customHeight,
                        color: Colors.grey[200],
                        child: ClipRect(
                          child: CustomPaint(
                            painter: WhiteboardPainter(
                              shapes: _shapes,
                              currentShape: _currentShape,
                              panOffset: _panOffset,
                              scale: _scale,
                              maxWidth: _maxWidth,
                              maxHeight: _maxHeight,
                              useImageBackground: _useImageBackground,
                              backgroundImage: _backgroundImage,
                              selectedShape: _selectedShape,
                              eraserCursorPosition: null, // Drawn separately
                              eraserThickness: _eraserThickness,
                            ),
                            size: Size(
                              widget.options.customWidth,
                              widget.options.customHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Eraser cursor overlay - uses ValueListenableBuilder for efficient updates
              if (_mode == WhiteboardMode.erase)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<Offset?>(
                      valueListenable: _eraserCursorNotifier,
                      builder: (context, position, child) {
                        if (position == null) return const SizedBox.shrink();
                        return CustomPaint(
                          painter: _EraserCursorPainter(
                            position: position,
                            radius: _eraserThickness / 2,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Show toolbar button when hidden
              if (!_toolbarVisible)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => setState(() => _toolbarVisible = true),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

              // Text input overlay
              if (_showTextInput)
                Positioned(
                  left: _textInputPosition.dx * _scale + _panOffset.dx,
                  top: _textInputPosition.dy * _scale + _panOffset.dy,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _textController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontFamily: _fontFamily,
                              color: _currentColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter text...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addText(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, size: 20),
                          onPressed: _addText,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () =>
                              setState(() => _showTextInput = false),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  MouseCursor _getCursor() {
    switch (_mode) {
      case WhiteboardMode.pan:
        return SystemMouseCursors.grab;
      case WhiteboardMode.draw:
      case WhiteboardMode.freehand:
      case WhiteboardMode.shape:
        return SystemMouseCursors.precise;
      case WhiteboardMode.text:
        return SystemMouseCursors.text;
      case WhiteboardMode.erase:
        return SystemMouseCursors
            .none; // We draw custom eraser cursor in painter
      case WhiteboardMode.select:
        return SystemMouseCursors.click;
    }
  }

  @override
  void dispose() {
    _removeSocketListeners();
    _textController.dispose();
    _eraserCursorNotifier.dispose();
    super.dispose();
  }

  /// Removes socket listeners to prevent memory leaks
  void _removeSocketListeners() {
    final socket = _params.socket;
    if (socket == null || !_socketListenersAttached) return;

    socket.off('whiteboardAction', _handleWhiteboardAction);
    socket.off('whiteboardUpdated', _handleWhiteboardUpdated);
    _socketListenersAttached = false;
  }
}

/// Custom painter for eraser cursor overlay - lightweight and efficient
class _EraserCursorPainter extends CustomPainter {
  final Offset position;
  final double radius;

  _EraserCursorPainter({required this.position, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    // Stroke outline
    final strokePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, radius, strokePaint);

    // Semi-transparent fill
    final fillPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _EraserCursorPainter oldDelegate) {
    return position != oldDelegate.position || radius != oldDelegate.radius;
  }
}
