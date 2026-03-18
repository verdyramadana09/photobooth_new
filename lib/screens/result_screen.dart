import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart'; // Import package baru
import '../model/template_model.dart';
import '../services/image_service.dart';

class ResultScreen extends StatefulWidget {
  final List<XFile> images;
  final FrameTemplate template;
  const ResultScreen({super.key, required this.images, required this.template});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? finalImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  // Menggabungkan foto-foto menjadi satu gambar strip
  Future<void> _processImage() async {
    try {
      final img = await generateImage(widget.images, widget.template);
      if (mounted) setState(() => finalImage = img);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memproses gambar: $e")));
    }
  }

  // Menyimpan gambar ke galeri HP menggunakan package 'gal'
  Future<void> _saveToGallery() async {
    if (finalImage == null) return;
    
    setState(() => isSaving = true);
    try {
      // Gal otomatis akan meminta izin penyimpanan jika belum diberikan
      await Gal.putImageBytes(finalImage!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Foto berhasil disimpan ke Galeri!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Photobooth")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: finalImage == null
                  ? const CircularProgressIndicator()
                  : Image.memory(finalImage!), // Menampilkan foto yang sudah digabung
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text("KEMBALI KE AWAL"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : _saveToGallery,
                  icon: isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_alt),
                  label: Text(isSaving ? "MENYIMPAN..." : "SIMPAN FOTO"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}