import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class RegistrationService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<String?> uploadImageToFirebase(
    File imageFile,
    String documentType,
    String userId,
  ) async {
    try {
      String fileName =
          '${userId}_${documentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Create Firebase Storage reference
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_documents')
          .child(userId)
          .child(fileName);

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }

  // Submit document URL to backend
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
        default:
          return false;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/documents'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(documentData),
      );

      if (response.statusCode == 200) {
        print('Document URL submitted successfully: ${response.body}');
        return true;
      } else {
        print('Failed to submit document URL: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting document URL: $e');
      return false;
    }
  }

  // Complete personal registration
  Future<bool> completePersonalRegistration(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/complete-personal-registration'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        print('Personal registration completed successfully');
        return true;
      } else {
        print('Failed to complete personal registration: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error completing personal registration: $e');
      return false;
    }
  }

  // Get user details
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final endpoint = '$baseUrl/users/$userId';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
