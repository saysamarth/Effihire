import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// Enum to manage status message types and colors
enum StatusType { initial, inProgress, success, error }

class AntiSpoofingResult {
  final bool isCaptureEnabled;
  final String statusMessage;
  final StatusType statusType;

  AntiSpoofingResult({
    required this.isCaptureEnabled,
    required this.statusMessage,
    required this.statusType,
  });
}

// Service to handle all anti-spoofing logic
class AntiSpoofingService {
  int _consecutiveSuccesses = 0;
  final int _requiredSuccesses = 5;

  Future<AntiSpoofingResult> processImage(CameraImage cameraImage) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://face-antispoofing-api-969158963934.us-central1.run.app/predict/',
        ),
      );

      final img.Image convertedImage = img.Image.fromBytes(
        width: cameraImage.width,
        height: cameraImage.height,
        bytes: cameraImage.planes[0].bytes.buffer,
        format: img.Format.uint8,
        numChannels: 1,
      );

      final jpgBytes = img.encodeJpg(convertedImage);

      request.files.add(
        http.MultipartFile.fromBytes('file', jpgBytes, filename: 'selfie.jpg'),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('API Response: $responseBody');

      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return _handleApiResponse(decodedResponse);
      } else {
        return _handleApiError(decodedResponse);
      }
    } catch (e) {
      return AntiSpoofingResult(
        isCaptureEnabled: false,
        statusMessage: 'Error: Could not connect to server.',
        statusType: StatusType.error,
      );
    }
  }

  AntiSpoofingResult _handleApiResponse(Map<String, dynamic> response) {
    if (response.containsKey('face_status') &&
        response['face_status'] == 'real') {
      final bbox = response['bounding_box'];
      final double width = bbox['width'].toDouble();
      final double height = bbox['height'].toDouble();
      final area = width * height;
      const minArea = 40000;
      const maxArea = 90000;

      // Adjusted condition for medium resolution
      if (area >= minArea && area <= maxArea) {
        _consecutiveSuccesses++;
        if (_consecutiveSuccesses >= _requiredSuccesses) {
          return AntiSpoofingResult(
            isCaptureEnabled: true,
            statusMessage: 'Ready to capture!',
            statusType: StatusType.success,
          );
        }
        return AntiSpoofingResult(
          isCaptureEnabled: false,
          statusMessage: 'Hold your face still',
          statusType: StatusType.inProgress,
        );
      } else {
        _resetSuccessCount();
        String message;
        if (area > maxArea) {
          message = 'Move away, fit your face';
        } else {
          message = 'Come closer, fit your face';
        }
        return AntiSpoofingResult(
          isCaptureEnabled: false,
          statusMessage: message,
          statusType: StatusType.error,
        );
      }
    } else {
      _resetSuccessCount();
      return AntiSpoofingResult(
        isCaptureEnabled: false,
        statusMessage:
            response.containsKey('face_status') &&
                response['face_status'] == 'fake'
            ? 'Spoof attempt detected'
            : 'No real face detected',
        statusType: StatusType.error,
      );
    }
  }

  AntiSpoofingResult _handleApiError(Map<String, dynamic> response) {
    _resetSuccessCount();
    final errorMessage = response['error'] ?? 'An unknown error occurred';
    return AntiSpoofingResult(
      isCaptureEnabled: false,
      statusMessage: errorMessage,
      statusType: StatusType.error,
    );
  }

  void _resetSuccessCount() {
    if (_consecutiveSuccesses > 0) {
      _consecutiveSuccesses = 0;
    }
  }

  void reset() {
    _resetSuccessCount();
  }
}
