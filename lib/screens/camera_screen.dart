import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../model/template_model.dart';
import '../services/camera_service.dart';
import '../../main.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final FrameTemplate template;
  const CameraScreen({super.key, required this.template});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int countdown = 0;
  List<XFile?> capturedImages = [];
  bool isReviewMode = false;
  Timer? _reviewTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    capturedImages = List.filled(widget.template.requiredPhotos, null);
    CameraService.init(cameras).then((_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _reviewTimer?.cancel(); super.dispose(); }

  void _startReviewTimer() {
    setState(() { isReviewMode = true; _secondsRemaining = 60; });
    _reviewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) setState(() => _secondsRemaining--);
      else _finishSession();
    });
  }

  Widget _previewWidget(XFile? file) {
    if (file == null) return const Icon(Icons.camera_alt, color: Colors.white, size: 35);
    return kIsWeb ? Image.network(file.path, fit: BoxFit.cover) : Image.file(File(file.path), fit: BoxFit.cover);
  }

  Future<void> _takeSinglePhoto(int index) async {
    for (int c = 3; c > 0; c--) {
      if (mounted) setState(() => countdown = c);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => countdown = 0);
    final img = await CameraService.controller!.takePicture();
    setState(() => capturedImages[index] = img);
  }

  void _finishSession() {
    _reviewTimer?.cancel();
    List<XFile> finalImages = capturedImages.whereType<XFile>().toList();
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(images: finalImages, template: widget.template)));
  }

  @override
  Widget build(BuildContext context) {
    if (CameraService.controller == null || !CameraService.controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const Color bgPurple = Color(0xFFE5B6F2); 
    const Color darkPurple = Color(0xFF7B4D8E);

    return Scaffold(
      backgroundColor: bgPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("AMBIL GAMBAR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(color: darkPurple, borderRadius: BorderRadius.circular(25)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.contain, // ANTI-ZOOM: Agar sensor kamera tidak terpotong
                                      child: SizedBox(
                                        width: CameraService.controller!.value.previewSize!.height,
                                        height: CameraService.controller!.value.previewSize!.width,
                                        child: CameraPreview(CameraService.controller!),
                                      ),
                                    ),
                                    if (countdown > 0) Center(child: Text("$countdown", style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: darkPurple, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                              onPressed: isReviewMode ? null : () async {
                                for(int i=0; i<widget.template.requiredPhotos; i++) { await _takeSinglePhoto(i); }
                                _startReviewTimer();
                              },
                              child: const Text("ambil gambar", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
                              itemCount: 6,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: isReviewMode ? () => _takeSinglePhoto(index) : null,
                                child: Container(
                                  decoration: BoxDecoration(color: darkPurple, borderRadius: BorderRadius.circular(15)),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(15), child: _previewWidget(capturedImages[index])),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: darkPurple, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                              onPressed: isReviewMode ? _finishSession : null,
                              child: const Text("lanjutkan", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}