import 'dart:io';

import 'package:effihire/auth/Registration/models/ocr_model.dart';
import 'package:effihire/auth/Registration/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common widgets/snackbar_helper.dart';
import '../../../config/media/camera_service.dart';
import '../../../config/media/document_scanner_service.dart';
import '../../../config/service/shared_pref.dart';
import '../models/registration_model.dart';
import '../services/register_backend_service.dart';
import '../services/registration_controller.dart';
import '../widgets/common.dart';
import '../widgets/documents_widget.dart';
import '../widgets/personal_info_widget.dart';
import '../widgets/review_step_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late RegistrationController _registrationController;

  // Form keys
  final _personalFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _languagesController = TextEditingController();

  // Services
  final DocumentScannerService _documentScannerService =
      DocumentScannerService();
  final PhotoCaptureService _photoCaptureService = PhotoCaptureService();
  final OCRService _ocrService = OCRService();
  final RegistrationService _registrationService = RegistrationService();

  final Map<String, bool> _documentLoadingStates = {};
  final Map<String, DocumentResponse> _documentResponses = {};

  @override
  void initState() {
    super.initState();
    _registrationController = RegistrationController(
      userId: SharedPrefsService.getUserUid()!,
    );
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeServices() async {
    try {
      await _documentScannerService.initializeScanner();
      await _photoCaptureService.initializeService();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _registrationController.dispose();

    // Dispose text controllers
    _nameController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _qualificationController.dispose();
    _languagesController.dispose();

    // Dispose services
    _documentScannerService.dispose();
    _photoCaptureService.dispose();

    super.dispose();
  }

  // Navigation methods
  void _nextStep() {
    final currentStep = _registrationController.currentStep;

    if (currentStep == 0) {
      if (_registrationController.validatePersonalInfo(
        formKey: _personalFormKey,
        gender: _registrationController.registrationData.gender,
      )) {
        _updatePersonalData();
        _registrationController.nextStep();
        _navigateToNextPage();
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          _registrationController.getValidationErrorMessage(0),
        );
      }
    } else if (currentStep == 1) {
      if (_registrationController.validateDocuments(
        formKey: _documentsFormKey,
      )) {
        _registrationController.nextStep();
        _navigateToNextPage();
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          _registrationController.getValidationErrorMessage(1),
        );
      }
    }
  }

  void _previousStep() {
    _registrationController.previousStep();
    _navigateToPreviousPage();
  }

  void _navigateToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Business logic methods
  void _updatePersonalData() {
    _registrationController.updatePersonalData(
      fullName: _nameController.text,
      currentAddress: _currentAddressController.text,
      permanentAddress: _permanentAddressController.text,
      qualification: _qualificationController.text,
      languages: _languagesController.text,
      gender: _registrationController.registrationData.gender,
    );
  }

  Future<void> _scanDocument(String documentType) async {
    try {
      File? scannedImage;

      if (documentType == 'selfie') {
        scannedImage = await _photoCaptureService.captureSelfie(
          context: context,
          showPreview: true,
        );
      } else {
        scannedImage = await _documentScannerService.scanDocument(
          context: context,
        );
      }

      if (scannedImage != null) {
        if (!_documentScannerService.isValidImage(scannedImage)) {
          SnackbarHelper.showErrorSnackBar(
            context,
            'Please capture a valid image',
          );
          return;
        }

        await _handleDocumentScan(documentType, scannedImage);
      }
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Error scanning document: ${e.toString()}',
      );
    }
  }

  Future<void> _uploadImageToFirebase(
    String documentType,
    File imageFile,
  ) async {
    try {
      final userId = SharedPrefsService.getUserUid();

      if (userId == null) {
        SnackbarHelper.showErrorSnackBar(
          context,
          'User ID not found. Please log in again.',
        );
        return;
      }

      final downloadUrl = await _registrationService.uploadImageToFirebase(
        imageFile,
        documentType,
        userId,
      );

      if (downloadUrl != null) {
        _registrationController.updateDocumentUrl(documentType, downloadUrl);
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Failed to upload image to Firebase Storage',
        );
      }
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Document upload failed: ${e.toString()}',
      );
    }
  }

  // In registration_screen.dart

  Future<void> _handleDocumentScan(String documentType, File imageFile) async {
    if (!await imageFile.exists()) {
      SnackbarHelper.showErrorSnackBar(context, 'Image file not found');
      return;
    }

    setState(() {
      _documentLoadingStates[documentType] = true;
    });

    try {
      final response = await _ocrService.processDocument(
        documentType,
        imageFile,
      );

      if (response.isSuccess && response.documentResponse != null) {
        // --- START OF FIX ---

        // Determine the correct key for storing the OCR data.
        String ocrStorageKey;
        if (documentType == 'aadhar_front' || documentType == 'aadhar_back') {
          ocrStorageKey =
              'aadhar_number'; // Use the generic key for Aadhaar data
        } else if (documentType == 'pan_card') {
          ocrStorageKey = 'pan_card'; // Use the generic key for PAN data
        } else {
          // For other documents, this won't be used for retrieval, but we can default it.
          ocrStorageKey = documentType;
        }

        // --- END OF FIX ---

        setState(() {
          _documentResponses[documentType] = response.documentResponse!;
          _registrationController.updateDocument(documentType, imageFile);

          // Update OCR data using the CORRECT, consistent key
          _registrationController.updateOcrData(
            ocrStorageKey,
            response.documentResponse!,
          );
        });

        await _uploadImageToFirebase(documentType, imageFile);

        String successMessage = documentType == 'selfie'
            ? 'Selfie captured successfully!'
            : documentType == 'driving_license'
            ? 'Driving license uploaded successfully!'
            : 'Document verified successfully!';

        SnackbarHelper.showSuccessSnackBar(context, successMessage);
      } else {
        SnackbarHelper.showErrorSnackBar(context, response.errorMessage!);
      }
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Processing failed, please try again',
      );
    } finally {
      setState(() {
        _documentLoadingStates[documentType] = false;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_registrationController.isDetailsConfirmed) {
      SnackbarHelper.showErrorSnackBar(
        context,
        _registrationController.getValidationErrorMessage(2),
      );
      return;
    }
    final success = await _registrationController.submitRegistration();
    if (success) {
      await SharedPrefsService.setRegistrationStatus(1);
      _showSuccessDialog();
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Failed to submit registration. Please try again.',
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialogWidget(
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _onGenderSelected(String gender) {
    _registrationController.updateGender(gender);
  }

  void _onSameAddressChanged(bool value) {
    _registrationController.updateSameAsCurrentAddress(
      value,
      _currentAddressController.text,
    );
    if (value) {
      _permanentAddressController.text = _currentAddressController.text;
    } else {
      _permanentAddressController.clear();
    }
  }

  void _onVehicleSelected(String vehicle) {
    _registrationController.updateVehicleSelection(vehicle);
  }

  void _onConfirmationChanged(bool isConfirmed) {
    _registrationController.updateConfirmationStatus(isConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _registrationController,
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: FadeTransition(
              opacity: _slideAnimation,
              child: Column(
                children: [
                  ProgressIndicatorWidget(
                    currentStep: _registrationController.currentStep,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildPersonalInfoStep(),
                        _buildDocumentsStep(),
                        _buildReviewStep(),
                      ],
                    ),
                  ),
                  _buildBottomButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppConstants.primaryColor,
          size: 20,
        ),
        onPressed: () {
          if (_registrationController.currentStep == 0) {
            Navigator.pop(context);
          } else {
            _previousStep();
          }
        },
      ),
      title: Text(
        'Registration',
        style: GoogleFonts.plusJakartaSans(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return PersonalInfoStepWidget(
      formKey: _personalFormKey,
      nameController: _nameController,
      currentAddressController: _currentAddressController,
      permanentAddressController: _permanentAddressController,
      qualificationController: _qualificationController,
      languagesController: _languagesController,
      selectedGender: _registrationController.registrationData.gender,
      sameAsCurrentAddress:
          _registrationController.registrationData.sameAsCurrentAddress,
      onGenderSelected: _onGenderSelected,
      onSameAddressChanged: _onSameAddressChanged,
    );
  }

  Widget _buildDocumentsStep() {
    return DocumentsStepWidget(
      formKey: _documentsFormKey,
      selectedVehicle: _registrationController.registrationData.selectedVehicle,
      registrationData: _registrationController.registrationData,
      onVehicleSelected: _onVehicleSelected,
      onDocumentScan: _scanDocument,
      documentLoadingStates: _documentLoadingStates,
      documentResponses: _documentResponses,
    );
  }

  Widget _buildReviewStep() {
    return ReviewStepWidget(
      registrationData: _registrationController.registrationData,
      onConfirmationChanged: _onConfirmationChanged,
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _registrationController.isLoading
            ? LoadingButton(
                text: 'Submitting...',
                onPressed: null,
                isLoading: true,
              )
            : SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _registrationController.currentStep == 0
                      ? _nextStep
                      : _registrationController.currentStep == 1
                      ? _nextStep
                      : _registrationController.isDetailsConfirmed
                      ? _submitRegistration
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    _registrationController.currentStep == 0
                        ? 'Next Step'
                        : _registrationController.currentStep == 1
                        ? 'Review Details'
                        : 'Submit Registration',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
