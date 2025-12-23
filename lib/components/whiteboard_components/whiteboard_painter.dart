import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'whiteboard_shape.dart';

/// CustomPainter that renders all shapes on the whiteboard canvas.
///
/// This painter handles rendering of all shape types including freehand drawings,
/// geometric shapes, text, and images with support for zoom and pan transformations.
class WhiteboardPainter extends CustomPainter {
  /// List of shapes to render.
  final List<WhiteboardShape> shapes;

  /// Current shape being drawn (preview).
  final WhiteboardShape? currentShape;

  /// Current pan offset.
  final Offset panOffset;

  /// Current zoom scale.
  final double scale;

  /// Maximum canvas width.
  final double maxWidth;

  /// Maximum canvas height.
  final double maxHeight;

  /// Whether to use image background.
  final bool useImageBackground;

  /// Background image (if any).
  final ui.Image? backgroundImage;

  /// Selected shape for highlighting.
  final WhiteboardShape? selectedShape;

  /// Eraser cursor position (for visual feedback).
  final Offset? eraserCursorPosition;

  /// Eraser thickness.
  final double eraserThickness;

  /// Whether to use a transparent background (for screen annotation overlays).
  final bool transparentBackground;

  WhiteboardPainter({
    required this.shapes,
    this.currentShape,
    required this.panOffset,
    required this.scale,
    required this.maxWidth,
    required this.maxHeight,
    this.useImageBackground = false,
    this.backgroundImage,
    this.selectedShape,
    this.eraserCursorPosition,
    this.eraserThickness = 10.0,
    this.transparentBackground = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Save the canvas state
    canvas.save();

    // Apply zoom and pan transformations
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(scale);

    // Draw background
    _drawBackground(canvas, size);

    // Draw all shapes
    for (final shape in shapes) {
      _drawShape(canvas, shape);
    }

    // Draw current shape being drawn (preview)
    if (currentShape != null) {
      _drawShape(canvas, currentShape!);
    }

    // Draw selection handles if a shape is selected
    if (selectedShape != null) {
      _drawSelection(canvas, selectedShape!);
    }

    // Restore canvas state
    canvas.restore();

    // Draw eraser cursor (not affected by zoom/pan - drawn at screen position)
    if (eraserCursorPosition != null) {
      _drawEraserCursor(canvas, eraserCursorPosition!);
    }

    // Draw edge markers (not affected by zoom/pan)
    _drawEdgeMarkers(canvas, size);
  }

  /// Draws the eraser cursor as a circle at the given position
  void _drawEraserCursor(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw circle at cursor position (using screen coordinates, not canvas coordinates)
    canvas.drawCircle(position, eraserThickness / 2, paint);

    // Draw a filled semi-transparent circle for better visibility
    final fillPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, eraserThickness / 2, fillPaint);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // For transparent overlays (like screenboard), skip background drawing
    if (transparentBackground) return;

    final bgRect = Rect.fromLTWH(
      -panOffset.dx / scale,
      -panOffset.dy / scale,
      size.width / scale,
      size.height / scale,
    );

    if (useImageBackground && backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: bgRect,
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else {
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(bgRect, bgPaint);
    }
  }

  void _drawShape(Canvas canvas, WhiteboardShape shape) {
    final paint = Paint()
      ..color = shape.color
      ..strokeWidth = shape.thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (shape.type) {
      case WhiteboardShapeType.freehand:
        _drawFreehand(canvas, shape, paint);
        break;
      case WhiteboardShapeType.line:
        _drawLine(canvas, shape, paint);
        break;
      case WhiteboardShapeType.rectangle:
        _drawRectangle(canvas, shape, paint);
        break;
      case WhiteboardShapeType.circle:
        _drawCircle(canvas, shape, paint);
        break;
      case WhiteboardShapeType.oval:
        _drawOval(canvas, shape, paint);
        break;
      case WhiteboardShapeType.triangle:
        _drawPolygon(canvas, shape, paint, 3);
        break;
      case WhiteboardShapeType.pentagon:
        _drawPolygon(canvas, shape, paint, 5);
        break;
      case WhiteboardShapeType.hexagon:
        _drawPolygon(canvas, shape, paint, 6);
        break;
      case WhiteboardShapeType.octagon:
        _drawPolygon(canvas, shape, paint, 8);
        break;
      case WhiteboardShapeType.rhombus:
        _drawRhombus(canvas, shape, paint);
        break;
      case WhiteboardShapeType.parallelogram:
        _drawParallelogram(canvas, shape, paint);
        break;
      case WhiteboardShapeType.text:
        _drawText(canvas, shape);
        break;
      case WhiteboardShapeType.image:
        _drawImage(canvas, shape);
        break;
    }
  }

  /// Returns the dash pattern for the given line type.
  /// Matches React implementation: dashed [10,10], dotted [2,10], dashDot [10,5,2,5]
  /// Note: For dotted, using [2,6] for better visibility with StrokeCap.round
  CircularIntervalList<double>? _getDashPattern(
      LineType lineType, double strokeWidth) {
    switch (lineType) {
      case LineType.dashed:
        // Scale dash/gap proportionally with stroke width for consistency
        final dashLength = math.max(10.0, strokeWidth * 2);
        return CircularIntervalList<double>([dashLength, dashLength]);
      case LineType.dotted:
        // For dotted lines: tiny dash (creates round dot with StrokeCap.round)
        // Gap should be proportional to stroke for visible separation
        final dotSize = math.max(1.0, strokeWidth * 0.3);
        final gapSize = math.max(6.0, strokeWidth * 1.5);
        return CircularIntervalList<double>([dotSize, gapSize]);
      case LineType.dashDot:
        final dash = math.max(10.0, strokeWidth * 2);
        final shortGap = math.max(5.0, strokeWidth);
        final dot = math.max(1.0, strokeWidth * 0.3);
        return CircularIntervalList<double>([dash, shortGap, dot, shortGap]);
      case LineType.solid:
        return null;
    }
  }

  /// Draws a path with optional dash pattern applied.
  void _drawPathWithDash(
      Canvas canvas, Path path, Paint paint, LineType lineType) {
    final dashPattern = _getDashPattern(lineType, paint.strokeWidth);
    if (dashPattern != null) {
      canvas.drawPath(dashPath(path, dashArray: dashPattern), paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawFreehand(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.points == null || shape.points!.length < 2) return;

    final path = Path();
    path.moveTo(shape.points!.first.dx, shape.points!.first.dy);

    for (int i = 1; i < shape.points!.length; i++) {
      path.lineTo(shape.points![i].dx, shape.points![i].dy);
    }

    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawLine(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;
    final path = Path()
      ..moveTo(shape.start!.dx, shape.start!.dy)
      ..lineTo(shape.end!.dx, shape.end!.dy);
    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawRectangle(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;
    final rect = Rect.fromPoints(shape.start!, shape.end!);
    final path = Path()..addRect(rect);
    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawCircle(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;
    final center = Offset(
      (shape.start!.dx + shape.end!.dx) / 2,
      (shape.start!.dy + shape.end!.dy) / 2,
    );
    final radius = math.min(
          (shape.end!.dx - shape.start!.dx).abs(),
          (shape.end!.dy - shape.start!.dy).abs(),
        ) /
        2;
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawOval(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;
    final rect = Rect.fromPoints(shape.start!, shape.end!);
    final path = Path()..addOval(rect);
    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawPolygon(
      Canvas canvas, WhiteboardShape shape, Paint paint, int sides) {
    if (shape.start == null || shape.end == null) return;

    final centerX = (shape.start!.dx + shape.end!.dx) / 2;
    final centerY = (shape.start!.dy + shape.end!.dy) / 2;
    final radius = math.min(
          (shape.end!.dx - shape.start!.dx).abs(),
          (shape.end!.dy - shape.start!.dy).abs(),
        ) /
        2;

    final angle = (2 * math.pi) / sides;
    final path = Path();

    for (int i = 0; i < sides; i++) {
      final x = centerX + radius * math.cos(i * angle - math.pi / 2);
      final y = centerY + radius * math.sin(i * angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawRhombus(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;

    final centerX = (shape.start!.dx + shape.end!.dx) / 2;
    final centerY = (shape.start!.dy + shape.end!.dy) / 2;
    final halfWidth = (shape.end!.dx - shape.start!.dx).abs() / 2;
    final halfHeight = (shape.end!.dy - shape.start!.dy).abs() / 2;

    final path = Path()
      ..moveTo(centerX, centerY - halfHeight)
      ..lineTo(centerX + halfWidth, centerY)
      ..lineTo(centerX, centerY + halfHeight)
      ..lineTo(centerX - halfWidth, centerY)
      ..close();

    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawParallelogram(Canvas canvas, WhiteboardShape shape, Paint paint) {
    if (shape.start == null || shape.end == null) return;

    final skew = (shape.end!.dx - shape.start!.dx).abs() * 0.2;

    final path = Path()
      ..moveTo(shape.start!.dx + skew, shape.start!.dy)
      ..lineTo(shape.end!.dx, shape.start!.dy)
      ..lineTo(shape.end!.dx - skew, shape.end!.dy)
      ..lineTo(shape.start!.dx, shape.end!.dy)
      ..close();

    _drawPathWithDash(canvas, path, paint, shape.lineType);
  }

  void _drawText(Canvas canvas, WhiteboardShape shape) {
    if (shape.text == null || shape.start == null) return;

    final textStyle = TextStyle(
      color: shape.color,
      fontSize: shape.fontSize ?? 20,
      fontFamily: shape.fontFamily ?? 'Arial',
    );

    final textSpan = TextSpan(text: shape.text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, shape.start!);
  }

  void _drawImage(Canvas canvas, WhiteboardShape shape) {
    if (shape.image == null || shape.start == null || shape.end == null) return;

    final rect = Rect.fromPoints(shape.start!, shape.end!);
    paintImage(
      canvas: canvas,
      rect: rect,
      image: shape.image!,
      fit: BoxFit.contain,
    );
  }

  void _drawSelection(Canvas canvas, WhiteboardShape shape) {
    final selectionPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final centerHandlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Rect? bounds;

    if (shape.start != null && shape.end != null) {
      bounds = Rect.fromPoints(shape.start!, shape.end!);
    } else if (shape.points != null && shape.points!.isNotEmpty) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final point in shape.points!) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }

      bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    }

    if (bounds != null) {
      // Draw selection rectangle
      canvas.drawRect(bounds.inflate(5), selectionPaint);

      // Draw corner handles
      const handleSize = 8.0;
      final cornerHandles = [
        bounds.topLeft,
        bounds.topRight,
        bounds.bottomLeft,
        bounds.bottomRight,
      ];

      for (final handle in cornerHandles) {
        canvas.drawCircle(handle, handleSize / 2, handlePaint);
      }

      // Draw center handle (different color for move)
      canvas.drawCircle(bounds.center, handleSize / 2, centerHandlePaint);
    }
  }

  void _drawEdgeMarkers(Canvas canvas, Size size) {
    final markerPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const markerLength = 20.0;

    final topLeftX = panOffset.dx;
    final topLeftY = panOffset.dy;
    final bottomRightX = panOffset.dx + maxWidth * scale;
    final bottomRightY = panOffset.dy + maxHeight * scale;

    // Top-left corner
    canvas.drawLine(
      Offset(topLeftX, topLeftY + markerLength),
      Offset(topLeftX, topLeftY),
      markerPaint,
    );
    canvas.drawLine(
      Offset(topLeftX, topLeftY),
      Offset(topLeftX + markerLength, topLeftY),
      markerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(bottomRightX - markerLength, topLeftY),
      Offset(bottomRightX, topLeftY),
      markerPaint,
    );
    canvas.drawLine(
      Offset(bottomRightX, topLeftY),
      Offset(bottomRightX, topLeftY + markerLength),
      markerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(bottomRightX, bottomRightY - markerLength),
      Offset(bottomRightX, bottomRightY),
      markerPaint,
    );
    canvas.drawLine(
      Offset(bottomRightX, bottomRightY),
      Offset(bottomRightX - markerLength, bottomRightY),
      markerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(topLeftX + markerLength, bottomRightY),
      Offset(topLeftX, bottomRightY),
      markerPaint,
    );
    canvas.drawLine(
      Offset(topLeftX, bottomRightY),
      Offset(topLeftX, bottomRightY - markerLength),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) {
    // Compare list lengths first, then reference
    // This ensures repaint happens when shapes are added/removed
    return shapes.length != oldDelegate.shapes.length ||
        shapes != oldDelegate.shapes ||
        currentShape != oldDelegate.currentShape ||
        panOffset != oldDelegate.panOffset ||
        scale != oldDelegate.scale ||
        useImageBackground != oldDelegate.useImageBackground ||
        backgroundImage != oldDelegate.backgroundImage ||
        selectedShape != oldDelegate.selectedShape;
  }
}
