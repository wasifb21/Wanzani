// upload_image_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

class UploadImageScreen extends StatefulWidget {
  final String docType;
  final String userId;

  const UploadImageScreen(
      {super.key, required this.docType, this.userId = 'testUser'});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _imageFile;
  String? _base64Image;
  bool _uploading = false;
  final _picker = ImagePicker();
  final dbRef = FirebaseDatabase.instance.ref();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _uploading = true;
      });
      final bytes = await File(picked.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      await _uploadBase64(base64Str);
    }
  }

  Future<void> _uploadBase64(String base64Str) async {
    try {
      await dbRef
          .child('verifications/${widget.userId}/${widget.docType}')
          .set(base64Str);
      if (mounted) {
        setState(() {
          _base64Image = base64Str;
          _uploading = false;
        });
        Navigator.pop(context, base64Str);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? previewWidget;
    if (_imageFile != null) {
      previewWidget = Image.file(_imageFile!, height: 200);
    } else if (_base64Image != null) {
      previewWidget = Image.memory(base64Decode(_base64Image!), height: 200);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Select ${widget.docType} Image')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: _imageFile == null && _base64Image == null
              ? (_uploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Select Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (previewWidget != null) previewWidget,
                    const SizedBox(height: 16),
                    if (_uploading) const CircularProgressIndicator(),
                    if (!_uploading)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Change Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
