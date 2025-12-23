import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../types/types.dart' show ShowAlert, SleepType;
import '../../methods/utils/sleep.dart' show SleepOptions;
import '../../methods/utils/platform_feature_support.dart'
    show PlatformFeatureSupport, MediasfuFeature;
import '../../methods/whiteboard_methods/capture_canvas_stream.dart'
    show ScreenAnnotationCapture, isWebCanvasCaptureSupported;
import 'whiteboard_shape.dart';
import 'whiteboard_painter.dart';

/// Parameters for the Screenboard widget.
/// Matches React ScreenboardParameters interface.
abstract class ScreenboardParameters {
  String get roomName;
  String get islevel;
  String get member;
  bool get shared;
  bool get shareScreenStarted;
  bool get annotateScreenStream;
  String get hostLabel;
  bool get whiteboardStarted;
  ShowAlert? get showAlert;
  SleepType get sleep;

  /// The canvas/capture instance for annotation broadcasting (web only).
  /// On web, this is an HTMLCanvasElement from ScreenAnnotationCapture.
  dynamic get canvasScreenboard;

  void Function(dynamic) get updateCanvasScreenboard;
  void Function(bool) get updateIsScreenboardModalVisible;
  void Function(bool) get updateAnnotateScreenStream;

  ScreenboardParameters Function() get getUpdatedAllParams;
}

/// Drawing modes for screenboard.
/// Matches React: draw (line), freehand, shape, erase
enum ScreenboardMode {
  draw,
  freehand,
  shape,
  erase,
}

/// Options for the Screenboard widget.
/// Matches React ScreenboardOptions interface.
class ScreenboardOptions {
  final double customWidth;
  final double customHeight;
  final ScreenboardParameters parameters;
  final bool showAspect;
  final Color defaultColor;
  final double brushThickness;
  final double lineThickness;
  final double eraserThickness;
  final bool allowAnnotation;
  final bool autoRemoveShapes;
  final Duration autoRemoveDuration;

  ScreenboardOptions({
    required this.customWidth,
    required this.customHeight,
    required this.parameters,
    this.showAspect = true,
    this.defaultColor = Colors.black,
    this.brushThickness = 6.0,
    this.lineThickness = 6.0,
    this.eraserThickness = 10.0,
    this.allowAnnotation = true,
    this.autoRemoveShapes = true,
    this.autoRemoveDuration = const Duration(seconds: 15),
  });
}

/// Type definition for the Screenboard widget.
typedef ScreenboardType = Widget Function(
    {required ScreenboardOptions options});

/// Screenboard - Annotation overlay for screen sharing.
///
/// This is a feature-complete whiteboard component designed to overlay on top of
/// a shared screen, allowing users to draw annotations during screen sharing.
/// Full parity with React Screenboard implementation.
///
/// Features:
/// - Line drawing mode with customizable thickness
/// - Freehand drawing with brush
/// - Shape tools (rectangle, circle, triangle, pentagon, hexagon, rhombus, octagon, parallelogram, oval, square)
/// - Eraser with adjustable size
/// - Color selection palette
/// - Line type options (solid, dashed, dotted, dash-dot)
/// - Thickness controls for brush, line, and eraser
/// - Auto-remove annotations after 15 seconds (configurable)
/// - Toggle toolbar visibility
/// - Real-time sync with other participants
/// - Touch and mouse input support
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     // Screen share video
///     VideoWidget(stream: screenStream),
///     // Annotation overlay
///     Screenboard(
///       options: ScreenboardOptions(
///         parameters: screenboardParams,
///         defaultColor: Colors.red,
///       ),
///     ),
///   ],
/// )
/// ```
class Screenboard extends StatefulWidget {
  final ScreenboardOptions options;

  const Screenboard({super.key, required this.options});

  @override
  State<Screenboard> createState() => _ScreenboardState();
}

class _ScreenboardState extends State<Screenboard> {
  // Shape storage
  final List<WhiteboardShape> _shapes = [];
  final List<Timer> _autoRemoveTimers = [];

  // Current drawing state - using pattern from whiteboard.dart
  bool _isDrawing = false;
  Offset? _startPoint;
  Offset? _currentPoint;
  List<Offset> _freehandPoints = [];

  // Mode and settings
  ScreenboardMode _mode = ScreenboardMode.draw;
  WhiteboardShapeType _shapeType = WhiteboardShapeType.rectangle;
  Color _color = Colors.black;
  double _brushThickness = 6.0;
  double _lineThickness = 6.0;
  double _eraserThickness = 10.0;

