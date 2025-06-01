import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

enum DocumentScanType { document, selfie }

class DocumentScannerService {
  static final DocumentScannerService _instance = DocumentScannerService._internal();
  factory DocumentScannerService() => _instance;
  DocumentScannerService._internal();

  final ImagePicker _picker = ImagePicker();
  DocumentScanner? _documentScanner;

  // Initialize the document scanner
  Future<void> initializeScanner() async {
    _documentScanner ??= DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.filter,
          pageLimit: 1,
          isGalleryImport: true,
        ),
      );
  }

  Future<File?> scanDocument({
    required BuildContext context,
    DocumentScanType scanType = DocumentScanType.document,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    int imageQuality = 90,
  }) async {
    try {
      if (scanType == DocumentScanType.selfie) {
        return await _captureRegularImage(
          context: context,
          maxWidth: maxWidth ?? 1024,
          maxHeight: maxHeight ?? 1024,
          imageQuality: imageQuality,
        );
      }

      bool hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar(context, 'Camera permission is required to scan documents.');
        return null;
      }

      await initializeScanner();
      
      if (_documentScanner == null) {
        _showErrorSnackBar(context, 'Failed to initialize document scanner.');
        return null;
      }

      // Start document scanning
      final DocumentScanningResult result = await _documentScanner!.scanDocument();
      
      if (result.images.isNotEmpty) {
        // Get the first scanned image
        final String imagePath = result.images.first;
        final File scannedFile = File(imagePath);
        
        if (await scannedFile.exists()) {
          return scannedFile;
        } else {
          _showErrorSnackBar(context, 'Scanned document file not found.');
          return null;
        }
      } else {
        // User cancelled or no document was scanned
        return null;
      }
    } catch (e) {
      if (e.toString().contains('cancel')) {
        // User cancelled - don't show error
        return null;
      }
      _showErrorSnackBar(context, 'Error scanning document: ${e.toString()}');
      return null;
    }
  }

  // Fallback method for selfies using regular camera
  Future<File?> _captureRegularImage({
    required BuildContext context,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 90,
  }) async {
    try {
      bool hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar(context, 'Camera permission is required.');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.front, // Use front camera for selfies
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      _showErrorSnackBar(context, 'Error capturing image: $e');
      return null;
    }
  }

  // Check camera permission
  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Utility methods (keeping the useful ones from the original service)
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

  String getFileName(File file) {
    return file.path.split('/').last;
  }

  // Delete image file
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

  // Validate image size
  bool validateImageSize(File file, {double maxSizeInMB = 10.0}) {
    return getImageSizeInMB(file) <= maxSizeInMB;
  }

  // Get image information
  Future<Map<String, dynamic>> getImageInfo(File file) async {
    try {
      final stat = await file.stat();
      return {
        'name': getFileName(file),
        'size': getImageSizeFormatted(file),
        'sizeInBytes': file.lengthSync(),
        'sizeInMB': getImageSizeInMB(file),
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

  void dispose() {
    _documentScanner?.close();
    _documentScanner = null;
  }
}