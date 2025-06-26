import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Auth state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // UI state
  bool _isOtpSent = false;
  bool _isLoading = false;

  // Timer state
  Timer? _resendTimer;
  bool _canResend = true;
  int _resendCountdown = 0;
  static const int _resendDuration = 30;

  // Animations
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _stopResendTimer();
    super.dispose();
  }

  // ================== ANIMATION SETUP ==================

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  void _startAnimations() async {
    if (!mounted) return;

    await Future.delayed(Duration(milliseconds: 100));
    if (mounted) _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    if (mounted) _slideController.forward();
  }

  // ================== TIMER MANAGEMENT ==================

  void _startResendTimer() {
    _stopResendTimer();

    setState(() {
      _canResend = false;
      _resendCountdown = _resendDuration;
    });

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        _stopResendTimer();
        if (mounted) {
          setState(() => _canResend = true);
        }
      }
    });
  }

  void _stopResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  // ================== PHONE VALIDATION ==================

  bool _isValidPhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  bool _isValidOtp(String otp) {
    return otp.trim().length == 6 && RegExp(r'^[0-9]+$').hasMatch(otp.trim());
  }

  // ================== UI STATE MANAGEMENT ==================

  void _resetToPhoneEntry() {
    _stopResendTimer();
    setState(() {
      _isOtpSent = false;
      _canResend = true;
      _resendCountdown = 0;
      _verificationId = null;
      _resendToken = null;
      _isLoading = false;
    });
    _otpController.clear();
  }

  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  // ================== ERROR HANDLING ==================

  String _getErrorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-phone-number' => 'The phone number is not valid.',
      'too-many-requests' => 'Too many requests. Please try again later.',
      'quota-exceeded' => 'SMS quota exceeded. Contact support.',
      'app-not-authorized' =>
        'App not authorized. Check Firebase configuration.',
      'network-request-failed' =>
        'Network error. Check your internet connection.',
      'invalid-verification-code' => 'Invalid OTP. Please check and try again.',
      'session-expired' => 'OTP expired. Please request a new one.',
      _ => 'An error occurred. Please try again.',
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color.fromARGB(255, 91, 42, 134),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ================== CORE AUTH FUNCTIONS ==================

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();

    // Validate phone number
    if (!_isValidPhoneNumber(phoneNumber)) {
      _showMessage('Please enter a valid 10-digit phone number');
      return;
    }

    // Check if we can send (not in cooldown)
    if (!_canResend && _isOtpSent) {
      _showMessage('Wait $_resendCountdown seconds before resending');
      return;
    }

    // Prevent multiple simultaneous requests
    if (_isLoading) return;

    _setLoadingState(true);
    _startResendTimer();

    try {
      final formattedPhoneNumber = '+91$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
        forceResendingToken: _resendToken,
        timeout: Duration(seconds: 40),
      );
    } catch (e) {
      _handleSendOtpError(e);
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    if (!mounted) return;
    await _signInWithCredential(credential);
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    if (!mounted) return;

    _setLoadingState(false);
    _stopResendTimer();
    setState(() => _canResend = true);
    _showMessage(_getErrorMessage(e));
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
      _verificationId = verificationId;
      _resendToken = resendToken;
    });

    _showMessage('OTP sent successfully!');
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    if (!mounted) return;

    _verificationId = verificationId;

    // If OTP screen not shown yet, proceed to OTP entry
    if (!_isOtpSent) {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      _showMessage('Enter the OTP sent to your phone');
    } else {
      _setLoadingState(false);
    }
  }

  void _handleSendOtpError(dynamic error) {
    if (!mounted) return;

    _setLoadingState(false);
    _stopResendTimer();
    setState(() => _canResend = true);
    _showMessage('Failed to send OTP. Please try again.');
  }

  Future<void> _verifyOtp() async {
    final otpCode = _otpController.text.trim();

    // Validate OTP
    if (!_isValidOtp(otpCode)) {
      _showMessage('Please enter a valid 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showMessage('Please request OTP first');
      return;
    }

    _setLoadingState(true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      await _signInWithCredential(credential);
    } catch (e) {
      _handleVerifyOtpError(e);
    }
  }

  void _handleVerifyOtpError(dynamic error) {
    if (!mounted) return;

    _setLoadingState(false);

    if (error is FirebaseAuthException) {
      if (error.code == 'session-expired') {
        _resetToPhoneEntry();
      }
      _showMessage(_getErrorMessage(error));
    } else {
      _showMessage('Invalid OTP. Please try again.');
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      _setLoadingState(false);

      if (userCredential.user != null) {
        _showMessage('Login successful!');
        _stopResendTimer();

        // Navigate to home with replacement to prevent back navigation
        if (mounted) {
          context.go('/location');
        }
      } else {
        _showMessage('Authentication failed. Please try again.');
      }
    } catch (e) {
      _setLoadingState(false);
      if (e is FirebaseAuthException) {
        _showMessage(_getErrorMessage(e));
      } else {
        _showMessage('Authentication failed. Please try again.');
      }
    }
  }

  // ================== EVENT HANDLERS ==================

  void _onEditPhoneNumber() {
    if (_isLoading) return;
    _resetToPhoneEntry();
  }

  void _onLoginButtonPressed() {
    if (_isLoading) return;

    if (_isOtpSent) {
      _verifyOtp();
    } else {
      _sendOtp();
    }
  }

  void _onResendOtp() {
    if (_isLoading || !_canResend) return;
    _sendOtp();
  }

  // ================== UI BUILDERS ==================

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 91, 42, 134), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildLoginCard(screenWidth),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(double screenWidth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            _buildHeader(),
            SizedBox(height: 40),
            _buildPhoneNumberSection(),
            if (_isOtpSent) ...[SizedBox(height: 20), _buildOtpSection()],
            SizedBox(height: 30),
            _buildLoginButton(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your phone number to receive an OTP for secure login',
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
            enabled: !_isOtpSent,
          ),
        ),
        if (_isOtpSent) ...[SizedBox(width: 10), _buildEditButton()],
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: IconButton(
        onPressed: _isLoading ? null : _onEditPhoneNumber,
        icon: Icon(
          Icons.edit,
          color: _isLoading ? Colors.grey : Colors.blue,
          size: 20,
        ),
        tooltip: 'Edit phone number',
      ),
    );
  }

  Widget _buildOtpSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _otpController,
          label: 'Enter OTP',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.security,
          maxLength: 6,
        ),
        SizedBox(height: 15),
        _buildResendSection(),
      ],
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _canResend
                ? "Didn't receive OTP?"
                : "Resend OTP in ${_resendCountdown}s",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        TextButton.icon(
          onPressed: (_canResend && !_isLoading) ? _onResendOtp : null,
          icon: Icon(
            Icons.refresh,
            size: 16,
            color: (_canResend && !_isLoading)
                ? Color(0xFFFFA726)
                : Colors.grey,
          ),
          label: Text(
            'Resend OTP',
            style: TextStyle(
              color: (_canResend && !_isLoading)
                  ? Color(0xFFFFA726)
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    bool enabled = true,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            prefixIcon,
            color: enabled ? Color(0xFFFFA726) : Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLoginButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isOtpSent ? 'Verify OTP' : 'Send OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}