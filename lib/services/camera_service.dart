import 'package:camera/camera.dart';

class CameraService {
  static CameraController? controller;

  static Future<void> init(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) return;
    controller = CameraController(
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first),
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  static void dispose() {
    controller?.dispose();
    controller = null;
  }
}