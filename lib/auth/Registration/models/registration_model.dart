import 'dart:io';
import 'package:effihire/auth/Registration/models/ocr_model.dart';
import 'package:flutter/material.dart';

class RegistrationData {
  // Personal Information
  String fullName;
  String currentAddress;
  String permanentAddress;
  String qualification;
  String languages;
  String? gender;
  bool sameAsCurrentAddress;

  // Vehicle and Documents
  String? selectedVehicle;
  Map<String, File?> documents;
  Map<String, String?> documentUrls;
  Map<String, DocumentResponse?> ocrData;

  RegistrationData({
    this.fullName = '',
    this.currentAddress = '',
    this.permanentAddress = '',
    this.qualification = '',
    this.languages = '',
    this.gender,
    this.sameAsCurrentAddress = false,
    this.selectedVehicle,
    Map<String, File?>? documents,
    Map<String, String?>? documentUrls,
    Map<String, DocumentResponse?>? ocrData,
  }) : documents =
           documents ??
           {
             'aadhar_front': null,
             'aadhar_back': null,
             'pan_card': null,
             'driving_license': null,
             'selfie': null,
           },
       documentUrls =
           documentUrls ??
           {
             'aadhar_front': null,
             'aadhar_back': null,
             'pan_card': null,
             'driving_license': null,
             'selfie': null,
           },
       ocrData = ocrData ?? {'aadhar_number': null, 'pan_card': null};

  bool get isPersonalInfoComplete {
    return fullName.isNotEmpty &&
        currentAddress.isNotEmpty &&
        permanentAddress.isNotEmpty &&
        qualification.isNotEmpty &&
        languages.isNotEmpty &&
        gender != null;
  }

  bool get isDocumentsComplete {
    return selectedVehicle != null &&
        documents['aadhar_front'] != null &&
        documents['aadhar_back'] != null &&
        documents['pan_card'] != null &&
        documents['driving_license'] != null &&
        documents['selfie'] != null;
  }

  void updateDocument(String type, File? file) {
    documents[type] = file;
  }

  File? getDocument(String type) {
    return documents[type];
  }

  void updateDocumentUrl(String type, String url) {
    documentUrls[type] = url;
  }

  void updateOcrData(String type, DocumentResponse data) {
    ocrData[type] = data;
  }

  String? getDocumentUrl(String type) {
    return documentUrls[type];
  }

  DocumentResponse? getOcrData(String type) {
    return ocrData[type];
  }
}

class VehicleOption {
  final String name;
  final IconData icon;
  final Color color;

  const VehicleOption({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<VehicleOption> options = [
    VehicleOption(
      name: 'Bike',
      icon: Icons.two_wheeler,
      color: Color(0xFF5B3E86),
    ),
    VehicleOption(
      name: 'Car',
      icon: Icons.directions_car,
      color: Color(0xFF5B3E86),
    ),
    VehicleOption(
      name: 'Auto Rickshaw',
      icon: Icons.local_taxi,
      color: Color(0xFF5B3E86),
    ),
    VehicleOption(
      name: 'Bicycle',
      icon: Icons.pedal_bike,
      color: Color(0xFF5B3E86),
    ),
  ];
}

class DocumentType {
  final String id;
  final String title;
  final IconData icon;
  final bool isCameraOnly;

  const DocumentType({
    required this.id,
    required this.title,
    required this.icon,
    this.isCameraOnly = false,
  });

  static const List<DocumentType> requiredDocuments = [
    DocumentType(
      id: 'aadhar_front',
      title: 'Aadhar Card (Front)',
      icon: Icons.credit_card,
    ),
    DocumentType(
      id: 'aadhar_back',
      title: 'Aadhar Card (Back)',
      icon: Icons.credit_card,
    ),
    DocumentType(id: 'pan_card', title: 'PAN Card', icon: Icons.badge),
    DocumentType(
      id: 'driving_license',
      title: 'Driving License',
      icon: Icons.drive_eta,
    ),
    DocumentType(
      id: 'selfie',
      title: 'Selfie Photo',
      icon: Icons.camera_alt,
      isCameraOnly: true,
    ),
  ];
}

class AppConstants {
  static const Color primaryColor = Color(0xFF5B3E86);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
}