  // UI state
  bool _annotationEnabled = false;
  bool _toolbarVisible = false;

  // Eraser cursor position (for visual feedback) - use ValueNotifier for efficient updates
  final ValueNotifier<Offset?> _eraserCursorNotifier =
      ValueNotifier<Offset?>(null);

  ScreenboardParameters get _params => widget.options.parameters;

  /// Computed current shape being drawn (matches whiteboard.dart pattern).
  /// This eliminates duplicate shapes and ensures lineType is always correct.
  WhiteboardShape? get _currentShape {
    if (!_isDrawing || _startPoint == null || _currentPoint == null) {
      // For freehand, allow shape even while not technically "drawing" if we have points
      if (_mode == ScreenboardMode.freehand && _freehandPoints.length >= 2) {
        return WhiteboardShape(
          type: WhiteboardShapeType.freehand,
          points: List.from(_freehandPoints),
          color: _color,
          thickness: _brushThickness,
        );
      }
      return null;
    }

    if (_mode == ScreenboardMode.draw) {
      return WhiteboardShape(
        type: WhiteboardShapeType.line,
        start: _startPoint,
        end: _currentPoint,
        color: _color,
        thickness: _lineThickness,
      );
    } else if (_mode == ScreenboardMode.shape) {
      return WhiteboardShape(
        type: _shapeType,
        start: _startPoint,
        end: _currentPoint,
        color: _color,
        thickness: _lineThickness,
      );
    } else if (_mode == ScreenboardMode.freehand &&
        _freehandPoints.length >= 2) {
      return WhiteboardShape(
        type: WhiteboardShapeType.freehand,
        points: List.from(_freehandPoints),
        color: _color,
        thickness: _brushThickness,
      );
    }

    return null;
  }

  /// Checks if the user can toggle annotation mode (host or sharer during screen share)
  bool get _canToggleAnnotate {
    if (!widget.options.allowAnnotation) return false;
    if (!_params.shareScreenStarted && !_params.shared) return false;
    final isHost = _params.islevel == '2';
    final isSharer = _params.shared;
    return isHost || isSharer;
  }

  /// Checks if annotation/drawing is currently enabled
  bool get _canAnnotate {
    return _canToggleAnnotate && _params.annotateScreenStream;
  }

  @override
  void initState() {
    super.initState();
    _color = widget.options.defaultColor;
    _brushThickness = widget.options.brushThickness;
    _lineThickness = widget.options.lineThickness;
    _eraserThickness = widget.options.eraserThickness;
  }

  void _scheduleAutoRemove(int shapeIndex) {
    final timer = Timer(widget.options.autoRemoveDuration, () {
      if (mounted && shapeIndex < _shapes.length) {
        setState(() {
          if (_shapes.isNotEmpty) {
            _shapes.removeAt(0); // Remove oldest shape
          }
        });
      }
    });
    _autoRemoveTimers.add(timer);
  }

  void _cancelAllAutoRemoveTimers() {
    for (final timer in _autoRemoveTimers) {
      timer.cancel();
    }
    _autoRemoveTimers.clear();
  }

  void _startDrawing(Offset position) {
    if (!_canAnnotate || !_annotationEnabled) return;

    setState(() {
      _isDrawing = true;
      _startPoint = position;
      _currentPoint = position;

      if (_mode == ScreenboardMode.erase) {
        _erase(position);
      } else if (_mode == ScreenboardMode.freehand) {
        _freehandPoints = [position];
      }
      // For draw and shape modes, the computed _currentShape getter handles creation
    });
  }

  void _updateDrawing(Offset position) {
    if (!_isDrawing) return;

    setState(() {
      _currentPoint = position;

      if (_mode == ScreenboardMode.erase) {
        _erase(position);
        _syncToHtmlCanvas();
      } else if (_mode == ScreenboardMode.freehand) {
        _freehandPoints.add(position);
        _syncToHtmlCanvas();
      } else {
        // For draw and shape modes, just update currentPoint
        // The computed _currentShape getter handles shape creation
        _syncToHtmlCanvas();
      }
    });
  }

  void _endDrawing() {
    final shape = _currentShape;
    if (!_isDrawing || shape == null) return;

    setState(() {
      _shapes.add(shape);
      _isDrawing = false;
      _startPoint = null;
      _currentPoint = null;
      _freehandPoints = [];
    });

    // Update HTML canvas for web annotation broadcasting
    // (annotations are broadcast via canvas capture, not socket)
    _syncToHtmlCanvas();

    // Schedule auto-remove
    if (widget.options.autoRemoveShapes) {
      _scheduleAutoRemove(_shapes.length - 1);
    }
  }

