import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/template_model.dart';

Future<Uint8List> generateImage(List<XFile> images, FrameTemplate template) async {
  double canvasWidth = 1200;
  double canvasHeight = 1800;
  List<Rect> photoSlots = [];

  if (template.layout == 'grid_3x2') {
    canvasWidth = 1200; canvasHeight = 1800;
    photoSlots = [
      const Rect.fromLTWH(120, 150, 440, 450), const Rect.fromLTWH(120, 620, 440, 450), const Rect.fromLTWH(120, 1080, 440, 450),
      const Rect.fromLTWH(640, 150, 440, 450), const Rect.fromLTWH(640, 620, 440, 450), const Rect.fromLTWH(640, 1080, 440, 450),
    ];
  } else {
    canvasWidth = 600; canvasHeight = 1800;
    photoSlots = [
      const Rect.fromLTWH(50, 50, 500, 380), const Rect.fromLTWH(50, 480, 500, 380),
      const Rect.fromLTWH(50, 910, 500, 380), const Rect.fromLTWH(50, 1340, 500, 380),
    ];
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();

  canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), paint..color = Colors.white);

  for (int i = 0; i < images.length && i < photoSlots.length; i++) {
    Uint8List imgBytes = await images[i].readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
    final ui.Image photo = (await codec.getNextFrame()).image;

    final Size imageSize = Size(photo.width.toDouble(), photo.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.cover, imageSize, photoSlots[i].size);
    final Rect inputRect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputRect = Alignment.center.inscribe(sizes.destination, photoSlots[i]);

    canvas.drawImageRect(photo, inputRect, outputRect, paint);
  }

  ui.Image? frameImage;
  if (template.type == 'asset') {
    final ByteData data = await rootBundle.load(template.path);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    frameImage = (await codec.getNextFrame()).image;
  } else {
    Uint8List frameBytes;
    if (kIsWeb) {
      final response = await http.get(Uri.parse(template.path));
      frameBytes = response.bodyBytes;
    } else {
      frameBytes = await File(template.path).readAsBytes();
    }
    final ui.Codec codec = await ui.instantiateImageCodec(frameBytes);
    frameImage = (await codec.getNextFrame()).image;
  }

  if (frameImage != null) {
    canvas.drawImageRect(frameImage, Rect.fromLTWH(0, 0, frameImage.width.toDouble(), frameImage.height.toDouble()), Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), paint);
  }

  final byteData = await (await recorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt())).toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}