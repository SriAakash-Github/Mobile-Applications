import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawing_app/providers/drawing_provider.dart';
import 'package:drawing_app/widgets/drawing_canvas.dart';
import 'package:drawing_app/widgets/drawing_toolbar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DrawingProvider(),
      child: const DrawingApp(),
    ),
  );
}

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whiteboard Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const DrawingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DrawingHomePage extends StatelessWidget {
  const DrawingHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final previewContainer = GlobalKey();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard Drawing App'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              // Open color picker or settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: previewContainer,
              child: Container(
                color: Colors.white,
                child: const DrawingCanvas(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DrawingToolbar(previewContainer: previewContainer),
    );
  }
}