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
  int _secondsRemaining = 30; // Timer 30 detik sesuai permintaan

  @override
  void initState() {
    super.initState();
    capturedImages = List.filled(widget.template.requiredPhotos, null);
    CameraService.init(cameras).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
    super.dispose();
  }

  // --- LOGIKA TIMER 30 DETIK ---
  void _startReviewTimer() {
    setState(() {
      isReviewMode = true;
      _secondsRemaining = 30;
    });
    _reviewTimer?.cancel();
    _reviewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        _finishSession(); // Otomatis lanjut jika waktu habis
      }
    });
  }

  // --- LOGIKA AMBIL FOTO (SINGLE / SEQUENCE) ---
  Future<void> _takePhoto(int index) async {
    for (int c = 3; c > 0; c--) {
      if (mounted) setState(() => countdown = c);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => countdown = 0);

    try {
      final img = await CameraService.controller!.takePicture();
      setState(() => capturedImages[index] = img);
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> _startSequence() async {
    for (int i = 0; i < widget.template.requiredPhotos; i++) {
      await _takePhoto(i);
    }
    _startReviewTimer();
  }

  void _finishSession() {
    _reviewTimer?.cancel();
    List<XFile> finalImages = capturedImages.whereType<XFile>().toList();
    if (finalImages.length == widget.template.requiredPhotos) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(images: finalImages, template: widget.template),
        ),
      );
    }
  }

  Widget _previewWidget(XFile? file) {
    if (file == null) {
      return const Icon(Icons.camera_alt, color: Colors.white, size: 30);
    }
    return kIsWeb
        ? Image.network(file.path, fit: BoxFit.cover)
        : Image.file(File(file.path), fit: BoxFit.cover);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AMBIL GAMBAR",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (isReviewMode)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                      child: Text("Sisa Waktu: $_secondsRemaining",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    // --- KAMERA (KIRI) ---
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
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                        width: CameraService.controller!.value.previewSize!.height,
                                        height: CameraService.controller!.value.previewSize!.width,
                                        child: CameraPreview(CameraService.controller!),
                                      ),
                                    ),
                                    if (countdown > 0)
                                      Center(
                                          child: Text("$countdown",
                                              style: const TextStyle(
                                                  fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!isReviewMode)
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: darkPurple,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 12)),
                                onPressed: _startSequence,
                                child: const Text("Mulai Ambil Foto", style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                            )
                          else
                            const Text("Klik foto di samping untuk ambil ulang (Retake)",
                                style: TextStyle(color: darkPurple, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // --- PREVIEW GRID & RETAKE (KANAN) ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                              itemCount: widget.template.requiredPhotos,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: isReviewMode ? () => _takePhoto(index) : null,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(color: darkPurple, borderRadius: BorderRadius.circular(15)),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: _previewWidget(capturedImages[index])),
                                    ),
                                    if (isReviewMode)
                                      Positioned(
                                        bottom: 5,
                                        right: 5,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white.withOpacity(0.8),
                                          child: const Icon(Icons.refresh, size: 15, color: darkPurple),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isReviewMode)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: darkPurple,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 15)),
                                onPressed: _finishSession,
                                child: const Text("LANJUTKAN", style: TextStyle(color: Colors.white, fontSize: 18)),
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