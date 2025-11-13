import 'package:flutter/material.dart';
import 'package:drawing_app/models/drawing_point.dart';
import 'dart:math' as math;

class DrawingProvider with ChangeNotifier {
  final List<List<DrawingPoint>> _strokes = [];
  final List<List<DrawingPoint>> _undoneStrokes = [];
  
  final Paint _currentPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = Colors.black
    ..strokeWidth = 5.0;

  // Drawing modes
  DrawingMode _drawingMode = DrawingMode.freehand;
  Offset? _startPoint;
  
  List<List<DrawingPoint>> get strokes => _strokes;
  DrawingMode get drawingMode => _drawingMode;
  
  Color get currentColor => _currentPaint.color;
  double get currentStrokeWidth => _currentPaint.strokeWidth;

  void setCurrentColor(Color color) {
    _currentPaint.color = color;
    notifyListeners();
  }

  void setCurrentStrokeWidth(double width) {
    _currentPaint.strokeWidth = width;
    notifyListeners();
  }

  void setDrawingMode(DrawingMode mode) {
    _drawingMode = mode;
    notifyListeners();
  }

  void addPoint(Offset offset) {
    if (_strokes.isEmpty) {
      _strokes.add([]);
      _undoneStrokes.clear();
    }
    
    // For freehand drawing, add every point without any optimization
    if (_drawingMode == DrawingMode.freehand) {
      _strokes.last.add(DrawingPoint(
        offset: offset,
        paint: Paint()
          ..color = _currentPaint.color
          ..strokeWidth = _currentPaint.strokeWidth
          ..strokeCap = _currentPaint.strokeCap
          ..strokeJoin = _currentPaint.strokeJoin
          ..style = PaintingStyle.stroke,
      ));
      notifyListeners();
    } else {
      // For shapes, just update the end point
      if (_strokes.last.isEmpty) {
        _strokes.last.add(DrawingPoint(
          offset: _startPoint!,
          paint: Paint()
            ..color = _currentPaint.color
            ..strokeWidth = _currentPaint.strokeWidth
            ..strokeCap = _currentPaint.strokeCap
            ..strokeJoin = _currentPaint.strokeJoin
            ..style = PaintingStyle.stroke,
        ));
      }
      
      // Update or add the end point
      if (_strokes.last.length == 1) {
        _strokes.last.add(DrawingPoint(
          offset: offset,
          paint: Paint()
            ..color = _currentPaint.color
            ..strokeWidth = _currentPaint.strokeWidth
            ..strokeCap = _currentPaint.strokeCap
            ..strokeJoin = _currentPaint.strokeJoin
            ..style = PaintingStyle.stroke,
        ));
      } else {
        _strokes.last[1] = DrawingPoint(
          offset: offset,
          paint: Paint()
            ..color = _currentPaint.color
            ..strokeWidth = _currentPaint.strokeWidth
            ..strokeCap = _currentPaint.strokeCap
            ..strokeJoin = _currentPaint.strokeJoin
            ..style = PaintingStyle.stroke,
        );
      }
      notifyListeners();
    }
  }

  void startNewStroke(Offset startPoint) {
    _strokes.add([]);
    _undoneStrokes.clear();
    _startPoint = startPoint;
    notifyListeners();
  }

  void finishShape() {
    // Convert temporary shape to permanent stroke
    if (_drawingMode != DrawingMode.freehand && 
        _strokes.isNotEmpty && 
        _strokes.last.length >= 2) {
      
      final startPoint = _strokes.last[0].offset;
      final endPoint = _strokes.last[1].offset;
      final paint = _strokes.last[0].paint;
      
      // Clear the temporary stroke
      _strokes.last.clear();
      
      // Create the final shape stroke
      switch (_drawingMode) {
        case DrawingMode.line:
          _createLineStroke(startPoint, endPoint, paint);
          break;
        case DrawingMode.rectangle:
          _createRectangleStroke(startPoint, endPoint, paint);
          break;
        case DrawingMode.circle:
          _createCircleStroke(startPoint, endPoint, paint);
          break;
        case DrawingMode.freehand:
          break; // Already handled
      }
      notifyListeners();
    }
  }

  void _createLineStroke(Offset start, Offset end, Paint paint) {
    _strokes.last.add(DrawingPoint(offset: start, paint: paint));
    _strokes.last.add(DrawingPoint(offset: end, paint: paint));
  }

  void _createRectangleStroke(Offset start, Offset end, Paint paint) {
    // Create rectangle as 4 connected lines
    final topLeft = Offset(start.dx < end.dx ? start.dx : end.dx, 
                          start.dy < end.dy ? start.dy : end.dy);
    final bottomRight = Offset(start.dx > end.dx ? start.dx : end.dx, 
                              start.dy > end.dy ? start.dy : end.dy);
    final topRight = Offset(bottomRight.dx, topLeft.dy);
    final bottomLeft = Offset(topLeft.dx, bottomRight.dy);
    
    _strokes.last.addAll([
      DrawingPoint(offset: topLeft, paint: paint),
      DrawingPoint(offset: topRight, paint: paint),
      DrawingPoint(offset: bottomRight, paint: paint),
      DrawingPoint(offset: bottomLeft, paint: paint),
      DrawingPoint(offset: topLeft, paint: paint), // Close the rectangle
    ]);
  }

  void _createCircleStroke(Offset start, Offset end, Paint paint) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final radius = (start - end).distance / 2;
    
    // Create circle as multiple points
    const int segments = 64;
    for (int i = 0; i <= segments; i++) {
      final angle = (i * 2 * math.pi) / segments;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      _strokes.last.add(DrawingPoint(offset: Offset(x, y), paint: paint));
    }
  }

  Offset? get startPoint => _startPoint;

  void clearCanvas() {
    _strokes.clear();
    _undoneStrokes.clear();
    _startPoint = null;
    notifyListeners();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      final stroke = _strokes.removeLast();
      _undoneStrokes.add(stroke);
      notifyListeners();
    }
  }

  void redo() {
    if (_undoneStrokes.isNotEmpty) {
      final stroke = _undoneStrokes.removeLast();
      _strokes.add(stroke);
      notifyListeners();
    }
  }

  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _undoneStrokes.isNotEmpty;
}

enum DrawingMode { freehand, line, rectangle, circle }