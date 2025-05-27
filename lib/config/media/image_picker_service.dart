import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum ImageSourceType { camera, gallery, both }

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    required BuildContext context,
    ImageSourceType sourceType = ImageSourceType.both,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      ImageSource? source;

      if (sourceType == ImageSourceType.both) {
        source = await _showImageSourceDialog(context);
        if (source == null) return null;
      } else {
        source = sourceType == ImageSourceType.camera 
            ? ImageSource.camera 
            : ImageSource.gallery;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      _showErrorSnackBar(context, 'Error picking image: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages({
    required BuildContext context,
    int maxImages = 10,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (images.length > maxImages) {
        _showErrorSnackBar(context, 'Maximum $maxImages images allowed');
        return images.take(maxImages).map((xFile) => File(xFile.path)).toList();
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      _showErrorSnackBar(context, 'Error picking images: $e');
      return [];
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Image Source',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B3E86),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceOption(
              context: context,
              icon: Icons.camera_alt,
              label: 'Camera',
              source: ImageSource.camera,
            ),
            const SizedBox(height: 12),
            _buildSourceOption(
              context: context,
              icon: Icons.photo_library,
              label: 'Gallery',
              source: ImageSource.gallery,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(source),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B3E86).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF5B3E86),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool isValidImage(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final fileName = file.path.toLowerCase();
    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  double getImageSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  Future<File?> compressImageIfNeeded(
    BuildContext context,
    File file, {
    double maxSizeInMB = 5.0,
    int quality = 70,
  }) async {
    try {
      if (getImageSizeInMB(file) <= maxSizeInMB) {
        return file;
      }

      final XFile? compressedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );
      return compressedFile != null ? File(compressedFile.path) : file;
    } catch (e) {
      _showErrorSnackBar(context, 'Error compressing image: $e');
      return file;
    }
  }
}