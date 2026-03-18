import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../result/result_screen.dart';
import '../../model/template_model.dart';

class PreviewScreen extends StatelessWidget {
  final List<XFile> images;
  final FrameTemplate template;

  const PreviewScreen({
    super.key,
    required this.images,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text("Preview"),

          Expanded(
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (_, i) => Image.file(
                File(images[i].path),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    images: images,
                    template: template,
                  ),
                ),
              );
            },
            child: const Text("Lanjut"),
          )
        ],
      ),
    );
  }
}