import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your existing files
import '../models/bank_model.dart';
import '../services/bank_controller.dart';
import '../../../common widgets/snackbar_helper.dart';
import '../../../config/colors/app_colors.dart';

class BankReviewScreen extends StatefulWidget {
  final String accountNumber;
  final String ifscCode;
  final BankVerificationData? bankData;

  const BankReviewScreen({
    super.key,
    required this.accountNumber,
    required this.ifscCode,
    this.bankData,
  });

  @override
  State<BankReviewScreen> createState() => _BankReviewScreenState();
}

class _BankReviewScreenState extends State<BankReviewScreen>
    with TickerProviderStateMixin {
  
  bool _isDetailsConfirmed = false;
  bool _isSubmitting = false;
  late BankVerificationController _controller;
  late AnimationController _fadeController, _scaleController;
  late Animation<double> _fadeAnimation, _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeAnimations();
  }

  void _initializeController() {
    _controller = BankVerificationController();
    if (widget.bankData != null) {
      _controller.setVerifiedBankData(widget.bankData);
      _controller.setVerificationStatus(true);
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _scaleController.forward());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitBankDetails() async {
    if (!_isDetailsConfirmed) {
      SnackbarHelper.showErrorSnackBar(context, 'Please confirm your bank details before submitting.');
      return;
    }

    if (widget.bankData == null) {
      SnackbarHelper.showErrorSnackBar(context, 'Bank verification data is missing. Please verify again.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      _controller.updateConfirmationStatus(true);
      final success = await _controller.submitBankDetails();
      
      if (success) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        String errorMessage = _controller.errorMessage ?? 'Failed to submit bank details. Please try again.';
        SnackbarHelper.showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(context, 'An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(scale: _scaleAnimation, child: _buildSuccessHeader()),
              const SizedBox(height: 20),
              _buildBankDetailsCard(),
              const SizedBox(height: 18),
              _buildConfirmationCheckbox(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppConstants.primaryColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Confirm Details',
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

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.verified, color: Colors.green.shade600, size: 36),
          const SizedBox(height: 10),
          Text(
            'Verification Complete!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your bank account has been successfully verified. Please review and confirm.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.green.shade700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: AppConstants.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'Bank Account Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._buildDetailRows(),
        ],
      ),
    );
  }

  List<Widget> _buildDetailRows() {
    final details = [
      ('Account Holder Name', widget.bankData?.accountHolderName ?? 'John Doe', Icons.person_outline),
      ('Bank Name', widget.bankData?.bankName ?? 'State Bank of India', Icons.account_balance_outlined),
      ('Branch', widget.bankData?.branch ?? 'New Delhi Main Branch', Icons.location_city_outlined),
      ('Account Number', _maskAccountNumber(widget.accountNumber), Icons.credit_card_outlined),
      ('IFSC Code', widget.ifscCode, Icons.code),
    ];

    return details.asMap().entries.map((entry) {
      final isLast = entry.key == details.length - 1;
      final (label, value, icon) = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppConstants.primaryColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildConfirmationCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _isDetailsConfirmed,
              onChanged: (value) => setState(() => _isDetailsConfirmed = value ?? false),
              activeColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmation Required',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'I confirm that the above bank details are correct and I authorize the use of this account for transactions.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : (_isDetailsConfirmed ? _submitBankDetails : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDetailsConfirmed ? AppConstants.primaryColor : Colors.grey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Submitting...',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Confirm & Submit',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    final visiblePart = accountNumber.substring(accountNumber.length - 4);
    final maskedPart = '*' * (accountNumber.length - 4);
    return maskedPart + visiblePart;
  }
}