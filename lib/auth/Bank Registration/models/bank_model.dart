class BankVerificationData {
  final String accountNumber;
  final String ifscCode;
  final String? accountHolderName;
  final String? bankName;
  final String? branch;
  final bool isVerified;
  final DateTime? verificationDate;

  BankVerificationData({
    required this.accountNumber,
    required this.ifscCode,
    this.accountHolderName,
    this.bankName,
    this.branch,
    this.isVerified = false,
    this.verificationDate,
  });

  factory BankVerificationData.fromJson(Map<String, dynamic> json) {
    return BankVerificationData(
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      branch: json['branch'],
      isVerified: json['is_verified'] ?? false,
      verificationDate: json['verification_date'] != null
          ? DateTime.parse(json['verification_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch': branch,
      'is_verified': isVerified,
      'verification_date': verificationDate?.toIso8601String(),
    };
  }

  BankVerificationData copyWith({
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? bankName,
    String? branch,
    bool? isVerified,
    DateTime? verificationDate,
  }) {
    return BankVerificationData(
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branch: branch ?? this.branch,
      isVerified: isVerified ?? this.isVerified,
      verificationDate: verificationDate ?? this.verificationDate,
    );
  }
}

class BankVerificationRequest {
  final String accountNumber;
  final String ifscCode;
  final String? userId;

  BankVerificationRequest({
    required this.accountNumber,
    required this.ifscCode,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      if (userId != null) 'user_id': userId,
    };
  }
}

class BankVerificationResponse {
  final bool success;
  final String message;
  final BankVerificationData? data;
  final String? errorCode;

  BankVerificationResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory BankVerificationResponse.fromJson(Map<String, dynamic> json) {
    return BankVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? BankVerificationData.fromJson(json['data'])
          : null,
      errorCode: json['error_code'],
    );
  }
}