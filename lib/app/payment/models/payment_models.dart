// models/payment_models.dart
import 'package:equatable/equatable.dart';

enum PaymentStatus { paid, processing, pending }

class PaymentTransaction extends Equatable {
  final String companyName;
  final String deliveryAddress;
  final PaymentStatus status;
  final DateTime dateTime;
  final double amount;

  const PaymentTransaction({
    required this.companyName,
    required this.deliveryAddress,
    required this.status,
    required this.dateTime,
    required this.amount,
  });

  @override
  List<Object> get props => [
    companyName,
    deliveryAddress,
    status,
    dateTime,
    amount,
  ];
}

class PaymentFilters extends Equatable {
  final String dateRange;
  final String company;
  final String status;
  final String sort;
  final DateTime? customFromDate;
  final DateTime? customToDate;

  const PaymentFilters({
    required this.dateRange,
    required this.company,
    required this.status,
    required this.sort,
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

  @override
  List<Object?> get props => [
    dateRange,
    company,
    status,
    sort,
    customFromDate,
    customToDate,
  ];
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
