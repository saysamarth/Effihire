import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../services/bank_controller.dart';
import '../widgets/bank_info_card.dart';
import '../widgets/bank_conformation.dart';
import '../../../common widgets/snackbar_helper.dart';
import '../../../config/colors/app_colors.dart';
import 'bank_review_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen>
    with TickerProviderStateMixin {
  // Controllers and Keys
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  
  // Services
  late BankVerificationController _controller;
  
  // Animations
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  
  // Focus nodes for better UX
  final _ifscFocusNode = FocusNode();
  final _accountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = BankVerificationController();
    _initializeAnimations();
    _setupFocusListeners();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    _slideAnimationController.forward();
  }

  void _setupFocusListeners() {
    _ifscController.addListener(_onIFSCChanged); // Listen for IFSC field changes to trigger auto-fetch
  }

  void _onIFSCChanged() {
    final ifscCode = _ifscController.text.trim();
    if (ifscCode.length == 11 && _controller.validateIFSCFormat(ifscCode)) {
      _controller.clearBankDetails();
      _fetchBankDetails();
    } else if (ifscCode.length < 11) {
      _controller.clearBankDetails();
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ifscController.dispose();
    _controller.dispose();
    _slideAnimationController.dispose();
    _ifscFocusNode.dispose();
    _accountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchBankDetails() async {
    final ifscCode = _ifscController.text.trim().toUpperCase();
    
    if (!_controller.validateIFSCFormat(ifscCode)) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Please enter a valid 11-character IFSC code',
      );
      return;
    }
    final success = await _controller.fetchBankDetails(ifscCode); 
    if (mounted) {
      if (!success && _controller.bankInfoError != null) {
        SnackbarHelper.showErrorSnackBar(
          context,
          _controller.bankInfoError!,
        );
      }
    }
  }

  void _onEditBankDetails() {
    _controller.clearBankDetails();
    _ifscFocusNode.requestFocus();
  }

  // UPDATED: Bank verification method (penny drop)
  // Replace the _verifyBankDetails method in bank_detail_input_screen.dart
Future<void> _verifyBankDetails() async {

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (!_controller.canProceedToVerification) {
    SnackbarHelper.showErrorSnackBar(
      context,
      'Please confirm the bank details before proceeding',
    );
    return;
  }

  try {
    final success = await _controller.verifyBankAccount(
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim().toUpperCase(),
    );
    if (mounted) {
      if (success && _controller.verifiedBankData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BankReviewScreen(
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim().toUpperCase(),
              bankData: _controller.verifiedBankData!,
            ),
          ),
        );
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          _controller.verificationError ?? 'Verification failed. Please try again.',
        );
      }
    }
  } catch (e) {
    if (mounted) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'An error occurred during verification: ${e.toString()}',
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Bank Details',
                    subtitle: 'Enter your bank account details for verification',
                  ),
                  const SizedBox(height: 32),
                  
                  _buildBankInputForm(), // SECTION 1: Input Form

                  if (_controller.isFetchingBankInfo) 
                    const BankInfoLoadingCard(), // SECTION 2: Bank Information Display
                  
                  if (_controller.hasBankInfo && _controller.fetchedBankDetails != null)
                    BankInfoCard(
                      bankDetails: _controller.fetchedBankDetails!,
                      onEdit: _onEditBankDetails,
                    ),
                  

                  if (_controller.hasBankInfo)
                    BankConfirmationWidget(    // SECTION 3: Confirmation Widget
                      isConfirmed: _controller.isConfirmed,
                      onConfirmationChanged: _controller.setConfirmation,
                    ),

                  if (_controller.hasBankInfo)
                    const SizedBox(height: 20),
                  
                  if (_controller.hasBankInfo)
                    _buildVerifyButton(), // SECTION 4: Verify Button
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Bank Details',
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

  Widget _buildBankInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildBankAccountField(),
          const SizedBox(height: 20),
          _buildIFSCFieldWithButton(),
        ],
      ),
    );
  }

  Widget _buildBankAccountField() {
    return TextFormField(
      controller: _accountNumberController,
      focusNode: _accountFocusNode,
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(fontSize: 15),
      enabled: !_controller.isConfirmed,
      decoration: InputDecoration(
        labelText: 'Bank Account Number',
        hintText: 'Enter your bank account number',
        prefixIcon: const Icon(
          Icons.account_balance,
          color: AppConstants.primaryColor,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: _controller.isConfirmed ? Colors.grey.shade50 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Account number is required';
        }
        if (value!.length < 9 || value.length > 18) {
          return 'Please enter a valid account number';
        }
        return null;
      },
    );
  }

  Widget _buildIFSCFieldWithButton() {
    return Column(
      children: [
        TextFormField(
          controller: _ifscController,
          focusNode: _ifscFocusNode,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.plusJakartaSans(fontSize: 15),
          enabled: !_controller.isConfirmed,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            hintText: 'Enter IFSC code (e.g., SBIN0001234)',
            prefixIcon: const Icon(
              Icons.location_city,
              color: AppConstants.primaryColor,
              size: 20,
            ),
            suffixIcon: _controller.isConfirmed ? 
              const Icon(Icons.check_circle, color: Colors.green) :
              (_ifscController.text.length == 11 && !_controller.isFetchingBankInfo ?
                IconButton(
                  icon: const Icon(Icons.search, color: AppConstants.primaryColor),
                  onPressed: _fetchBankDetails,
                  tooltip: 'Get Bank Info',
                ) : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: _controller.isConfirmed ? Colors.grey.shade50 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'IFSC code is required';
            }
            if (value!.length != 11) {
              return 'IFSC code must be 11 characters';
            }
            if (!_controller.validateIFSCFormat(value)) {
              return 'Please enter a valid IFSC code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _controller.canProceedToVerification && !_controller.isVerifying 
          ? _verifyBankDetails 
          : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _controller.canProceedToVerification 
            ? AppConstants.primaryColor 
            : Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _controller.isVerifying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Verify Bank Account',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: _controller.canProceedToVerification 
                    ? Colors.white 
                    : Colors.grey.shade600,
                ),
              ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}