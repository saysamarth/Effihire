import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../models/payment_models.dart';

class TransactionListWidget extends StatelessWidget {
  const TransactionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 91, 42, 134),
            ),
          );
        }

        if (state is PaymentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading transactions',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is PaymentLoaded) {
          final transactions = state.filteredTransactions;

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              ...transactions.map(
                (transaction) => Column(
                  children: [
                    _buildTransactionCard(transaction),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Load More Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 91, 42, 134),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Add your load more logic here
                      // Example: context.read<PaymentCubit>().loadMore();
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color.fromARGB(255, 91, 42, 134),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Load More Transactions',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 91, 42, 134),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters to see more results',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Company Logo/Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCompanyColor(
                    transaction.companyName,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCompanyIcon(transaction.companyName),
                  color: _getCompanyColor(transaction.companyName),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.companyName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction.deliveryAddress,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildPaymentStatusBadge(transaction.status),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(transaction.dateTime),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const Spacer(),
              Text(
                '₹${transaction.amount.toStringAsFixed(0)}', // Direct INR amount
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case PaymentStatus.paid:
        color = Colors.green;
        text = 'Paid';
        icon = Icons.check_circle;
        break;
      case PaymentStatus.processing:
        color = const Color.fromARGB(255, 91, 42, 134);
        text = 'Processing';
        icon = Icons.sync;
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompanyColor(String companyName) {
    switch (companyName.toLowerCase()) {
      case 'swiggy':
      case 'swiggy instamart':
        return const Color(0xFFFF6B35);
      case 'zomato':
        return const Color(0xFFE23744);
      case 'dunzo':
        return const Color(0xFF00C851);
      case 'bigbasket':
        return const Color(0xFF84C441);
      case 'blinkit':
        return const Color(0xFFF8E71C);
      case 'zepto':
        return const Color(0xFF9C4FBE);
      case 'amazon fresh':
        return const Color(0xFFFF9900);
      case 'flipkart quick':
        return const Color(0xFF2874F0);
      case 'uber eats':
        return const Color(0xFF000000);
      default:
        return const Color.fromARGB(255, 91, 42, 134);
    }
  }

  IconData _getCompanyIcon(String companyName) {
    switch (companyName.toLowerCase()) {
      case 'swiggy':
      case 'zomato':
      case 'uber eats':
        return Icons.restaurant;
      case 'swiggy instamart':
      case 'dunzo':
      case 'bigbasket':
      case 'blinkit':
      case 'zepto':
      case 'amazon fresh':
      case 'flipkart quick':
        return Icons.shopping_bag;
      default:
        return Icons.delivery_dining;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
