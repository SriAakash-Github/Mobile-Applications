import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawing_app/providers/drawing_provider.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, child) {
        return Listener(
          onPointerDown: (details) {
            drawingProvider.startNewStroke(details.localPosition);
            drawingProvider.addPoint(details.localPosition);
          },
          onPointerMove: (details) {
            drawingProvider.addPoint(details.localPosition);
          },
          onPointerUp: (details) {
            if (drawingProvider.drawingMode != DrawingMode.freehand) {
              drawingProvider.finishShape();
            }
          },
          child: CustomPaint(
            painter: DrawingPainter(drawingProvider),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final DrawingProvider drawingProvider;

  DrawingPainter(this.drawingProvider) : super(repaint: drawingProvider);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all completed strokes
    for (int s = 0; s < drawingProvider.strokes.length; s++) {
      var stroke = drawingProvider.strokes[s];
      if (stroke.isEmpty) continue;
      
      bool isCurrentStroke = (s == drawingProvider.strokes.length - 1);
      
      // For freehand drawing or completed strokes
      if (drawingProvider.drawingMode == DrawingMode.freehand || !isCurrentStroke) {
        if (stroke.length == 1) {
          // Draw a single dot
          canvas.drawCircle(
            stroke.first.offset,
            stroke.first.paint.strokeWidth / 2,
            stroke.first.paint,
          );
        } else if (stroke.length >= 2) {
          // Draw lines between consecutive points (like MS Paint)
          for (int i = 0; i < stroke.length - 1; i++) {
            canvas.drawLine(
              stroke[i].offset,
              stroke[i + 1].offset,
              stroke[i].paint,
            );
          }
        }
      }
      
      // Draw preview for current shape being drawn
      if (isCurrentStroke && 
          drawingProvider.drawingMode != DrawingMode.freehand && 
          stroke.length >= 2) {
        
        final startPoint = stroke[0].offset;
        final endPoint = stroke[1].offset;
        final paint = Paint()
          ..color = drawingProvider.currentColor
          ..strokeWidth = drawingProvider.currentStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        
        // Draw preview shape
        switch (drawingProvider.drawingMode) {
          case DrawingMode.line:
            canvas.drawLine(startPoint, endPoint, paint);
            break;
          case DrawingMode.rectangle:
            final rect = Rect.fromPoints(startPoint, endPoint);
            canvas.drawRect(rect, paint);
            break;
          case DrawingMode.circle:
            final center = Offset(
              (startPoint.dx + endPoint.dx) / 2,
              (startPoint.dy + endPoint.dy) / 2,
            );
            final radius = (startPoint - endPoint).distance / 2;
            canvas.drawCircle(center, radius, paint);
            break;
          case DrawingMode.freehand:
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}