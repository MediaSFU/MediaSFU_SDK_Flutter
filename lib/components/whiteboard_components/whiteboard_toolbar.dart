import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_drawing/path_drawing.dart';
import 'whiteboard_shape.dart';

/// Toolbar widget for the whiteboard providing drawing tools and controls.
///
/// This widget renders a horizontal toolbar with buttons for:
/// - Drawing mode selection (pan, draw, freehand, shapes, text, erase, select)
/// - Shape type selection
/// - Color picker
/// - Thickness controls
/// - Line type selection
/// - Undo/redo
/// - Zoom controls
/// - Background toggle
class WhiteboardToolbar extends StatefulWidget {
  /// Current drawing mode.
  final WhiteboardMode currentMode;

  /// Current shape type for shape mode.
  final WhiteboardShapeType currentShapeType;

  /// Current drawing color.
  final Color currentColor;

  /// Current brush thickness for freehand drawing.
  final double brushThickness;

  /// Current line thickness for shapes.
  final double lineThickness;

  /// Current eraser thickness.
  final double eraserThickness;

  /// Current line type.
  final LineType lineType;

  /// Current font size for text.
  final double fontSize;

  /// Whether using image background.
  final bool useImageBackground;

  /// Whether undo is available.
  final bool canUndo;

  /// Whether redo is available.
  final bool canRedo;

  /// Callback when mode changes.
  final ValueChanged<WhiteboardMode> onModeChanged;

  /// Callback when shape type changes.
  final ValueChanged<WhiteboardShapeType> onShapeTypeChanged;

  /// Callback when color changes.
  final ValueChanged<Color> onColorChanged;

  /// Callback when brush thickness changes.
  final ValueChanged<double> onBrushThicknessChanged;

  /// Callback when line thickness changes.
  final ValueChanged<double> onLineThicknessChanged;

  /// Callback when eraser thickness changes.
  final ValueChanged<double> onEraserThicknessChanged;

  /// Callback when line type changes.
  final ValueChanged<LineType> onLineTypeChanged;

  /// Callback when font size changes.
  final ValueChanged<double> onFontSizeChanged;

  /// Callback for undo action.
  final VoidCallback onUndo;

  /// Callback for redo action.
  final VoidCallback onRedo;

  /// Callback for delete selected shape action.
  final VoidCallback? onDeleteShape;

  /// Whether a shape is currently selected.
  final bool hasSelectedShape;

  /// Callback for clear canvas action.
  final VoidCallback onClear;

  /// Callback for zoom in action.
  final VoidCallback onZoomIn;

  /// Callback for zoom out action.
  final VoidCallback onZoomOut;

  /// Callback for reset zoom action.
  final VoidCallback onResetZoom;

  /// Callback for toggle background action.
  final VoidCallback onToggleBackground;

  /// Callback for saving canvas as image.
  final VoidCallback? onSave;

  /// Callback for uploading image to canvas.
  final VoidCallback? onUploadImage;

  /// Callback for hiding the toolbar.
  final VoidCallback onToggleToolbar;

  const WhiteboardToolbar({
    super.key,
    required this.currentMode,
    required this.currentShapeType,
    required this.currentColor,
    required this.brushThickness,
    required this.lineThickness,
    required this.eraserThickness,
    required this.lineType,
    required this.fontSize,
    required this.useImageBackground,
    required this.canUndo,
    required this.canRedo,
    required this.onModeChanged,
    required this.onShapeTypeChanged,
    required this.onColorChanged,
    required this.onBrushThicknessChanged,
    required this.onLineThicknessChanged,
    required this.onEraserThicknessChanged,
    required this.onLineTypeChanged,
    required this.onFontSizeChanged,
    required this.onUndo,
    required this.onRedo,
    this.onDeleteShape,
    this.hasSelectedShape = false,
    required this.onClear,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onToggleBackground,
    this.onSave,
    this.onUploadImage,
    required this.onToggleToolbar,
  });

  @override
  State<WhiteboardToolbar> createState() => _WhiteboardToolbarState();
}

