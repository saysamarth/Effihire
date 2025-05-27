// controllers/registration_controller.dart

import 'package:flutter/material.dart';
import '../models/registration_model.dart';

class RegistrationController extends ChangeNotifier {
  // Form keys
  final GlobalKey<FormState> _personalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _documentsFormKey = GlobalKey<FormState>();

  // Page controller
  final PageController _pageController = PageController();

  // Registration data
  PersonalInfo _personalInfo = PersonalInfo();
  DocumentInfo _documentInfo = DocumentInfo();
  int _currentStep = 0;

  // Getters
  GlobalKey<FormState> get personalFormKey => _personalFormKey;
  GlobalKey<FormState> get documentsFormKey => _documentsFormKey;
  PageController get pageController => _pageController;
  PersonalInfo get personalInfo => _personalInfo;
  DocumentInfo get documentInfo => _documentInfo;
  int get currentStep => _currentStep;
  RegistrationData get registrationData => RegistrationData(
        personalInfo: _personalInfo,
        documentInfo: _documentInfo,
      );

  bool get canProceedToNextStep {
    if (_currentStep == 0) {
      return _personalFormKey.currentState?.validate() == true && 
             _personalInfo.isValid;
    }
    return false;
  }

  bool get canSubmitRegistration {
    return _documentsFormKey.currentState?.validate() == true && 
           registrationData.isComplete;
  }

  // Methods
  void updatePersonalInfo(PersonalInfo personalInfo) {
    _personalInfo = personalInfo;
    notifyListeners();
  }

  void updateDocumentInfo(DocumentInfo documentInfo) {
    _documentInfo = documentInfo;
    notifyListeners();
  }

  Future<bool> nextStep() async {
    if (canProceedToNextStep) {
      _currentStep = 1;
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> previousStep() async {
    if (_currentStep > 0) {
      _currentStep = 0;
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  bool validateCurrentStep() {
    if (_currentStep == 0) {
      return _personalFormKey.currentState?.validate() == true && 
             _personalInfo.isValid;
    } else if (_currentStep == 1) {
      return _documentsFormKey.currentState?.validate() == true && 
             _documentInfo.isValid;
    }
    return false;
  }

  String getValidationMessage() {
    if (_currentStep == 0) {
      if (!_personalInfo.isValid) {
        return 'Please fill all required fields and select gender';
      }
    } else if (_currentStep == 1) {
      if (!_documentInfo.isValid) {
        return 'Please complete all required fields and upload all documents';
      }
    }
    return 'Please complete all required information';
  }

  void reset() {
    _personalInfo = PersonalInfo();
    _documentInfo = DocumentInfo();
    _currentStep = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}