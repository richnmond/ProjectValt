// tools/generate_assets.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AssetGenerator {
  static Future<void> generateAppLogo() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    
    // Background
    paint.color = const Color(0xFF6C63FF);
    final rect = Rect.fromLTWH(0, 0, 512, 512);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(100)),
      paint,
    );
    
    // Folder icon
    paint.color = Colors.white;
    final path = Path()
      ..moveTo(150, 200)
      ..lineTo(200, 200)
      ..lineTo(230, 230)
      ..lineTo(362, 230)
      ..lineTo(362, 330)
      ..lineTo(150, 330)
      ..close();
    canvas.drawPath(path, paint);
    
    // "PV" Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'PV',
        style: TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(200, 350));
    
    final image = await recorder.endRecording().toImage(512, 512);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    final appDir = Directory('../frontend/assets/images');
    await appDir.create(recursive: true);
    await File('${appDir.path}/app_logo.png').writeAsBytes(bytes!.buffer.asUint8List());
    print('Generated app_logo.png');
  }
  
  static Future<void> generatePlaceholderImages() async {
    final appDir = Directory('../frontend/assets/images');
    await appDir.create(recursive: true);
    
    // Generate empty state image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    
    // Empty folder icon
    paint.color = Colors.grey[300]!;
    final path = Path()
      ..moveTo(150, 200)
      ..lineTo(200, 200)
      ..lineTo(230, 230)
      ..lineTo(362, 230)
      ..lineTo(362, 330)
      ..lineTo(150, 330)
      ..close();
    canvas.drawPath(path, paint);
    
    // Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No projects yet',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(150, 380));
    
    final image = await recorder.endRecording().toImage(512, 512);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('${appDir.path}/empty_state.png').writeAsBytes(bytes!.buffer.asUint8List());
    print('Generated empty_state.png');
  }
}

void main() async {
  await AssetGenerator.generateAppLogo();
  await AssetGenerator.generatePlaceholderImages();
  print('All assets generated successfully!');
}