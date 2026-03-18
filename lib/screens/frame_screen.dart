import 'dart:io';
import 'package:flutter/foundation.dart'; // Wajib untuk kIsWeb
import 'package:flutter/material.dart';
import '../model/template_model.dart';
import 'camera_screen.dart';

class FrameScreen extends StatefulWidget {
  final List<FrameTemplate> userTemplates;
  const FrameScreen({super.key, required this.userTemplates});

  @override
  State<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends State<FrameScreen> {
  String selectedFilter = 'all'; 

  @override
  Widget build(BuildContext context) {
    // Gabungkan frame bawaan dan upload-an user
    final List<FrameTemplate> allFrames = [
      FrameTemplate(
        path: "assets/frames/default_3x2.png", 
        type: "asset", 
        layout: "grid_3x2", 
        requiredPhotos: 6
      ),
      FrameTemplate(
        path: "assets/frames/default.png", 
        type: "asset", 
        layout: "strip_1x4", 
        requiredPhotos: 4
      ),
      ...widget.userTemplates,
    ];

    // Filter list frame berdasarkan tombol yang ditekan
    final filteredFrames = selectedFilter == 'all' 
        ? allFrames 
        : allFrames.where((f) => f.layout == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE5B6F2), // Warna ungu muda konsisten
      appBar: AppBar(
        title: const Text("PILIH FRAME", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- TOMBOL FILTER DI ATAS ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterButton("Semua", "all"),
                _buildFilterButton("1x3", "strip_1x3"),
                _buildFilterButton("1x4", "strip_1x4"),
                _buildFilterButton("2x2", "grid_2x2"),
                _buildFilterButton("3x2", "grid_3x2"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- CAROUSEL FRAME (HORIZONTAL LIST) ---
          Expanded(
            child: filteredFrames.isEmpty 
              ? const Center(child: Text("Belum ada frame untuk kategori ini"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  itemCount: filteredFrames.length,
                  itemBuilder: (context, index) {
                    final frame = filteredFrames[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => CameraScreen(template: frame))
                        );
                      },
                      child: Container(
                        width: 250, 
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _buildFrameImage(frame), // Menggunakan helper agar support Web
                        ),
                      ),
                    );
                  },
                ),
          ),

          // --- TOMBOL LANJUTKAN ---
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B4D8E), // Ungu tua
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                // Logika otomatis pilih frame pertama jika ada
                if (filteredFrames.isNotEmpty) {
                   Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => CameraScreen(template: filteredFrames[0]))
                  );
                }
              }, 
              child: const Text("lanjutkan", style: TextStyle(color: Colors.white))
            ),
          ),
        ],
      ),
    );
  }

  // HELPER UNTUK MENAMPILKAN GAMBAR (Mencegah error di Web)
  Widget _buildFrameImage(FrameTemplate frame) {
    if (frame.type == "asset") {
      return Image.asset(frame.path, fit: BoxFit.contain);
    } else {
      // Jika di Web gunakan Image.network, jika di Mobile gunakan Image.file
      return kIsWeb 
          ? Image.network(frame.path, fit: BoxFit.contain) 
          : Image.file(File(frame.path), fit: BoxFit.contain);
    }
  }

  // Helper widget untuk membuat tombol filter
  Widget _buildFilterButton(String label, String value) {
    bool isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF7B4D8E) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => setState(() => selectedFilter = value),
        child: Text(label),
      ),
    );
  }
}