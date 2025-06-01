import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
// Import your files
import '../models/registration_model.dart';
import '../widgets/registration_widget.dart';
import '../../../config/media/image_picker_service.dart'; // Updated import

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  int currentStep = 0;

  // Form keys
  final _personalFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();

  // Registration data model
  final RegistrationData _registrationData = RegistrationData();

  // Controllers
  final _nameController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _languagesController = TextEditingController();

  // Document scanner service
  final DocumentScannerService _documentScannerService = DocumentScannerService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // Initialize the document scanner
    _initializeDocumentScanner();
  }

  Future<void> _initializeDocumentScanner() async {
    try {
      await _documentScannerService.initializeScanner();
    } catch (e) {
      debugPrint('Error initializing document scanner: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _nameController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _qualificationController.dispose();
    _languagesController.dispose();
    _documentScannerService.dispose();
    super.dispose();
  }

  Future<void> _scanDocument(String documentType) async {
    try {
      File? scannedImage;
      
      // Show loading indicator
      if (mounted) {
        _showSnackBar('Preparing to scan...', isError: false);
      }
      
      if (documentType == 'selfie') {
        // For selfie, use regular camera with front camera
        scannedImage = await _documentScannerService.scanDocument(
          context: context,
          scanType: DocumentScanType.selfie,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 90,
        );
      } else {
        // For documents, use ML Kit document scanner
        scannedImage = await _documentScannerService.scanDocument(
          context: context,
          scanType: DocumentScanType.document,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 90,
        );
      }
      
      if (scannedImage != null) {
        // Validate image
        if (!_documentScannerService.isValidImage(scannedImage)) {
          _showSnackBar('Please capture a valid image', isError: true);
          return;
        }
        
        // Check file size
        double sizeInMB = _documentScannerService.getImageSizeInMB(scannedImage);
        if (sizeInMB > 10) {
          _showSnackBar('Image size should be less than 10MB', isError: true);
          // Optionally delete the large file
          await _documentScannerService.deleteImage(scannedImage);
          return;
        }
        
        if (mounted) {
          setState(() {
            _registrationData.updateDocument(documentType, scannedImage);
          });
          
          String successMessage = documentType == 'selfie' 
              ? 'Selfie captured successfully!' 
              : 'Document scanned successfully!';
          _showSnackBar(successMessage, isError: false);
        }
      } else {
        // User cancelled or scanning failed - don't show error for cancellation
        debugPrint('Document scanning cancelled or failed');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error scanning document: ${e.toString()}', isError: true);
      }
    }
  }

  void _nextStep() {
    if (_personalFormKey.currentState!.validate() &&
        _registrationData.gender != null) {
      _updatePersonalData();
      setState(() => currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showSnackBar('Please fill all required fields', isError: true);
    }
  }

  void _previousStep() {
    if (currentStep == 1) {
      setState(() => currentStep = 0);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updatePersonalData() {
    _registrationData.fullName = _nameController.text;
    _registrationData.currentAddress = _currentAddressController.text;
    _registrationData.permanentAddress = _permanentAddressController.text;
    _registrationData.qualification = _qualificationController.text;
    _registrationData.languages = _languagesController.text;
  }

  void _submitRegistration() {
    if (_documentsFormKey.currentState!.validate() &&
        _registrationData.isDocumentsComplete) {
      _showSuccessDialog();
    } else {
      _showSnackBar(
        'Please complete all required fields and upload all documents',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Successful!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your registration has been submitted successfully. We will review your documents and get back to you within 24-48 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildPersonalInfoStep(), _buildDocumentsStep()],
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
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
        onPressed: () =>
            currentStep == 0 ? Navigator.pop(context) : _previousStep(),
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: currentStep >= 1
                    ? AppConstants.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Personal Information',
              subtitle: 'Tell us about yourself',
            ),
            const SizedBox(height: 24),

            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _currentAddressController,
              label: 'Current Address',
              hint: 'Enter your current address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Current address is required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _permanentAddressController,
              label: 'Permanent Address',
              hint: 'Enter your permanent address',
              icon: Icons.home_outlined,
              maxLines: 2,
              enabled: !_registrationData.sameAsCurrentAddress,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Permanent address is required'
                  : null,
            ),
            
            const SizedBox(height: 12),
            _buildAddressCheckbox(),
            
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _qualificationController,
                    label: 'Qualification',
                    hint: 'e.g., Graduate',
                    icon: Icons.school_outlined,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Qualification is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _languagesController,
                    label: 'Languages',
                    hint: 'e.g., English, Hindi',
                    icon: Icons.language_outlined,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Languages are required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            GenderSelectionWidget(
              selectedGender: _registrationData.gender,
              onGenderSelected: (gender) {
                setState(() {
                  _registrationData.gender = gender;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _documentsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Documents & Vehicle',
              subtitle: 'Scan required documents and select vehicle',
            ),
            const SizedBox(height: 24),

            VehicleSelectionGrid(
              selectedVehicle: _registrationData.selectedVehicle,
              onVehicleSelected: (vehicle) {
                setState(() {
                  _registrationData.selectedVehicle = vehicle;
                });
              },
            ),
            const SizedBox(height: 32),

            Text(
              'Required Documents',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Info card about document scanning
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Documents will be scanned automatically with proper alignment and cropping',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ...DocumentType.requiredDocuments
                .map(
                  (documentType) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DocumentUploadCard(
                      documentType: documentType,
                      uploadedFile: _registrationData.getDocument(
                        documentType.id,
                      ),
                      onTap: () => _scanDocument(documentType.id),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _registrationData.sameAsCurrentAddress,
            onChanged: (value) {
              setState(() {
                _registrationData.sameAsCurrentAddress = value ?? false;
                if (_registrationData.sameAsCurrentAddress) {
                  _permanentAddressController.text =
                      _currentAddressController.text;
                } else {
                  _permanentAddressController.clear();
                }
              });
            },
            activeColor: AppConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Same as current address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: currentStep == 0 ? _nextStep : _submitRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              currentStep == 0 ? 'Next Step' : 'Submit Registration',
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