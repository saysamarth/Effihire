import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class RegistrationService {
  static const String baseUrl = 'https://effihire.onrender.com';

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
