import 'package:flutter/material.dart';
import '../models/registration_model.dart';

class RegistrationController extends ChangeNotifier {
  final RegistrationData _registrationData = RegistrationData();
  int _currentStep = 0;
  bool _isDetailsConfirmed = false;
  bool _isLoading = false;

  // Getters
  RegistrationData get registrationData => _registrationData;
  int get currentStep => _currentStep;
  bool get isDetailsConfirmed => _isDetailsConfirmed;
  bool get isLoading => _isLoading;

  // Form validation methods
  bool validatePersonalInfo({
    required GlobalKey<FormState> formKey,
    required String? gender,
  }) {
    return (formKey.currentState?.validate() ?? false) && gender != null;
  }

  bool validateDocuments({
    required GlobalKey<FormState> formKey,
  }) {
    return (formKey.currentState?.validate() ?? false) && 
           _registrationData.isDocumentsComplete;
  }

  // Step navigation
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

  // Update personal data
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

  // Update vehicle selection
  void updateVehicleSelection(String vehicle) {
    _registrationData.selectedVehicle = vehicle;
    notifyListeners();
  }

  // Update document
  void updateDocument(String documentType, dynamic file) {
    _registrationData.updateDocument(documentType, file);
    notifyListeners();
  }

  // Update gender
  void updateGender(String gender) {
    _registrationData.gender = gender;
    notifyListeners();
  }

  // Update address checkbox
  void updateSameAsCurrentAddress(bool value, String currentAddress) {
    _registrationData.sameAsCurrentAddress = value;
    if (value) {
      _registrationData.permanentAddress = currentAddress;
    }
    notifyListeners();
  }

  // Update confirmation status
  void updateConfirmationStatus(bool isConfirmed) {
    _isDetailsConfirmed = isConfirmed;
    notifyListeners();
  }

  // Submit registration
  Future<bool> submitRegistration() async {
    if (!_registrationData.isDocumentsComplete || !_isDetailsConfirmed) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you would make actual API call
      // final result = await _apiService.submitRegistration(_registrationData);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get validation error message
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

  // Reset controller
  void reset() {
    _currentStep = 0;
    _isDetailsConfirmed = false;
    _isLoading = false;
    // Reset registration data if needed
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}