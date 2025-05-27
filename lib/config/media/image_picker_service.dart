import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

      bool hasPermission = await _checkPermissions(source);
      if (!hasPermission) {
        _showErrorSnackBar(context, 'Permission denied. Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission in settings.');
        return null;
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
      // Check storage permission
      bool hasPermission = await _checkPermissions(ImageSource.gallery);
      if (!hasPermission) {
        _showErrorSnackBar(context, 'Permission denied. Please grant storage permission in settings.');
        return [];
      }

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

  Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      return status.isGranted;
    } else {
      // For gallery access
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      } else {
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        return status.isGranted;
      }
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
              subtitle: 'Take a new photo',
              source: ImageSource.camera,
            ),
            const SizedBox(height: 12),
            _buildSourceOption(
              context: context,
              icon: Icons.photo_library,
              label: 'Gallery',
              subtitle: 'Choose from gallery',
              source: ImageSource.gallery,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
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

  String getImageSizeFormatted(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
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

      // Use image_picker to re-compress the image
      final XFile compressedFile = XFile(file.path);
      
      // For now, return the original file as compression would require additional packages
      // You can integrate packages like flutter_image_compress for better compression
      return file;
    } catch (e) {
      _showErrorSnackBar(context, 'Error compressing image: $e');
      return file;
    }
  }

  // Additional utility methods
  Future<bool> deleteImage(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String getFileName(File file) {
    return file.path.split('/').last;
  }

  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  Future<Map<String, dynamic>> getImageInfo(File file) async {
    try {
      final stat = await file.stat();
      return {
        'name': getFileName(file),
        'size': getImageSizeFormatted(file),
        'sizeInBytes': file.lengthSync(),
        'sizeInMB': getImageSizeInMB(file),
        'extension': getFileExtension(file),
        'path': file.path,
        'lastModified': stat.modified,
        'isValid': isValidImage(file),
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  // Show image preview dialog
  Future<void> showImagePreview(BuildContext context, File imageFile) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Implement share functionality if needed
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Batch operations
  Future<List<File>> compressMultipleImages(
    BuildContext context,
    List<File> files, {
    double maxSizeInMB = 5.0,
    int quality = 70,
  }) async {
    List<File> compressedFiles = [];
    
    for (File file in files) {
      File? compressed = await compressImageIfNeeded(
        context,
        file,
        maxSizeInMB: maxSizeInMB,
        quality: quality,
      );
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }
    
    return compressedFiles;
  }

  Future<bool> deleteMultipleImages(List<File> files) async {
    try {
      for (File file in files) {
        if (await file.exists()) {
          await file.delete();
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validation methods
  bool validateImageSize(File file, {double maxSizeInMB = 10.0}) {
    return getImageSizeInMB(file) <= maxSizeInMB;
  }

  bool validateImageDimensions(File file, {int? maxWidth, int? maxHeight}) {
    // This would require additional packages like flutter_native_image
    // For now, return true as a placeholder
    return true;
  }

  List<String> validateImages(List<File> files, {
    double maxSizeInMB = 10.0,
    int? maxWidth,
    int? maxHeight,
  }) {
    List<String> errors = [];
    
    for (int i = 0; i < files.length; i++) {
      File file = files[i];
      String fileName = getFileName(file);
      
      if (!isValidImage(file)) {
        errors.add('$fileName: Invalid image format');
      }
      
      if (!validateImageSize(file, maxSizeInMB: maxSizeInMB)) {
        errors.add('$fileName: File size exceeds ${maxSizeInMB}MB');
      }
      
      // Add dimension validation if needed
      if (maxWidth != null || maxHeight != null) {
        if (!validateImageDimensions(file, maxWidth: maxWidth, maxHeight: maxHeight)) {
          errors.add('$fileName: Image dimensions too large');
        }
      }
    }
    
    return errors;
  }
}