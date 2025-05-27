// screens/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/Registration/models/registration_model.dart';
import '../../../auth/Registration/controller/registration_controller.dart';
import '../../../auth/Registration/views/personal_info_view.dart';
import '../../../auth/Registration/views/documents_view.dart';
import '../../../auth/Registration/widgets/registration_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late RegistrationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller = RegistrationController();
    _controller.addListener(_onControllerChanged);
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

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleBackAction() {
    if (_controller.currentStep == 0) {
      Navigator.pop(context);
    } else {
      _controller.previousStep();
    }
  }

  void _handleNextStep() async {
    final success = await _controller.nextStep();
    if (!success) {
      _showSnackBar(_controller.getValidationMessage(), isError: true);
    }
  }

  void _handleSubmitRegistration() {
    if (_controller.canSubmitRegistration) {
      _showSuccessDialog();
    } else {
      _showSnackBar(_controller.getValidationMessage(), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        onContinue: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Close registration screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrationConstants.backgroundColor,
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
              Progress_Indicator(currentStep: _controller.currentStep),
              Expanded(
                child: PageView(
                  controller: _controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Form(
                      key: _controller.personalFormKey,
                      child: PersonalInfoView(
                        personalInfo: _controller.personalInfo,
                        onPersonalInfoChanged: _controller.updatePersonalInfo,
                      ),
                    ),
                    Form(
                      key: _controller.documentsFormKey,
                      child: DocumentsView(
                        documentInfo: _controller.documentInfo,
                        onDocumentInfoChanged: _controller.updateDocumentInfo,
                      ),
                    ),
                  ],
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
          color: RegistrationConstants.primaryColor,
          size: 20,
        ),
        onPressed: _handleBackAction,
      ),
      title: Text(
        'Registration',
        style: GoogleFonts.plusJakartaSans(
          color: RegistrationConstants.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
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
            onPressed: _controller.currentStep == 0 
                ? _handleNextStep 
                : _handleSubmitRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: RegistrationConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              _controller.currentStep == 0 ? 'Next Step' : 'Submit Registration',
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