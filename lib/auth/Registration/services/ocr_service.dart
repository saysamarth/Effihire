import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ocr_model.dart';

class OCRService {
  static const String _baseUrl =
      "https://ekyc-backend-969158963934.us-central1.run.app";
  //static const String _debugServerUrl = "http://192.168.0.102:5003";
  static const Duration _timeoutDuration = Duration(seconds: 30);

  // Convert image file to base64 and send to debug server
  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      //await _sendToDebugServer(base64String);
      return base64String;
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  // Send base64 string to debug server on PC
  // Future<void> _sendToDebugServer(String base64String) async {
  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('$_debugServerUrl/decode-image'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: json.encode({'base64_string': base64String}),
  //         )
  //         .timeout(Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final result = json.decode(response.body);
  //       print(
  //         'Image sent to debug server successfully, saved as: \\${result['filename']}',
  //       );
  //     }
  //   } catch (e) {
  //     // Silent fail
  //     print('Failed to send image to debug server: $e');
  //   }
  // }

  // Generic method to make API calls with proper error handling
  Future<Map<String, dynamic>> _makeAPICall({
    required String endpoint,
    required String base64Image,
    required String bodyKey,
  }) async {
    try {
      print('✅ Making API call to: $_baseUrl/$endpoint');
      final requestBody = json.encode({bodyKey: base64Image});
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Parsed API response for $endpoint:');
        print(const JsonEncoder.withIndent('  ').convert(jsonResponse));
        return jsonResponse;
      } else {
        throw Exception(
          'API call failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      }
      throw Exception('API call failed: $e');
    }
  }

  // Process Aadhaar Front
  Future<OCRResult> processAadhaarFront(File imageFile) async {
    try {
      final base64Image = await _convertImageToBase64(imageFile);
      final jsonResponse = await _makeAPICall(
        endpoint: 'GetAadharFront',
        base64Image: base64Image,
        bodyKey: 'front',
      );

      final status = jsonResponse['status']?.toString() ?? 'failure';

      if (status == 'success') {
        final aadhaar = _parseAadhaarResponse(jsonResponse);
        return OCRResult.success(DocumentResponse(aadhaar: aadhaar));
      } else {
        return OCRResult.failure('Please upload a valid Aadhaar card');
      }
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        return OCRResult.networkError('Network issue, please try again');
      }
      return OCRResult.error('Processing failed, please try again');
    }
  }

  // Process Aadhaar Back
  Future<OCRResult> processAadhaarBack(File imageFile) async {
    try {
      final base64Image = await _convertImageToBase64(imageFile);
      final jsonResponse = await _makeAPICall(
        endpoint: 'GetAadharBack',
        base64Image: base64Image,
        bodyKey: 'back',
      );

      final status = jsonResponse['status']?.toString() ?? 'failure';

      if (status == 'success') {
        final aadhaar = _parseAadhaarResponse(jsonResponse);
        return OCRResult.success(DocumentResponse(aadhaar: aadhaar));
      } else {
        return OCRResult.failure('Please upload a valid Aadhaar card');
      }
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        return OCRResult.networkError('Network issue, please try again');
      }
      return OCRResult.error('Processing failed, please try again');
    }
  }

  // Process PAN Card
  Future<OCRResult> processPAN(File imageFile) async {
    try {
      final base64Image = await _convertImageToBase64(imageFile);
      final jsonResponse = await _makeAPICall(
        endpoint: 'GetPAN',
        base64Image: base64Image,
        bodyKey: 'pan',
      );

      final status = jsonResponse['status']?.toString() ?? 'failure';

      if (status == 'success') {
        final pan = _parsePANResponse(jsonResponse);
        return OCRResult.success(DocumentResponse(pan: pan));
      } else {
        return OCRResult.failure('Please upload a valid PAN card');
      }
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        return OCRResult.networkError('Network issue, please try again');
      }
      return OCRResult.error('Processing failed, please try again');
    }
  }

  // Process any document type
  Future<OCRResult> processDocument(String documentType, File imageFile) async {
    if (!await imageFile.exists()) {
      return OCRResult.error('File not found');
    }

    try {
      switch (documentType) {
        case 'aadhar_front':
          return await processAadhaarFront(imageFile);
        case 'aadhar_back':
          return await processAadhaarBack(imageFile);
        case 'pan_card':
          return await processPAN(imageFile);
        case 'selfie':
        case 'driving_license':
          // For selfie and driving license, just return success
          return OCRResult.success(DocumentResponse());
        default:
          return OCRResult.error('Unknown document type');
      }
    } catch (e) {
      return OCRResult.error('Processing failed, please try again');
    }
  }

  // Parse Aadhaar response
  AadhaarCard _parseAadhaarResponse(Map<String, dynamic> jsonResponse) {
    try {
      final aadharData = jsonResponse['Aadhar'] as Map<String, dynamic>;
      final name = aadharData['name']?.toString().trim() ?? '';
      final dob = aadharData['date of birth']?.toString().trim() ?? '';
      final gender = aadharData['gender']?.toString().trim() ?? '';
      final aadhaarNumber =
          aadharData['Aadhar number']?.toString().trim() ?? '';
      final pincode = aadharData['PIN Code']?.toString().trim() ?? '';
      final address = aadharData['address']?.toString().trim() ?? '';
      final aadhaarValidate =
          aadharData['aadhar_validate']?.toString().trim() ?? '';

      return AadhaarCard(
        name: name.isEmpty ? null : name,
        dateOfBirth: dob.isEmpty ? null : dob,
        gender: gender.isEmpty ? null : gender,
        aadhaarNumber: aadhaarNumber.isEmpty ? null : aadhaarNumber,
        address: Address(
          pincode: pincode.isEmpty ? null : pincode,
          line1: address.isEmpty ? null : address,
        ),
        isValid: aadhaarValidate.toLowerCase() == 'true',
      );
    } catch (e) {
      throw Exception('Failed to parse Aadhaar response: $e');
    }
  }

  // Parse PAN response
  PanCard _parsePANResponse(Map<String, dynamic> jsonResponse) {
    try {
      final panData = jsonResponse['PAN'] as Map<String, dynamic>;
      final name = panData['Candidate Name']?.toString().trim() ?? '';
      final dob = panData['DOB']?.toString().trim() ?? '';
      final panNumber = panData['PAN number']?.toString().trim() ?? '';
      final fatherName = panData['Father Name']?.toString().trim() ?? '';

      return PanCard(
        name: name.isEmpty ? null : name,
        dateOfBirth: dob.isEmpty ? null : dob,
        panNumber: panNumber.isEmpty ? null : panNumber,
        fatherName: fatherName.isEmpty ? null : fatherName,
      );
    } catch (e) {
      throw Exception('Failed to parse PAN response: $e');
    }
  }
}

// Add this new class to handle different result types
class OCRResult {
  final bool isSuccess;
  final DocumentResponse? documentResponse;
  final String? errorMessage;
  final OCRResultType type;

  OCRResult._(
    this.isSuccess,
    this.documentResponse,
    this.errorMessage,
    this.type,
  );

  factory OCRResult.success(DocumentResponse response) {
    return OCRResult._(true, response, null, OCRResultType.success);
  }

  factory OCRResult.failure(String message) {
    return OCRResult._(false, null, message, OCRResultType.failure);
  }

  factory OCRResult.networkError(String message) {
    return OCRResult._(false, null, message, OCRResultType.networkError);
  }

  factory OCRResult.error(String message) {
    return OCRResult._(false, null, message, OCRResultType.error);
  }
}

enum OCRResultType { success, failure, networkError, error }