  /// Syncs all shapes to the HTML canvas for web annotation broadcasting.
  ///
  /// This replicates React's approach where annotations drawn on the
  /// canvasScreenboard are combined with the screen video and broadcast.
  void _syncToHtmlCanvas() {
    if (!kIsWeb || !isWebCanvasCaptureSupported()) return;

    final canvasScreenboard = _params.canvasScreenboard;
    if (canvasScreenboard == null) return;

    // canvasScreenboard is the ScreenAnnotationCapture instance (on web)
    // We call redrawShapes() to update the HTML canvas with all current shapes

    // Convert shapes to format expected by ScreenAnnotationCapture
    final shapesList = _shapes.map((shape) => _shapeToMap(shape)).toList();

    // If there's a current shape being drawn, include it
    if (_currentShape != null) {
      shapesList.add(_shapeToMap(_currentShape!));
    }

    // Call redrawShapes on the ScreenAnnotationCapture instance
    try {
      if (canvasScreenboard is ScreenAnnotationCapture) {
        canvasScreenboard.redrawShapes(shapesList);
      }
    } catch (e) {
      debugPrint('Screenboard: Error syncing to HTML canvas: $e');
    }
  }

  /// Converts a WhiteboardShape to a map for HTML canvas drawing.
  Map<String, dynamic> _shapeToMap(WhiteboardShape shape) {
    // Convert color to hex string (e.g., #FF0000 for red)
    final colorHex =
        '#${shape.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    return {
      'type': shape.type.name,
      'x1': shape.start?.dx ?? 0,
      'y1': shape.start?.dy ?? 0,
      'x2': shape.end?.dx ?? 0,
      'y2': shape.end?.dy ?? 0,
      'color': colorHex,
      'thickness': shape.thickness,
      'points': shape.points?.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }

  void _erase(Offset position) {
    final threshold = _eraserThickness / 2;

    setState(() {
      _shapes.removeWhere((shape) {
        if (shape.type == WhiteboardShapeType.freehand &&
            shape.points != null) {
          // Remove points near eraser
          return shape.points!.any((point) {
            final distance = math.sqrt(math.pow(point.dx - position.dx, 2) +
                math.pow(point.dy - position.dy, 2));
            return distance <= threshold;
          });
        } else if (shape.type == WhiteboardShapeType.line) {
          return _isPointNearLine(
            position.dx,
            position.dy,
            shape.start!.dx,
            shape.start!.dy,
            shape.end!.dx,
            shape.end!.dy,
            threshold,
          );
        } else if (shape.start != null && shape.end != null) {
          // Check if point is inside bounding box
          final minX = math.min(shape.start!.dx, shape.end!.dx);
          final maxX = math.max(shape.start!.dx, shape.end!.dx);
          final minY = math.min(shape.start!.dy, shape.end!.dy);
          final maxY = math.max(shape.start!.dy, shape.end!.dy);
          return position.dx >= minX &&
              position.dx <= maxX &&
              position.dy >= minY &&
              position.dy <= maxY;
        }
        return false;
      });
    });
  }

  bool _isPointNearLine(double px, double py, double x1, double y1, double x2,
      double y2, double threshold) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return false;

