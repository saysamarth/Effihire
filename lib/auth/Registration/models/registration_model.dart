// models/registration_model.dart

import 'dart:io';
import 'package:flutter/material.dart';

class PersonalInfo {
  String name;
  String currentAddress;
  String permanentAddress;
  String qualification;
  String languages;
  String? gender;
  bool sameAsCurrentAddress;

  PersonalInfo({
    this.name = '',
    this.currentAddress = '',
    this.permanentAddress = '',
    this.qualification = '',
    this.languages = '',
    this.gender,
    this.sameAsCurrentAddress = false,
  });

  bool get isValid {
    return name.isNotEmpty &&
        currentAddress.isNotEmpty &&
        permanentAddress.isNotEmpty &&
        qualification.isNotEmpty &&
        languages.isNotEmpty &&
        gender != null;
  }

  PersonalInfo copyWith({
    String? name,
    String? currentAddress,
    String? permanentAddress,
    String? qualification,
    String? languages,
    String? gender,
    bool? sameAsCurrentAddress,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      qualification: qualification ?? this.qualification,
      languages: languages ?? this.languages,
      gender: gender ?? this.gender,
      sameAsCurrentAddress: sameAsCurrentAddress ?? this.sameAsCurrentAddress,
    );
  }
}

class DocumentInfo {
  String? selectedVehicle;
  File? aadharFrontImage;
  File? aadharBackImage;
  File? panCardImage;
  File? drivingLicenseImage;
  File? selfieImage;

  DocumentInfo({
    this.selectedVehicle,
    this.aadharFrontImage,
    this.aadharBackImage,
    this.panCardImage,
    this.drivingLicenseImage,
    this.selfieImage,
  });

  bool get isValid {
    return selectedVehicle != null &&
        aadharFrontImage != null &&
        aadharBackImage != null &&
        panCardImage != null &&
        drivingLicenseImage != null &&
        selfieImage != null;
  }

  DocumentInfo copyWith({
    String? selectedVehicle,
    File? aadharFrontImage,
    File? aadharBackImage,
    File? panCardImage,
    File? drivingLicenseImage,
    File? selfieImage,
  }) {
    return DocumentInfo(
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      aadharFrontImage: aadharFrontImage ?? this.aadharFrontImage,
      aadharBackImage: aadharBackImage ?? this.aadharBackImage,
      panCardImage: panCardImage ?? this.panCardImage,
      drivingLicenseImage: drivingLicenseImage ?? this.drivingLicenseImage,
      selfieImage: selfieImage ?? this.selfieImage,
    );
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
}

class RegistrationData {
  PersonalInfo personalInfo;
  DocumentInfo documentInfo;

  RegistrationData({
    required this.personalInfo,
    required this.documentInfo,
  });

  bool get isComplete {
    return personalInfo.isValid && documentInfo.isValid;
  }
}

// Constants
class RegistrationConstants {
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
  
  static const List<VehicleOption> vehicleOptions = [
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
  
  static const Color primaryColor = Color(0xFF5B3E86);
  static const Color backgroundColor = Color(0xFFF8F9FA);
}