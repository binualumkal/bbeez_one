import 'dart:io';

// Uses file_picker plugin which invokes the platform picker and avoids broad storage permissions.
// Add to pubspec.yaml: file_picker: ^5.3.0

import 'package:file_picker/file_picker.dart';

class PhotoPicker {
  /// Opens the system picker and returns a File for the selected image, or null if cancelled.
  static Future<File?> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }
}

// Usage example:
// final file = await PhotoPicker.pickImage();
// if (file != null) { /* use the image file */ }
