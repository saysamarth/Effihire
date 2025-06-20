import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/bank_model.dart';
import 'bank_service.dart';

class BankVerificationController extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  bool _isVerified = false;
  bool _isDetailsConfirmed = false;
  BankVerificationData? _verifiedBankData;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isVerified => _isVerified;
  bool get isDetailsConfirmed => _isDetailsConfirmed;
  BankVerificationData? get verifiedBankData => _verifiedBankData;
  String? get errorMessage => _errorMessage;

  // Bank verification method
  Future<bool> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Use real API service or simulation based on environment
      BankVerificationResponse response;

      if (kDebugMode) {
        // Use simulation in debug mode for development
        response = await _simulateVerificationAPI(
          BankVerificationRequest(
            accountNumber: accountNumber,
            ifscCode: ifscCode,
          ),
        );
      } else {
        // Use real API service in production
        response = await BankVerificationService.verifyBankAccount(
          accountNumber: accountNumber,
          ifscCode: ifscCode,
        );
      }

      if (response.success && response.data != null) {
        _verifiedBankData = response.data;
        _isVerified = true;
        notifyListeners();
        return true;
      } else {
        _setError(
          BankVerificationService.getUserFriendlyErrorMessage(
            response.errorCode,
          ),
        );
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Submit bank details method - Fixed validation logic
  Future<bool> submitBankDetails() async {
    // Improved validation with better error messages
    if (_verifiedBankData == null) {
      _setError('Bank details not verified. Please verify first.');
      return false;
    }

    if (!_isVerified) {
      _setError('Bank verification is not complete.');
      return false;
    }

    if (!_isDetailsConfirmed) {
      _setError('Please confirm bank details before submitting.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      bool success;

      if (kDebugMode) {
        // Use simulation in debug mode
        success = await _simulateSubmissionAPI(_verifiedBankData!);
      } else {
        // Use real API service in production
        success = await BankVerificationService.submitBankDetails(
          bankData: _verifiedBankData!,
        );
      }

      if (success) {
        // Don't reset state immediately - let UI handle it
        debugPrint('Bank details submitted successfully');
        return true;
      } else {
        _setError('Failed to submit bank details. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Simulated API call for verification (dummy data)
  Future<BankVerificationResponse> _simulateVerificationAPI(
    BankVerificationRequest request,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different responses based on IFSC code for testing
    if (request.ifscCode.startsWith('SBIN')) {
      return BankVerificationResponse(
        success: true,
        message: 'Bank details verified successfully',
        data: BankVerificationData(
          accountNumber: request.accountNumber,
          ifscCode: request.ifscCode,
          accountHolderName: 'John Doe',
          bankName: 'State Bank of India',
          branch: 'New Delhi Main Branch',
          isVerified: true,
          verificationDate: DateTime.now(),
        ),
      );
    } else if (request.ifscCode.startsWith('HDFC')) {
      return BankVerificationResponse(
        success: true,
        message: 'Bank details verified successfully',
        data: BankVerificationData(
          accountNumber: request.accountNumber,
          ifscCode: request.ifscCode,
          accountHolderName: 'Jane Smith',
          bankName: 'HDFC Bank',
          branch: 'Mumbai Central Branch',
          isVerified: true,
          verificationDate: DateTime.now(),
        ),
      );
    } else if (request.ifscCode.startsWith('ICIC')) {
      return BankVerificationResponse(
        success: true,
        message: 'Bank details verified successfully',
        data: BankVerificationData(
          accountNumber: request.accountNumber,
          ifscCode: request.ifscCode,
          accountHolderName: 'Rajesh Kumar',
          bankName: 'ICICI Bank',
          branch: 'Bangalore Electronic City',
          isVerified: true,
          verificationDate: DateTime.now(),
        ),
      );
    } else {
      // Simulate verification failure for other IFSC codes
      return BankVerificationResponse(
        success: false,
        message:
            'Bank details could not be verified. Please check your account number and IFSC code.',
        errorCode: 'VERIFICATION_FAILED',
      );
    }
  }

  // Simulated API call for submission (dummy response)
  Future<bool> _simulateSubmissionAPI(BankVerificationData bankData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Add some random failure for testing (5% chance)
    if (DateTime.now().millisecond % 20 == 0) {
      return false;
    }

    // Simulate success for demonstration
    return true;
  }

  // State management methods
  void updateConfirmationStatus(bool isConfirmed) {
    _isDetailsConfirmed = isConfirmed;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _resetState() {
    _isVerified = false;
    _isDetailsConfirmed = false;
    _verifiedBankData = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset verification (useful for re-verification)
  void resetVerification() {
    _resetState();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  // Utility methods for validation
  static bool isValidAccountNumber(String accountNumber) {
    return accountNumber.length >= 8 &&
        accountNumber.length <= 25 &&
        RegExp(r'^\d+$').hasMatch(accountNumber);
  }

  static bool isValidIFSC(String ifsc) {
    return ifsc.length == 11 && RegExp(r'^[A-Z]{4}0\w{6}$').hasMatch(ifsc);
  }

  // Improved setter methods with validation
  void setVerifiedBankData(BankVerificationData? data) {
    _verifiedBankData = data;
    if (data != null) {
      _isVerified = data.isVerified;
    }
    notifyListeners();
  }

  void setVerificationStatus(bool status) {
    _isVerified = status;
    notifyListeners();
  }

  // Additional utility method to check if ready for submission
  bool get isReadyForSubmission {
    return _isVerified &&
        _verifiedBankData != null &&
        _isDetailsConfirmed &&
        !_isLoading;
  }

  // Method to get formatted bank details for display
  Map<String, String> get formattedBankDetails {
    if (_verifiedBankData == null) return {};

    return {
      'Account Holder': ?_verifiedBankData!.accountHolderName,
      'Bank Name': ?_verifiedBankData!.bankName,
      'Branch': ?_verifiedBankData!.branch,
      'Account Number': _verifiedBankData!.accountNumber,
      'IFSC Code': _verifiedBankData!.ifscCode,
    };
  }
}
