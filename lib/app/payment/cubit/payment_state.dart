// cubit/payment_state.dart
import 'package:equatable/equatable.dart';
import '../models/payment_models.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentTransaction> allTransactions;
  final List<PaymentTransaction> filteredTransactions;
  final PaymentFilters filters;
  final List<String> companies;

  const PaymentLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.filters,
    required this.companies,
  });

  PaymentLoaded copyWith({
    List<PaymentTransaction>? allTransactions,
    List<PaymentTransaction>? filteredTransactions,
    PaymentFilters? filters,
    List<String>? companies,
  }) {
    return PaymentLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      filters: filters ?? this.filters,
      companies: companies ?? this.companies,
    );
  }

  @override
  List<Object?> get props => [
    allTransactions,
    filteredTransactions,
    filters,
    companies,
  ];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
