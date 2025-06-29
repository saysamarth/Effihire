// cubit/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/payment_models.dart';
import '../services/payment_services.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentService _paymentService;

  PaymentCubit(this._paymentService) : super(PaymentInitial());

  Future<void> loadPayments() async {
    emit(PaymentLoading());

    try {
      final transactions = await _paymentService.getAllTransactions();
      final companies = await _paymentService.getCompanies();

      const initialFilters = PaymentFilters(
        dateRange: 'Last Week',
        company: 'All Companies',
        status: 'All Status',
        sort: 'Newest',
      );

      final filteredTransactions = _applyFilters(transactions, initialFilters);

      emit(
        PaymentLoaded(
          allTransactions: transactions,
          filteredTransactions: filteredTransactions,
          filters: initialFilters,
          companies: companies,
        ),
      );
    } catch (e) {
      emit(PaymentError('Failed to load payments: ${e.toString()}'));
    }
  }

  void applyFilters(PaymentFilters filters) {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      final filteredTransactions = _applyFilters(
        currentState.allTransactions,
        filters,
      );

      emit(
        currentState.copyWith(
          filters: filters,
          filteredTransactions: filteredTransactions,
        ),
      );
    }
  }

  List<PaymentTransaction> _applyFilters(
    List<PaymentTransaction> transactions,
    PaymentFilters filters,
  ) {
    var filtered = List<PaymentTransaction>.from(transactions);

    // Apply company filter
    if (filters.company != 'All Companies') {
      filtered = filtered
          .where((t) => t.companyName == filters.company)
          .toList();
    }

    // Apply status filter
    if (filters.status != 'All Status') {
      PaymentStatus? statusFilter;
      switch (filters.status) {
        case 'Paid':
          statusFilter = PaymentStatus.paid;
          break;
        case 'Processing':
          statusFilter = PaymentStatus.processing;
          break;
        case 'Pending':
          statusFilter = PaymentStatus.pending;
          break;
      }
      if (statusFilter != null) {
        filtered = filtered.where((t) => t.status == statusFilter).toList();
      }
    }

    // Apply date range filter
    final now = DateTime.now();
    DateTime? startDate;

    switch (filters.dateRange) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Last Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Custom':
        if (filters.customFromDate != null) {
          startDate = filters.customFromDate;
        }
        break;
    }

    if (startDate != null) {
      filtered = filtered.where((t) {
        if (filters.dateRange == 'Custom' && filters.customToDate != null) {
          return t.dateTime.isAfter(startDate!) &&
              t.dateTime.isBefore(
                filters.customToDate!.add(const Duration(days: 1)),
              );
        }
        return t.dateTime.isAfter(startDate!);
      }).toList();
    }

    // Apply sorting
    switch (filters.sort) {
      case 'Newest':
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'Highest Paid':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest Paid':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  void refreshData() {
    loadPayments();
  }
}
