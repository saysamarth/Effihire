import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/bank_model.dart';

class BankVerificationService {
  static const String _baseUrl = 'https://your-api-base-url.com';
  static const String _verifyEndpoint = '/api/bank/verify';
  static const String _submitEndpoint = '/api/bank/submit';
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'Authorization': 'Bearer ${AuthService.getToken()}',
    // 'X-API-Key': 'your-api-key',
  };

  /// Verify bank account details using Razorpay penny drop
  /// [accountNumber] - The bank account number to verify
  /// [ifscCode] - The IFSC code of the bank
  /// Returns [BankVerificationResponse] with verification result

  static Future<BankVerificationResponse> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
    String? userId,
  }) async {
    try {
      if (!_isValidAccountNumber(accountNumber)) {
        return BankVerificationResponse(
          success: false,
          message: 'Invalid account number format',
          errorCode: 'INVALID_ACCOUNT_NUMBER',
        );
      }

      if (!_isValidIFSC(ifscCode)) {
        return BankVerificationResponse(
          success: false,
          message: 'Invalid IFSC code format',
          errorCode: 'INVALID_IFSC',
        );
      }

      final request = BankVerificationRequest(
        accountNumber: accountNumber,
        ifscCode: ifscCode.toUpperCase(),
        userId: userId,
      );

      // Make API call
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_verifyEndpoint'),
            headers: _headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeoutDuration);

      return _parseVerificationResponse(response);

    } on SocketException {
      return BankVerificationResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        errorCode: 'NO_INTERNET',
      );
    } on TimeoutException {
      return BankVerificationResponse(
        success: false,
        message: 'Request timeout. Please try again.',
        errorCode: 'TIMEOUT',
      );
    } on FormatException {
      return BankVerificationResponse(
        success: false,
        message: 'Invalid response format from server.',
        errorCode: 'INVALID_RESPONSE',
      );
    } catch (e) { 
      debugPrint('Bank verification error: $e');
      return BankVerificationResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Submit verified bank details to backend
  /// [bankData] - The verified bank data to submit
  /// Returns [bool] indicating success or failure

  static Future<bool> submitBankDetails({
    required BankVerificationData bankData,
  }) async {
    try {
      if (!bankData.isVerified) {
        debugPrint('Cannot submit unverified bank details');
        return false;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl$_submitEndpoint'),
            headers: _headers,
            body: jsonEncode(bankData.toJson()),
          )
          .timeout(_timeoutDuration);

      return _parseSubmissionResponse(response);

    } on SocketException {
      debugPrint('No internet connection during submission');
      return false;
    } on TimeoutException {
      debugPrint('Submission request timeout');
      return false;
    } catch (e) {
      debugPrint('Bank submission error: $e');
      return false;
    }
  }

  static BankVerificationResponse _parseVerificationResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return BankVerificationResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        return BankVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid request parameters',
          errorCode: responseData['error_code'] ?? 'BAD_REQUEST',
        );
      } else if (response.statusCode == 401) {
        return BankVerificationResponse(
          success: false,
          message: 'Authentication failed. Please login again.',
          errorCode: 'UNAUTHORIZED',
        );
      } else if (response.statusCode == 429) {
        return BankVerificationResponse(
          success: false,
          message: 'Too many requests. Please try again later.',
          errorCode: 'RATE_LIMIT_EXCEEDED',
        );
      } else if (response.statusCode >= 500) {
        return BankVerificationResponse(
          success: false,
          message: 'Server error. Please try again later.',
          errorCode: 'SERVER_ERROR',
        );
      } else {
        return BankVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Verification failed',
          errorCode: responseData['error_code'] ?? 'VERIFICATION_FAILED',
        );
      }
    } catch (e) {
      debugPrint('Error parsing verification response: $e');
      return BankVerificationResponse(
        success: false,
        message: 'Invalid response from server',
        errorCode: 'PARSE_ERROR',
      );
    }
  }

  static bool _parseSubmissionResponse(http.Response response) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error parsing submission response: $e');
      return false;
    }
  }

  static bool _isValidAccountNumber(String accountNumber) {
    if (accountNumber.isEmpty) return false;
    if (accountNumber.length < 9 || accountNumber.length > 18) return false;
    return RegExp(r'^[0-9]+$').hasMatch(accountNumber);
  }

  static bool _isValidIFSC(String ifsc) {
    if (ifsc.isEmpty || ifsc.length != 11) return false;
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc);
  }

  static String getUserFriendlyErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'INVALID_ACCOUNT_NUMBER':
        return 'Please enter a valid account number (9-18 digits)';
      case 'INVALID_IFSC':
        return 'Please enter a valid IFSC code (11 characters)';
      case 'ACCOUNT_NOT_FOUND':
        return 'Account not found. Please check your details and try again.';
      case 'IFSC_NOT_FOUND':
        return 'IFSC code not found. Please check and try again.';
      case 'PENNY_DROP_FAILED':
        return 'Account verification failed. Please ensure your account is active.';
      case 'INSUFFICIENT_BALANCE':
        return 'Insufficient balance in account for verification.';
      case 'ACCOUNT_FROZEN':
        return 'This account appears to be frozen. Please contact your bank.';
      case 'NO_INTERNET':
        return 'No internet connection. Please check your network and try again.';
      case 'TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'RATE_LIMIT_EXCEEDED':
        return 'Too many verification attempts. Please try again after some time.';
      case 'UNAUTHORIZED':
        return 'Session expired. Please login again.';
      case 'SERVER_ERROR':
        return 'Server is temporarily unavailable. Please try again later.';
      default:
        return 'Verification failed. Please check your details and try again.';
    }
  }

  static Future<BankVerificationResponse> retryVerification({
    required String accountNumber,
    required String ifscCode,
    String? userId,
    int maxRetries = 3,
  }) async {
    BankVerificationResponse? lastResponse;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      lastResponse = await verifyBankAccount(
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        userId: userId,
      );

      if (lastResponse.success) {
        return lastResponse;
      }

      if (lastResponse.errorCode != null &&
          ['INVALID_ACCOUNT_NUMBER', 'INVALID_IFSC', 'UNAUTHORIZED', 'BAD_REQUEST']
              .contains(lastResponse.errorCode)) {
        break;
      }
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return lastResponse ?? BankVerificationResponse(
      success: false,
      message: 'All retry attempts failed',
      errorCode: 'MAX_RETRIES_EXCEEDED',
    );
  }
}