// tools/create_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

Future<Uint8List> createLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(512, 512);
  
  // Background
  final gradient = ui.Gradient.linear(
    Offset(0, 0),
    Offset(size.width, size.height),
    [Color(0xFF6C63FF), Color(0xFF4A45B4)],
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(100),
    ),
    Paint()..shader = gradient,
  );
  
  // Folder icon
  final folderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  final folderPath = Path()
    ..moveTo(150, 180)
    ..quadraticBezierTo(180, 160, 210, 180)
    ..lineTo(362, 180)
    ..lineTo(362, 330)
    ..lineTo(150, 330)
    ..close();
  canvas.drawPath(folderPath, folderPaint);
  
  // Inner folder
  final innerFolderPaint = Paint()
    ..color = Color(0xFF6C63FF)
    ..style = PaintingStyle.fill;
  final innerPath = Path()
    ..moveTo(170, 220)
    ..lineTo(342, 220)
    ..lineTo(342, 310)
    ..lineTo(170, 310)
    ..close();
  canvas.drawPath(innerPath, innerFolderPaint);
  
  // "PV" text
  final textPainter = TextPainter(
    text: TextSpan(
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

void main() async {
  final logoBytes = await createLogo();
  final file = File('../frontend/assets/images/app_logo.png');
  await file.create(recursive: true);
  await file.writeAsBytes(logoBytes);
  print('Logo created successfully!');
}