    final dot = ((px - x1) * dx + (py - y1) * dy) / (length * length);
    final closestX = x1 + dot * dx;
    final closestY = y1 + dot * dy;
    final distance =
        math.sqrt(math.pow(px - closestX, 2) + math.pow(py - closestY, 2));
    return distance <= threshold;
  }

  void _toggleAnnotation() async {
    // Check if screenboard is supported on the current platform
    if (!PlatformFeatureSupport.isScreenboardSupported) {
      _params.showAlert?.call(
        message: PlatformFeatureSupport.getUnsupportedMessage(
          MediasfuFeature.screenboard,
        ),
        type: 'danger',
        duration: 4000,
      );
      return;
    }

    final newAnnotateState = !_params.annotateScreenStream;
    _params.updateAnnotateScreenStream(newAnnotateState);

    setState(() {
      _annotationEnabled = newAnnotateState;
      if (newAnnotateState) {
        _toolbarVisible = true;
        _params.showAlert?.call(
          message:
              "You can now annotate the screen. If you cannot see your annotation controls (on top), try minimizing your screen by using 'Cmd' + '-' (on Mac) or 'Ctrl' + '-' (on Windows).",
          type: 'success',
          duration: 9000,
        );
      } else {
        _toolbarVisible = false;
      }
    });

    // Brief modal visibility toggle for UI feedback (matches React exactly)
    // The modal's showModal/hideModal check annotateScreenStream state,
    // so capture persists even when modal closes
    _params.updateIsScreenboardModalVisible(true);
    await _params.sleep(SleepOptions(ms: 500));
    _params.updateIsScreenboardModalVisible(false);
  }

  void _toggleToolbar() {
    setState(() {
      _toolbarVisible = !_toolbarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Match React: hide if showAspect is false or sharing not active
    if (!widget.options.showAspect) {
      return const SizedBox.shrink();
    }
    if (!_params.shareScreenStarted && !_params.shared) {
      return const SizedBox.shrink();
    }

    // Use a Stack for the screenboard overlay
    return SizedBox(
      width: widget.options.customWidth,
      height: widget.options.customHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Drawing canvas (only shown when annotation enabled)
          if (_annotationEnabled)
            Positioned.fill(
              child: Listener(
                onPointerHover: (event) {
                  if (_mode == ScreenboardMode.erase) {
                    // Use ValueNotifier to avoid full widget rebuild
                    _eraserCursorNotifier.value = event.localPosition;
                  }
                },
                onPointerMove: (event) {
                  if (_mode == ScreenboardMode.erase && event.down) {
                    _eraserCursorNotifier.value = event.localPosition;
                  }
                },
                child: MouseRegion(
                  cursor: _mode == ScreenboardMode.erase
                      ? SystemMouseCursors.none
                      : SystemMouseCursors.precise,
                  onExit: (_) {
                    if (_mode == ScreenboardMode.erase) {
                      _eraserCursorNotifier.value = null;
                    }
                  },
                  child: GestureDetector(
                    onPanStart: (details) =>
                        _startDrawing(details.localPosition),
                    onPanUpdate: (details) =>
                        _updateDrawing(details.localPosition),
                    onPanEnd: (_) => _endDrawing(),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: WhiteboardPainter(
                          shapes: [
                            ..._shapes,
                            if (_currentShape != null) _currentShape!
                          ],
                          panOffset: Offset.zero,
                          scale: 1.0,
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                          transparentBackground:
                              true, // Screenboard is a transparent overlay
                        ),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Eraser cursor overlay - uses ValueListenableBuilder for efficient updates
          if (_annotationEnabled && _mode == ScreenboardMode.erase)
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

          // Annotate toggle button
          Positioned(
            top: 5,
            right: 10,
            child: _buildAnnotateButton(),
          ),

          // Toolbar toggle button
          if (_params.annotateScreenStream)
            Positioned(
              top: 5,
              right: 55,
              child: _buildToolbarToggle(),
            ),

          // Full toolbar
          if (_params.annotateScreenStream && _toolbarVisible)
            Positioned(
              top: 5,
              right: 105,
              child: _buildToolbar(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnotateButton() {
    return Tooltip(
      message:
          _params.annotateScreenStream ? 'Stop Annotating' : 'Start Annotating',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_canToggleAnnotate) {
              _toggleAnnotation();
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.edit,
              color: _params.annotateScreenStream ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarToggle() {
    return Tooltip(
      message: _toolbarVisible ? 'Hide Toolbar' : 'Show Toolbar',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleToolbar,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _toolbarVisible ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Draw mode (Line)
          _buildDropdownButton(
            id: 'draw',
            icon: Icons.edit,
            color: Colors.grey,
            isActive: _mode == ScreenboardMode.draw,
            items: _lineThicknessItems,
            tooltip: 'Line Tool',
            onItemSelected: (value) {
              setState(() {
                _lineThickness = value;
                _mode = ScreenboardMode.draw;
              });
            },
          ),

          // Freehand mode
          _buildDropdownButton(
            id: 'freehand',
            icon: Icons.brush,
            color: Colors.grey.shade800,
            isActive: _mode == ScreenboardMode.freehand,
            items: _brushThicknessItems,
            tooltip: 'Freehand Brush',
            onItemSelected: (value) {
              setState(() {
                _brushThickness = value;
                _mode = ScreenboardMode.freehand;
              });
            },
          ),

          // Shape mode
          _buildDropdownButton(
            id: 'shape',
            icon: Icons.category,
            color: Colors.grey.shade800,
            isActive: _mode == ScreenboardMode.shape,
            items: _shapeItems,
            tooltip: 'Shape Tool',
            onItemSelected: (value) {
              setState(() {
                _shapeType = value;
                _mode = ScreenboardMode.shape;
              });
            },
          ),

          // Eraser mode
          _buildDropdownButton(
            id: 'erase',
            icon: Icons.cleaning_services,
            color: Colors.red,
            isActive: _mode == ScreenboardMode.erase,
            items: _eraserThicknessItems,
            tooltip: 'Eraser',
            onItemSelected: (value) {
              setState(() {
                _eraserThickness = value;
                _mode = ScreenboardMode.erase;
              });
            },
          ),

          const SizedBox(width: 4),

          // Color picker
          _buildColorPicker(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _lineThicknessItems => [
        {'label': 'XX-Small (3px)', 'value': 3.0},
        {'label': 'X-Small (6px)', 'value': 6.0},
        {'label': 'Small (12px)', 'value': 12.0},
        {'label': 'Medium (18px)', 'value': 18.0},
        {'label': 'Large (24px)', 'value': 24.0},
        {'label': 'X-Large (36px)', 'value': 36.0},
      ];

  List<Map<String, dynamic>> get _brushThicknessItems => [
        {'label': 'X-Small (5px)', 'value': 5.0},
        {'label': 'Small (10px)', 'value': 10.0},
        {'label': 'Medium (20px)', 'value': 20.0},
        {'label': 'Large (40px)', 'value': 40.0},
        {'label': 'X-Large (60px)', 'value': 60.0},
      ];

  List<Map<String, dynamic>> get _eraserThicknessItems => [
        {'label': 'X-Small (5px)', 'value': 5.0},
        {'label': 'Small (10px)', 'value': 10.0},
        {'label': 'Medium (20px)', 'value': 20.0},
        {'label': 'Large (30px)', 'value': 30.0},
        {'label': 'X-Large (60px)', 'value': 60.0},
      ];

  List<Map<String, dynamic>> get _shapeItems => [
        {
          'label': 'Square',
          'value': WhiteboardShapeType.rectangle,
          'icon': Icons.crop_square
        },
        {
          'label': 'Rectangle',
          'value': WhiteboardShapeType.rectangle,
          'icon': Icons.rectangle_outlined
        },
        {
          'label': 'Circle',
          'value': WhiteboardShapeType.circle,
          'icon': Icons.circle_outlined
        },
        {
          'label': 'Triangle',
          'value': WhiteboardShapeType.triangle,
          'icon': Icons.change_history
        },
        {
          'label': 'Hexagon',
          'value': WhiteboardShapeType.hexagon,
          'icon': Icons.hexagon_outlined
        },
        {
          'label': 'Pentagon',
          'value': WhiteboardShapeType.pentagon,
          'icon': Icons.pentagon_outlined
        },
        {
          'label': 'Rhombus',
          'value': WhiteboardShapeType.rhombus,
          'icon': Icons.diamond_outlined
        },
        {
          'label': 'Octagon',
          'value': WhiteboardShapeType.octagon,
          'icon': Icons.stop_outlined
        },
        {
          'label': 'Parallelogram',
          'value': WhiteboardShapeType.parallelogram,
          'icon': Icons.crop_portrait
        },
        {
          'label': 'Oval',
          'value': WhiteboardShapeType.oval,
          'icon': Icons.lens_outlined
        },
      ];

  Widget _buildDropdownButton({
    required String id,
    required IconData icon,
    required Color color,
    required bool isActive,
    required List<Map<String, dynamic>> items,
    required void Function(dynamic value) onItemSelected,
    String? tooltip,
  }) {
    // Use PopupMenuButton for reliable dropdown behavior
    return PopupMenuButton<dynamic>(
      tooltip: tooltip ?? '',
      onSelected: (value) {
        onItemSelected(value);
      },
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: Colors.white,
      elevation: 8,
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<dynamic>(
          value: item['value'],
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item['icon'] != null)
                Icon(item['icon'], size: 16, color: Colors.black54),
              if (item['icon'] != null) const SizedBox(width: 8),
              Text(
                item['label'],
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isActive ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Tooltip(
      message: 'Color',
      child: InkWell(
        onTap: () async {
          final selectedColor = await showDialog<Color>(
            context: context,
            builder: (context) => _ColorPickerDialog(initialColor: _color),
          );
          if (selectedColor != null) {
            setState(() {
              _color = selectedColor;
            });
          }
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _color,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancelAllAutoRemoveTimers();
    _eraserCursorNotifier.dispose();
    super.dispose();
  }
}

/// Simple color picker dialog
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  static const List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 280,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((color) {
            final isSelected = color == _selectedColor;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
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
