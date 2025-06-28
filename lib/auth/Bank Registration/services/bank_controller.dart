import 'package:flutter/foundation.dart';
import 'ifsc_service.dart';
import '../models/bank_model.dart';

class BankVerificationController extends ChangeNotifier {
  final IFSCService _ifscService = IFSCService();
  // State variables for IFSC lookup
  bool _isFetchingBankInfo = false;
  BankDetails? _fetchedBankDetails;
  String? _bankInfoError;

  // State variables for bank verification (penny drop)
  bool _isVerifying = false;
  BankVerificationData? _verifiedBankData;
  String? _verificationError;

  // User confirmation state
  bool _isConfirmed = false;

  // Getters for IFSC lookup state
  bool get isFetchingBankInfo => _isFetchingBankInfo;
  BankDetails? get fetchedBankDetails => _fetchedBankDetails;
  String? get bankInfoError => _bankInfoError;
  bool get hasBankInfo => _fetchedBankDetails != null;

  // Getters for verification state
  bool get isVerifying => _isVerifying;
  bool get isLoading => _isFetchingBankInfo || _isVerifying;
  BankVerificationData? get verifiedBankData => _verifiedBankData;
  String? get verificationError => _verificationError;

  // Getters for confirmation state
  bool get isConfirmed => _isConfirmed;
  bool get canProceedToVerification => hasBankInfo && _isConfirmed;

  /// Fetches bank details using IFSC code
  Future<bool> fetchBankDetails(String ifscCode) async {
    _setFetchingBankInfo(true);
    _clearBankInfoError();

    try {
      final bankDetails = await _ifscService.fetchBankDetails(ifscCode);
      _fetchedBankDetails = bankDetails;
      _setFetchingBankInfo(false);
      return true;
    } catch (e) {
      _bankInfoError = e.toString();
      _fetchedBankDetails = null;
      _setFetchingBankInfo(false);
      return false;
    }
  }

  /// Validates IFSC format before attempting fetch
  bool validateIFSCFormat(String ifscCode) {
    return _ifscService.isValidIFSC(ifscCode);
  }

  /// Sets user confirmation status
  void setConfirmation(bool isConfirmed) {
    _isConfirmed = isConfirmed;
    notifyListeners();
  }

  /// Clears fetched bank details (when user wants to edit)
  void clearBankDetails() {
    _fetchedBankDetails = null;
    _bankInfoError = null;
    _isConfirmed = false;
    notifyListeners();
  }

  /// Performs bank account verification (penny drop)
  // Replace the verifyBankAccount method in BankVerificationController
  Future<bool> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
  }) async {
    if (!canProceedToVerification) {
      _verificationError = 'Please confirm bank details before proceeding';
      notifyListeners();
      return false;
    }

    _setVerifying(true);
    _clearVerificationError();

    try {
      // This is a placeholder for the actual verification logic. Replace with actual penny drop API call
      await Future.delayed(const Duration(seconds: 2));

      _verifiedBankData = BankVerificationData(
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        accountHolderName:
            'Mock Account Holder', // This would come from your penny drop API
        bankName: _fetchedBankDetails?.bankName ?? 'Unknown Bank',
        branch: _fetchedBankDetails?.branch ?? 'Unknown Branch',
        isVerified: true,
        verificationDate: DateTime.now(),
      );
      _setVerifying(false);
      return true;
    } catch (e) {
      _verificationError = 'Verification failed: ${e.toString()}';
      _setVerifying(false);
      return false;
    }
  }

  void clearVerificationData() {
    _verifiedBankData = null;
    _verificationError = null;
    notifyListeners();
  }

  void resetAll() {
    _fetchedBankDetails = null;
    _bankInfoError = null;
    _verifiedBankData = null;
    _verificationError = null;
    _isConfirmed = false;
    _isFetchingBankInfo = false;
    _isVerifying = false;
    notifyListeners();
  }

  void _setFetchingBankInfo(bool loading) {
    _isFetchingBankInfo = loading;
    notifyListeners();
  }

  void _setVerifying(bool loading) {
    _isVerifying = loading;
    notifyListeners();
  }

  void _clearBankInfoError() {
    _bankInfoError = null;
    notifyListeners();
  }

  void _clearVerificationError() {
    _verificationError = null;
    notifyListeners();
  }
}

extension BankDetailsExtension on BankDetails {
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'branch': branch,
      'address': address,
      'city': city,
      'state': state,
      'contact': contact,
      'ifscCode': ifscCode,
    };
  }
}
