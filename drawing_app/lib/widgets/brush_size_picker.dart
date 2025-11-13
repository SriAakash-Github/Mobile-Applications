import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawing_app/providers/drawing_provider.dart';

class BrushSizePicker extends StatelessWidget {
  const BrushSizePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> sizes = const [2.0, 5.0, 10.0, 15.0, 20.0];

    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: sizes.map((size) {
                return GestureDetector(
                  onTap: () {
                    drawingProvider.setCurrentStrokeWidth(size);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    width: size * 2,
                    height: size * 2,
                    decoration: BoxDecoration(
                      color: drawingProvider.currentStrokeWidth == size
                          ? drawingProvider.currentColor
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: drawingProvider.currentStrokeWidth == size
                            ? Colors.white
                            : Colors.grey[600]!,
                        width: 2,
                      ),
                    ),
                    child: drawingProvider.currentStrokeWidth == size
                        ? null
                        : Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}