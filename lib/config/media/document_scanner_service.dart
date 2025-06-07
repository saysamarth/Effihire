import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DocumentScannerService {
  static final DocumentScannerService _instance = DocumentScannerService._internal();
  factory DocumentScannerService() => _instance;
  DocumentScannerService._internal();

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
  }) async {
    try {
      bool hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        showSnackBar(context, 'Camera permission is required to scan documents.', isError: true);
        return null;
      }

      await initializeScanner();
      
      if (_documentScanner == null) {
        showSnackBar(context, 'Failed to initialize document scanner.', isError: true);
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
          showSnackBar(context, 'Scanned document file not found.', isError: true);
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
      showSnackBar(context, 'Error scanning document: ${e.toString()}', isError: true);
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

  // Show snackbar (unified method for both success and error)
  void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // Utility methods for file handling
  bool isValidImage(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final fileName = file.path.toLowerCase();
    return validExtensions.any((ext) => fileName.endsWith(ext));
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

  void dispose() {
    _documentScanner?.close();
    _documentScanner = null;
  }
}