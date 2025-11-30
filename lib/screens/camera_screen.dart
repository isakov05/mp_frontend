import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (!mounted) return;

    if (picked != null) {
      Navigator.pushNamed(
        context,
        "/prediction",
        arguments: picked.path,    // ← send file path
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: pickImage,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Open Camera"),
      ),
    );
  }
}
