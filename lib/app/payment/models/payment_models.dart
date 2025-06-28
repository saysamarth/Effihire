enum PaymentStatus { pending, processing, paid }

class PaymentTransaction {
  final String companyName;
  final String deliveryAddress;
  final PaymentStatus status;
  final DateTime dateTime;
  final double amount;

  PaymentTransaction({
    required this.companyName,
    required this.deliveryAddress,
    required this.status,
    required this.dateTime,
    required this.amount,
  });
}

class PaymentOverviewData {
  final double totalEarnings;
  final double thisMonthEarnings;
  final double pendingAmount;
  final double inProgressAmount;

  PaymentOverviewData({
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.pendingAmount,
    required this.inProgressAmount,
  });
}

class PaymentFilters {
  final String dateRange;
  final String company;
  final String status;
  final String sort;
  final DateTime? customFromDate;
  final DateTime? customToDate;

  PaymentFilters({
    this.dateRange = 'Last Week',
    this.company = 'All Companies',
    this.status = 'All Status',
    this.sort = 'Newest',
    this.customFromDate,
    this.customToDate,
  });

  PaymentFilters copyWith({
    String? dateRange,
    String? company,
    String? status,
    String? sort,
    DateTime? customFromDate,
    DateTime? customToDate,
  }) {
    return PaymentFilters(
      dateRange: dateRange ?? this.dateRange,
      company: company ?? this.company,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      customFromDate: customFromDate ?? this.customFromDate,
      customToDate: customToDate ?? this.customToDate,
    );
  }
}