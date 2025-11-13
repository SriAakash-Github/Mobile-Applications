import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawing_app/providers/drawing_provider.dart';
import 'package:drawing_app/widgets/color_picker.dart';
import 'package:drawing_app/widgets/brush_size_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class DrawingToolbar extends StatelessWidget {
  final GlobalKey previewContainer;

  const DrawingToolbar({super.key, required this.previewContainer});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drawing Mode Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModeButton(
                      context,
                      Icons.edit,
                      DrawingMode.freehand,
                      drawingProvider.drawingMode == DrawingMode.freehand,
                    ),
                    _buildModeButton(
                      context,
                      Icons.show_chart,
                      DrawingMode.line,
                      drawingProvider.drawingMode == DrawingMode.line,
                    ),
                    _buildModeButton(
                      context,
                      Icons.rectangle_outlined,
                      DrawingMode.rectangle,
                      drawingProvider.drawingMode == DrawingMode.rectangle,
                    ),
                    _buildModeButton(
                      context,
                      Icons.circle_outlined,
                      DrawingMode.circle,
                      drawingProvider.drawingMode == DrawingMode.circle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Color Picker
              const ColorPicker(),
              const SizedBox(height: 16),
              
              // Brush Size Picker
              const BrushSizePicker(),
              const SizedBox(height: 16),
              
              // Action Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Undo Button
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.white),
                      onPressed: drawingProvider.canUndo
                          ? () => drawingProvider.undo()
                          : null,
                    ),
                    
                    // Redo Button
                    IconButton(
                      icon: const Icon(Icons.redo, color: Colors.white),
                      onPressed: drawingProvider.canRedo
                          ? () => drawingProvider.redo()
                          : null,
                    ),
                    
                    // Clear Button
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () => drawingProvider.clearCanvas(),
                    ),
                    
                    // Save Button
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: () => _saveDrawing(context, previewContainer),
                    ),
                    
                    // Eraser Button
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                      onPressed: () => drawingProvider.setCurrentColor(Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeButton(BuildContext context, IconData icon, DrawingMode mode, bool isSelected) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, child) {
        return IconButton(
          icon: Icon(icon, 
            color: isSelected ? Colors.blue : Colors.white,
          ),
          onPressed: () => drawingProvider.setDrawingMode(mode),
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  _saveDrawing(BuildContext context, GlobalKey previewContainer) async {
    try {
      RenderRepaintBoundary boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = File(imagePath);
      await file.writeAsBytes(pngBytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drawing saved to: $imagePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save drawing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}