// ignore_for_file: unused_import
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Enum representing the different types of shapes that can be drawn on the whiteboard.
enum WhiteboardShapeType {
  freehand,
  line,
  rectangle,
  circle,
  triangle,
  pentagon,
  hexagon,
  rhombus,
  parallelogram,
  octagon,
  oval,
  text,
  image,
}

/// Enum representing the different line types for shapes.
enum LineType {
  solid,
  dashed,
  dotted,
  dashDot,
}

/// Converts a [LineType] to a string representation.
String lineTypeToString(LineType lineType) {
  switch (lineType) {
    case LineType.solid:
      return 'solid';
    case LineType.dashed:
      return 'dashed';
    case LineType.dotted:
      return 'dotted';
    case LineType.dashDot:
      return 'dashDot';
  }
}

/// Converts a string to a [LineType].
LineType stringToLineType(String str) {
  switch (str) {
    case 'dashed':
      return LineType.dashed;
    case 'dotted':
      return LineType.dotted;
    case 'dashDot':
      return LineType.dashDot;
    default:
      return LineType.solid;
  }
}

/// Converts a [WhiteboardShapeType] to a string representation.
String shapeTypeToString(WhiteboardShapeType type) {
  switch (type) {
    case WhiteboardShapeType.freehand:
      return 'freehand';
    case WhiteboardShapeType.line:
      return 'line';
    case WhiteboardShapeType.rectangle:
      return 'rectangle';
    case WhiteboardShapeType.circle:
      return 'circle';
    case WhiteboardShapeType.triangle:
      return 'triangle';
    case WhiteboardShapeType.pentagon:
      return 'pentagon';
    case WhiteboardShapeType.hexagon:
      return 'hexagon';
    case WhiteboardShapeType.rhombus:
      return 'rhombus';
    case WhiteboardShapeType.parallelogram:
      return 'parallelogram';
    case WhiteboardShapeType.octagon:
      return 'octagon';
    case WhiteboardShapeType.oval:
      return 'oval';
    case WhiteboardShapeType.text:
      return 'text';
    case WhiteboardShapeType.image:
      return 'image';
  }
}

/// Converts a string to a [WhiteboardShapeType].
WhiteboardShapeType stringToShapeType(String str) {
  switch (str) {
    case 'freehand':
      return WhiteboardShapeType.freehand;
    case 'line':
      return WhiteboardShapeType.line;
    case 'rectangle':
      return WhiteboardShapeType.rectangle;
    case 'circle':
      return WhiteboardShapeType.circle;
    case 'triangle':
      return WhiteboardShapeType.triangle;
    case 'pentagon':
      return WhiteboardShapeType.pentagon;
    case 'hexagon':
      return WhiteboardShapeType.hexagon;
    case 'rhombus':
      return WhiteboardShapeType.rhombus;
    case 'parallelogram':
      return WhiteboardShapeType.parallelogram;
    case 'octagon':
      return WhiteboardShapeType.octagon;
    case 'oval':
      return WhiteboardShapeType.oval;
    case 'text':
      return WhiteboardShapeType.text;
    case 'image':
      return WhiteboardShapeType.image;
    default:
      return WhiteboardShapeType.freehand;
  }
}

/// Represents a shape on the whiteboard.
///
/// This class encapsulates all the properties needed to draw and serialize
/// shapes on the whiteboard canvas.
class WhiteboardShape {
  /// The type of shape (freehand, line, rectangle, etc.).
  final WhiteboardShapeType type;

  /// Points for freehand drawing.
  final List<Offset>? points;

  /// Start position for shapes.
  final Offset? start;

  /// End position for shapes.
  final Offset? end;

  /// Text content for text shapes.
  final String? text;

  /// Color of the shape.
  final Color color;

  /// Thickness of the stroke.
  final double thickness;

  /// Type of line (solid, dashed, dotted, dashDot).
  final LineType lineType;

  /// Font family for text shapes.
  final String? fontFamily;

  /// Font size for text shapes.
  final double? fontSize;

  /// Image data for image shapes.
  final ui.Image? image;

  /// Image source URL for serialization.
  final String? imageSrc;

