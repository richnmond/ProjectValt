// tools/bin/generate_assets.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetGenerator {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4A45B4);
  
  static Future<Uint8List> generateAppLogo() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(512, 512);
    
    // Background gradient
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(size.width, size.height),
      [primaryColor, secondaryColor],
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(100),
      ),
      Paint()..shader = gradient,
    );
    
    // Folder icon
    final folderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final folderPath = Path()
      ..moveTo(150, 180)
      ..quadraticBezierTo(180, 150, 210, 180)
      ..lineTo(362, 180)
      ..lineTo(362, 330)
      ..lineTo(150, 330)
      ..close();
    canvas.drawPath(folderPath, folderPaint);
    
    // "PV" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'PV',
        style: TextStyle(
          color: Colors.white,
          fontSize: 72,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(200, 360));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  static Future<void> generateAllAssets() async {
    final baseDir = Directory('../frontend/assets');
    await baseDir.create(recursive: true);
    
    final imagesDir = Directory('${baseDir.path}/images');
    await imagesDir.create(recursive: true);
    
    // Generate app logo
    final logoBytes = await generateAppLogo();
    await File('${imagesDir.path}/app_logo.png').writeAsBytes(logoBytes);
    print('✅ Generated app_logo.png');
    
    // Generate placeholder images
    final placeholderBytes = await generatePlaceholderImage();
    await File('${imagesDir.path}/empty_state.png').writeAsBytes(placeholderBytes);
    print('✅ Generated empty_state.png');
    
    print('🎉 All assets generated successfully!');
  }
  
  static Future<Uint8List> generatePlaceholderImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(512, 512);
    
    // Background
    final backgroundPaint = Paint()..color = Colors.grey[100]!;
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    
    // Folder icon
    final folderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;
    
    final folderPath = Path()
      ..moveTo(200, 200)
      ..lineTo(312, 200)
      ..lineTo(330, 230)
      ..lineTo(362, 230)
      ..lineTo(362, 330)
      ..lineTo(150, 330)
      ..close();
    canvas.drawPath(folderPath, folderPaint);
    
    // Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No projects yet',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 24,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(180, 380));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AssetGenerator.generateAllAssets();
}