class _WhiteboardToolbarState extends State<WhiteboardToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode buttons
            _buildModeButton(
              WhiteboardMode.pan,
              FontAwesomeIcons.hand,
              'Pan',
            ),
            _buildModeButton(
              WhiteboardMode.select,
              FontAwesomeIcons.arrowPointer,
              'Select',
            ),
            _buildModeButton(
              WhiteboardMode.draw,
              FontAwesomeIcons.pencil,
              'Line',
            ),
            _buildModeButton(
              WhiteboardMode.freehand,
              FontAwesomeIcons.paintbrush,
              'Freehand',
            ),
            _buildShapeButton(),
            _buildModeButton(
              WhiteboardMode.text,
              FontAwesomeIcons.font,
              'Text',
            ),
            _buildEraserButton(),

            _buildDivider(),

            // Color picker
            _buildColorButton(),

            // Thickness
            _buildThicknessButton(),

            // Line type
            _buildLineTypeButton(),

            _buildDivider(),

            // Undo/Redo
            _buildActionButton(
              FontAwesomeIcons.arrowRotateLeft,
              'Undo',
              widget.canUndo ? widget.onUndo : null,
            ),
            _buildActionButton(
              FontAwesomeIcons.arrowRotateRight,
              'Redo',
              widget.canRedo ? widget.onRedo : null,
            ),
            // Delete selected shape
            _buildActionButton(
              FontAwesomeIcons.trash,
              'Delete Selected',
              widget.hasSelectedShape ? widget.onDeleteShape : null,
            ),
            // Clear all
            _buildActionButton(
              FontAwesomeIcons.xmark,
              'Clear All',
              widget.onClear,
            ),
            // Save canvas as image (not supported on web)
            if (!kIsWeb)
              _buildActionButton(
                FontAwesomeIcons.floppyDisk,
                'Save Image',
                widget.onSave,
              ),
            // Upload image
            _buildActionButton(
              FontAwesomeIcons.upload,
              'Upload Image',
              widget.onUploadImage,
            ),

            _buildDivider(),

            // Zoom controls
            _buildActionButton(
              FontAwesomeIcons.magnifyingGlassPlus,
              'Zoom In',
              widget.onZoomIn,
            ),
            _buildActionButton(
              FontAwesomeIcons.magnifyingGlassMinus,
              'Zoom Out',
              widget.onZoomOut,
            ),
            _buildActionButton(
              FontAwesomeIcons.expand,
              'Reset Zoom',
              widget.onResetZoom,
            ),

            _buildDivider(),

            // Background toggle
            _buildActionButton(
              widget.useImageBackground
                  ? FontAwesomeIcons.image
                  : FontAwesomeIcons.squareFull,
              'Toggle Background',
              widget.onToggleBackground,
            ),

            _buildDivider(),

            // Hide toolbar
            _buildActionButton(
              FontAwesomeIcons.chevronUp,
              'Hide Toolbar',
              widget.onToggleToolbar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey[300],
    );
  }

  Widget _buildModeButton(WhiteboardMode mode, IconData icon, String tooltip) {
    final isSelected = widget.currentMode == mode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => widget.onModeChanged(mode),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FaIcon(
            icon,
            size: 18,
            color: isSelected ? Colors.blue : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeButton() {
    final isSelected = widget.currentMode == WhiteboardMode.shape;

    return PopupMenuButton<WhiteboardShapeType>(
      tooltip: 'Shapes',
      onSelected: (type) {
        widget.onShapeTypeChanged(type);
        widget.onModeChanged(WhiteboardMode.shape);
      },
      itemBuilder: (context) => [
        _buildShapeMenuItem(WhiteboardShapeType.rectangle, 'Rectangle',
            FontAwesomeIcons.square),
        _buildShapeMenuItem(
            WhiteboardShapeType.circle, 'Circle', FontAwesomeIcons.circle),
        _buildShapeMenuItem(
            WhiteboardShapeType.triangle, 'Triangle', FontAwesomeIcons.caretUp),
        _buildShapeMenuItem(
            WhiteboardShapeType.oval, 'Oval', FontAwesomeIcons.circle),
        _buildShapeMenuItem(WhiteboardShapeType.pentagon, 'Pentagon',
            FontAwesomeIcons.starOfDavid),
        _buildShapeMenuItem(
            WhiteboardShapeType.hexagon, 'Hexagon', FontAwesomeIcons.drawPolygon),
        _buildShapeMenuItem(WhiteboardShapeType.rhombus, 'Rhombus',
            FontAwesomeIcons.diamondTurnRight),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.shapes,
              size: 18,
              color: isSelected ? Colors.blue : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isSelected ? Colors.blue : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<WhiteboardShapeType> _buildShapeMenuItem(
      WhiteboardShapeType type, String label, IconData icon) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          FaIcon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildEraserButton() {
    final isSelected = widget.currentMode == WhiteboardMode.erase;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eraser mode button
        Tooltip(
          message: 'Eraser',
          child: InkWell(
            onTap: () => widget.onModeChanged(WhiteboardMode.erase),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FaIcon(
                FontAwesomeIcons.eraser,
                size: 18,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
          ),
        ),
        // Eraser size dropdown
        PopupMenuButton<double>(
          tooltip: 'Eraser Size',
          onSelected: widget.onEraserThicknessChanged,
          itemBuilder: (context) => [
            _buildEraserSizeMenuItem(10, 'Small'),
            _buildEraserSizeMenuItem(20, 'Medium'),
            _buildEraserSizeMenuItem(30, 'Large'),
            _buildEraserSizeMenuItem(50, 'Extra Large'),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.eraserThickness.clamp(8, 20),
                  height: widget.eraserThickness.clamp(8, 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.red, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<double> _buildEraserSizeMenuItem(double value, String label) {
    final isSelected = widget.eraserThickness == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: value.clamp(10, 30),
            height: value.clamp(10, 30),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.red,
                width: isSelected ? 2 : 1,
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16, color: Colors.blue),
          ],
        ],
      ),
    );
  }

  Widget _buildColorButton() {
    return Tooltip(
      message: 'Color',
      child: InkWell(
        onTap: () => _showColorPickerDialog(),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.currentColor,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: widget.currentColor,
            onColorChanged: widget.onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildThicknessButton() {
    return PopupMenuButton<double>(
      tooltip: 'Thickness',
      onSelected: (value) {
        if (widget.currentMode == WhiteboardMode.freehand) {
          widget.onBrushThicknessChanged(value);
        } else if (widget.currentMode == WhiteboardMode.erase) {
          widget.onEraserThicknessChanged(value);
        } else {
          widget.onLineThicknessChanged(value);
        }
      },
      itemBuilder: (context) => [
        _buildThicknessMenuItem(2, 'Thin'),
        _buildThicknessMenuItem(4, 'Light'),
        _buildThicknessMenuItem(6, 'Medium'),
        _buildThicknessMenuItem(10, 'Bold'),
        _buildThicknessMenuItem(16, 'Extra Bold'),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: _getDisplayThickness(),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  double _getDisplayThickness() {
    if (widget.currentMode == WhiteboardMode.freehand) {
      return widget.brushThickness.clamp(2, 16);
    } else if (widget.currentMode == WhiteboardMode.erase) {
      return widget.eraserThickness.clamp(2, 16);
    }
    return widget.lineThickness.clamp(2, 16);
  }

  PopupMenuItem<double> _buildThicknessMenuItem(double value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 40,
            height: value.clamp(2, 16),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(value / 2),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLineTypeButton() {
    return PopupMenuButton<LineType>(
      tooltip: 'Line Style',
      onSelected: widget.onLineTypeChanged,
      itemBuilder: (context) => [
        _buildLineTypeMenuItem(LineType.solid, 'Solid'),
        _buildLineTypeMenuItem(LineType.dashed, 'Dashed'),
        _buildLineTypeMenuItem(LineType.dotted, 'Dotted'),
        _buildLineTypeMenuItem(LineType.dashDot, 'Dash-Dot'),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLineTypePreview(widget.lineType),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<LineType> _buildLineTypeMenuItem(LineType type, String label) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          _buildLineTypePreview(type),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLineTypePreview(LineType type) {
    return CustomPaint(
      size: const Size(40, 2),
      painter: _LineTypePainter(type),
    );
  }

  Widget _buildActionButton(
      IconData icon, String tooltip, VoidCallback? onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: FaIcon(
            icon,
            size: 18,
            color: onPressed != null ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for line type preview.
class _LineTypePainter extends CustomPainter {
  final LineType lineType;

  _LineTypePainter(this.lineType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    // Draw with appropriate dash pattern for visual clarity in small preview
    switch (lineType) {
      case LineType.dashed:
        canvas.drawPath(
          dashPath(path, dashArray: CircularIntervalList<double>([8.0, 6.0])),
          paint,
        );
        break;
      case LineType.dotted:
        // Use small dash with proportional gap for visible dots
        canvas.drawPath(
          dashPath(path, dashArray: CircularIntervalList<double>([1.0, 5.0])),
          paint,
        );
        break;
      case LineType.dashDot:
        canvas.drawPath(
          dashPath(path,
              dashArray: CircularIntervalList<double>([8.0, 4.0, 1.0, 4.0])),
          paint,
        );
        break;
      case LineType.solid:
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LineTypePainter oldDelegate) {
    return lineType != oldDelegate.lineType;
  }
}