  WhiteboardShape({
    required this.type,
    this.points,
    this.start,
    this.end,
    this.text,
    required this.color,
    required this.thickness,
    this.lineType = LineType.solid,
    this.fontFamily,
    this.fontSize,
    this.image,
    this.imageSrc,
  });

  /// Creates a copy of this shape with optional parameter overrides.
  WhiteboardShape copyWith({
    WhiteboardShapeType? type,
    List<Offset>? points,
    Offset? start,
    Offset? end,
    String? text,
    Color? color,
    double? thickness,
    LineType? lineType,
    String? fontFamily,
    double? fontSize,
    ui.Image? image,
    String? imageSrc,
  }) {
    return WhiteboardShape(
      type: type ?? this.type,
      points: points ?? this.points,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      lineType: lineType ?? this.lineType,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      image: image ?? this.image,
      imageSrc: imageSrc ?? this.imageSrc,
    );
  }

  /// Converts the shape to a Map for serialization (socket transmission).
  Map<String, dynamic> toMap() {
    // Convert color to hex string (RRGGBB format)
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    final hexColor =
        '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

    final map = <String, dynamic>{
      'type': shapeTypeToString(type),
      'color': hexColor,
      'thickness': thickness,
      'lineType': lineTypeToString(lineType),
    };

    if (points != null) {
      map['points'] = points!.map((p) => {'x': p.dx, 'y': p.dy}).toList();
    }

    if (start != null) {
      map['x1'] = start!.dx;
      map['y1'] = start!.dy;
    }

    if (end != null) {
      map['x2'] = end!.dx;
      map['y2'] = end!.dy;
    }

    if (text != null) {
      map['text'] = text;
      map['x'] = start?.dx ?? 0;
      map['y'] = start?.dy ?? 0;
    }

    if (fontFamily != null) {
      map['font'] = fontFamily;
    }

    if (fontSize != null) {
      map['fontSize'] = fontSize;
    }

    if (imageSrc != null) {
      map['src'] = imageSrc;
    }

    return map;
  }

  /// Creates a shape from a Map (socket data).
  factory WhiteboardShape.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'freehand';
    final type = stringToShapeType(typeStr);
    final colorStr = map['color'] as String? ?? '#000000';
    final color = _parseColor(colorStr);
    final thickness = (map['thickness'] as num?)?.toDouble() ?? 2.0;
    final lineTypeStr = map['lineType'] as String? ?? 'solid';
    final lineType = stringToLineType(lineTypeStr);

    List<Offset>? points;
    if (map['points'] != null) {
      points = (map['points'] as List)
          .map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList();
    }

    Offset? start;
    if (map['x1'] != null && map['y1'] != null) {
      start = Offset(
        (map['x1'] as num).toDouble(),
        (map['y1'] as num).toDouble(),
      );
    } else if (map['x'] != null && map['y'] != null) {
      start = Offset(
        (map['x'] as num).toDouble(),
        (map['y'] as num).toDouble(),
      );
    }

    Offset? end;
    if (map['x2'] != null && map['y2'] != null) {
      end = Offset(
        (map['x2'] as num).toDouble(),
        (map['y2'] as num).toDouble(),
      );
    }

    return WhiteboardShape(
      type: type,
      points: points,
      start: start,
      end: end,
      text: map['text'] as String?,
      color: color,
      thickness: thickness,
      lineType: lineType,
      fontFamily: map['font'] as String?,
      fontSize: (map['fontSize'] as num?)?.toDouble(),
      imageSrc: map['src'] as String?,
    );
  }

  /// Parses a color string (hex format) to a Color object.
  static Color _parseColor(String colorStr) {
    String hex = colorStr.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

/// Represents the current drawing mode of the whiteboard.
enum WhiteboardMode {
  pan,
  draw,
  freehand,
  shape,
  text,
  erase,
  select,
}

/// Converts a [WhiteboardMode] to a string representation.
String modeToString(WhiteboardMode mode) {
  switch (mode) {
    case WhiteboardMode.pan:
      return 'pan';
    case WhiteboardMode.draw:
      return 'draw';
    case WhiteboardMode.freehand:
      return 'freehand';
    case WhiteboardMode.shape:
      return 'shape';
    case WhiteboardMode.text:
      return 'text';
    case WhiteboardMode.erase:
      return 'erase';
    case WhiteboardMode.select:
      return 'select';
  }
}
