import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class RegistrationService {
  static const String baseUrl = 'http://192.168.0.107:3000';

  Future<String?> uploadImageToFirebase(
    File imageFile,
    String documentType,
    String userId,
  ) async {
    try {
      String fileName =
          '${userId}_${documentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_documents')
          .child(userId)
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }

  Future<bool> submitDocumentUrl(
    String userId,
    String documentType,
    String downloadUrl,
  ) async {
    try {
      Map<String, String> documentData = {};
      switch (documentType) {
        case 'aadhar_front':
          documentData['aadhar_url'] = downloadUrl;
          break;
        case 'aadhar_back':
          documentData['aadharBack_url'] = downloadUrl;
          break;
        case 'driving_license':
          documentData['dl_url'] = downloadUrl;
          break;
        case 'pan_card':
          documentData['pan_url'] = downloadUrl;
          break;
        case 'selfie':
          documentData['user_image_url'] = downloadUrl;
          break;
        default:
          return false;
      }

      final endpoint = '$baseUrl/users/$userId/documents';

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(documentData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Backend submission failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error submitting document URL to backend: $e');
      return false;
    }
  }

  Future<bool> completePersonalRegistration(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final endpoint = '$baseUrl/users/$userId/complete-personal-registration';

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Personal registration failed with status ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('Error completing personal registration: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final endpoint = '$baseUrl/users/$userId';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch user details, status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
