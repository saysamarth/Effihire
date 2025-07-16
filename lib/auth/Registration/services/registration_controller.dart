import 'package:effihire/auth/Registration/models/ocr_model.dart';
import 'package:flutter/material.dart';

import '../models/registration_model.dart';
import 'register_backend_service.dart';

class RegistrationController extends ChangeNotifier {
  final RegistrationData _registrationData = RegistrationData();
  final RegistrationService _registrationService = RegistrationService();
  int _currentStep = 0;
  bool _isDetailsConfirmed = false;
  bool _isLoading = false;
  final String userId;

  RegistrationController({required this.userId});

  RegistrationData get registrationData => _registrationData;
  int get currentStep => _currentStep;
  bool get isDetailsConfirmed => _isDetailsConfirmed;
  bool get isLoading => _isLoading;

  bool validatePersonalInfo({
    required GlobalKey<FormState> formKey,
    required String? gender,
  }) {
    final formValid = formKey.currentState?.validate() ?? false;
    final genderValid = gender != null;
    return formValid && genderValid;
  }

  bool validateDocuments({required GlobalKey<FormState> formKey}) {
    final formValid = formKey.currentState?.validate() ?? false;
    final documentsComplete = _registrationData.isDocumentsComplete;
    return formValid && documentsComplete;
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void updatePersonalData({
    required String fullName,
    required String currentAddress,
    required String permanentAddress,
    required String qualification,
    required String languages,
    required String? gender,
  }) {
    _registrationData.fullName = fullName;
    _registrationData.currentAddress = currentAddress;
    _registrationData.permanentAddress = permanentAddress;
    _registrationData.qualification = qualification;
    _registrationData.languages = languages;
    _registrationData.gender = gender;
    notifyListeners();
  }

  void updateVehicleSelection(String vehicle) {
    _registrationData.selectedVehicle = vehicle;
    notifyListeners();
  }

  void updateDocument(String documentType, dynamic file) {
    _registrationData.updateDocument(documentType, file);
    notifyListeners();
  }

  void updateGender(String gender) {
    _registrationData.gender = gender;
    notifyListeners();
  }

  void updateSameAsCurrentAddress(bool value, String currentAddress) {
    _registrationData.sameAsCurrentAddress = value;
    if (value) {
      _registrationData.permanentAddress = currentAddress;
    }
    notifyListeners();
  }

  void updateConfirmationStatus(bool isConfirmed) {
    _isDetailsConfirmed = isConfirmed;
    notifyListeners();
  }

  void updateDocumentUrl(String documentType, String url) {
    _registrationData.updateDocumentUrl(documentType, url);
    notifyListeners();
  }

  void updateOcrData(String documentType, DocumentResponse data) {
    _registrationData.updateOcrData(documentType, data);
    notifyListeners();
  }

  Future<bool> submitRegistration() async {
    // --- START: PRE-SUBMISSION VALIDATION ---

    // Get all data points first
    final dlUrl = _registrationData.getDocumentUrl('driving_license');
    final selfieUrl = _registrationData.getDocumentUrl('selfie');
    final aadharOcr = _registrationData.getOcrData('aadhar_number');
    final panOcr = _registrationData.getOcrData('pan_card');

    // Check each required piece of data for null or empty values
    if (dlUrl == null || dlUrl.isEmpty) {
      print("Validation Failed: Driving License URL is missing.");
      // Optionally show a user-facing error message here
      return false;
    }
    if (selfieUrl == null || selfieUrl.isEmpty) {
      print("Validation Failed: Selfie URL is missing.");
      return false;
    }
    if (aadharOcr?.aadhaar?.aadhaarNumber == null) {
      print("Validation Failed: Aadhaar Number from OCR is missing.");
      return false;
    }
    if (panOcr?.pan?.panNumber == null) {
      print("Validation Failed: PAN Number from OCR is missing.");
      return false;
    }
    if (!_isDetailsConfirmed) {
      print("Validation Failed: Details are not confirmed by the user.");
      return false;
    }

    // --- END: PRE-SUBMISSION VALIDATION ---

    _isLoading = true;
    notifyListeners();

    try {
      // Now that we've validated, we can safely build the map
      Map<String, dynamic> userData = {
        'full_name': _registrationData.fullName,
        'current_address': _registrationData.currentAddress,
        'permanent_address': _registrationData.permanentAddress,
        'vehicle_details': _registrationData.selectedVehicle,
        'qualification': _registrationData.qualification,
        'languages': _registrationData.languages,
        'gender': _registrationData.gender?.toLowerCase(),
        'aadhar_front_url': _registrationData.getDocumentUrl('aadhar_front'),
        'aadhar_back_url': _registrationData.getDocumentUrl('aadhar_back'),
        'pan_url': _registrationData.getDocumentUrl('pan_card'),
        'dl_url': dlUrl, // Use the validated variable
        'user_image_url': selfieUrl, // Use the validated variable
        'aadhar_number':
            aadharOcr!.aadhaar!.aadhaarNumber, // Use the validated variable
        'pan_card': panOcr!.pan!.panNumber, // Use the validated variable
      };

      final success = await _registrationService.completePersonalRegistration(
        userId,
        userData,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Error during API call: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String getValidationErrorMessage(int step) {
    switch (step) {
      case 0:
        return 'Please fill all required fields';
      case 1:
        return 'Please complete all required fields and upload all documents';
      case 2:
        if (!_isDetailsConfirmed) {
          return 'Please confirm that all details are correct';
        }
        return 'Please complete all required fields';
      default:
        return 'Please complete all required fields';
    }
  }

  void reset() {
    _currentStep = 0;
    _isDetailsConfirmed = false;
    _isLoading = false;
    notifyListeners();
  }
}
