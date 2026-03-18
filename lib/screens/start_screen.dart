import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/template_model.dart';
import '../utils/constants.dart';
import 'frame_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<FrameTemplate> customTemplates = [];

  Future<String?> _askForLayout(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Jenis Layout Frame"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.view_headline),
                title: const Text("Strip 4 Foto (1x4)"),
                onTap: () => Navigator.pop(context, "strip_1x4"),
              ),
              ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text("Strip 3 Foto (1x3)"),
                onTap: () => Navigator.pop(context, "strip_1x3"),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text("Kertas 4R (4 Foto / 2x2)"),
                onTap: () => Navigator.pop(context, "grid_2x2"),
              ),
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text("Kertas 4R (6 Foto Berbeda)"),
                onTap: () => Navigator.pop(context, "grid_3x2"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickTemplate() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      if (!mounted) return;
      final selectedLayout = await _askForLayout(context);
      
      if (selectedLayout != null) {
        // Tentukan jumlah jepretan kamera berdasarkan pilihan layout
        int photos = 4; // Default
        if (selectedLayout == 'strip_1x3') photos = 3;
        if (selectedLayout == 'grid_3x2') photos = 6; // <-- Sekarang jepret 6 kali!

        setState(() {
          customTemplates.add(FrameTemplate(
            path: file.path, 
            type: 'file', 
            layout: selectedLayout, 
            requiredPhotos: photos // Simpan jumlah jepretannya
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FrameScreen(userTemplates: customTemplates))),
              child: const Text("MULAI", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20)),
              onPressed: _pickTemplate,
              icon: const Icon(Icons.upload),
              label: const Text("UPLOAD TEMPLATE", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}