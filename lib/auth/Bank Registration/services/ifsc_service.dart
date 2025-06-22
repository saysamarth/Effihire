import 'package:razorpay_ifsc/razorpay_ifsc.dart';

class IFSCService {
  static final IFSCService _instance = IFSCService._internal();
  factory IFSCService() => _instance;
  IFSCService._internal();
  final ifscRazorpay = RazorpayIfsc();
  bool isValidIFSC(String ifsc) {
    return ifsc.length == 11 && 
           RegExp(r'^[A-Z]{4}0\w{6}$').hasMatch(ifsc);
  }

  Future<BankDetails> fetchBankDetails(String ifscCode) async {
    try {
      if (!isValidIFSC(ifscCode)) {
        throw IFSCException('Invalid IFSC code format');
      }
      final razorpayBankDetails = await ifscRazorpay.getBankDetails(ifscCode.toUpperCase());  
      return BankDetails.fromRazorpayResponse(razorpayBankDetails, ifscCode);
    } catch (e) {
      if (e is IFSCException) {
        rethrow;
      }
      throw IFSCException('Failed to fetch bank details: ${e.toString()}');
    }
  }
}

class IFSCException implements Exception {
  final String message;
  IFSCException(this.message);
  
  @override
  String toString() => message;
}

class BankDetails {
  final String bankName;
  final String branch;
  final String address;
  final String city;
  final String state;
  final String contact;
  final String ifscCode;

  BankDetails({
    required this.bankName,
    required this.branch,
    required this.address,
    required this.city,
    required this.state,
    required this.contact,
    required this.ifscCode,
  });

  factory BankDetails.fromRazorpayResponse(dynamic response, [String? fallbackIfsc]) {
    if (response is Map<String, dynamic>) {
      return BankDetails(
        bankName: response['BANK'] ?? 'Unknown Bank',
        branch: response['BRANCH'] ?? 'Unknown Branch',
        address: response['ADDRESS'] ?? 'Address not available',
        city: response['CITY'] ?? 'Unknown City',
        state: response['STATE'] ?? 'Unknown State',
        contact: response['CONTACT'] ?? 'Not available',
        ifscCode: response['IFSC'] ?? fallbackIfsc ?? '',
      );
    }
    try {
      return BankDetails(
        bankName: response.bank ?? response.bankName ?? 'Unknown Bank',
        branch: response.branch ?? 'Unknown Branch',
        address: response.address ?? 'Address not available',
        city: response.city ?? 'Unknown City',
        state: response.state ?? 'Unknown State',
        contact: response.contact ?? response.phone ?? 'Not available',
        ifscCode: response.ifsc ?? response.ifscCode ?? fallbackIfsc ?? '',
      );
    } catch (e) {
      return BankDetails(
        bankName: 'Unknown Bank',
        branch: 'Unknown Branch',
        address: 'Address not available',
        city: 'Unknown City',
        state: 'Unknown State',
        contact: 'Not available',
        ifscCode: fallbackIfsc ?? '',
      );
    }
  }
  bool get isValid => 
      bankName.isNotEmpty && 
      branch.isNotEmpty && 
      ifscCode.isNotEmpty;

  @override
  String toString() {
    return 'BankDetails(bank: $bankName, branch: $branch, city: $city, state: $state, ifsc: $ifscCode)';
  }
}