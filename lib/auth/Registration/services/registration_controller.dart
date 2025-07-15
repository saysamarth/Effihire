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

  Future<bool> submitRegistration() async {
    if (!_registrationData.isDocumentsComplete || !_isDetailsConfirmed) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final documents = _registrationData.documents;
      for (var entry in documents.entries) {
        if (entry.value != null) {
          final downloadUrl = await _registrationService.uploadImageToFirebase(
            entry.value!,
            entry.key,
            userId,
          );
          if (downloadUrl != null) {
            await _registrationService.submitDocumentUrl(
              userId,
              entry.key,
              downloadUrl,
            );
          }
        }
      }

      final success = await _registrationService
          .completePersonalRegistration(userId, {
            'full_name': _registrationData.fullName,
            'current_address': _registrationData.currentAddress,
            'permanent_address': _registrationData.permanentAddress,
            'vehicle_details': _registrationData.selectedVehicle,
            'qualification': _registrationData.qualification,
            'languages': _registrationData.languages,
            'gender': _registrationData.gender,
          });

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
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
