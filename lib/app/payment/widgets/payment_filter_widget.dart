// widgets/payment_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../models/payment_models.dart';

class PaymentFiltersWidget extends StatefulWidget {
  const PaymentFiltersWidget({super.key});

  @override
  State<PaymentFiltersWidget> createState() => _PaymentFiltersWidgetState();
}

class _PaymentFiltersWidgetState extends State<PaymentFiltersWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is! PaymentLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Date Range',
                      value: state.filters.dateRange,
                      isSelected: true,
                      onTap: () => _showDateRangeOptions(state.filters),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Company',
                      value: state.filters.company,
                      isSelected: state.filters.company != 'All Companies',
                      onTap: () =>
                          _showCompanyOptions(state.filters, state.companies),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Status',
                      value: state.filters.status,
                      isSelected: state.filters.status != 'All Status',
                      onTap: () => _showStatusOptions(state.filters),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Sort By',
                      value: state.filters.sort,
                      isSelected: true,
                      onTap: () => _showSortOptions(state.filters),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 91, 42, 134).withAlpha(10)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 91, 42, 134)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color.fromARGB(255, 91, 42, 134)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected
                  ? const Color.fromARGB(255, 91, 42, 134)
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangeOptions(PaymentFilters currentFilters) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Date Range',
        options: ['Today', 'Last Week', 'Last Month', 'Custom'],
        selectedValue: currentFilters.dateRange,
        onSelected: (value) {
          final newFilters = currentFilters.copyWith(dateRange: value);
          context.read<PaymentCubit>().applyFilters(newFilters);
        },
      ),
    );
  }

  void _showCompanyOptions(
    PaymentFilters currentFilters,
    List<String> companies,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Company',
        options: companies,
        selectedValue: currentFilters.company,
        onSelected: (value) {
          final newFilters = currentFilters.copyWith(company: value);
          context.read<PaymentCubit>().applyFilters(newFilters);
        },
      ),
    );
  }

  void _showStatusOptions(PaymentFilters currentFilters) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Status',
        options: ['All Status', 'Paid', 'Processing', 'Pending'],
        selectedValue: currentFilters.status,
        onSelected: (value) {
          final newFilters = currentFilters.copyWith(status: value);
          context.read<PaymentCubit>().applyFilters(newFilters);
        },
      ),
    );
  }

  void _showSortOptions(PaymentFilters currentFilters) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Sort By',
        options: ['Newest', 'Oldest', 'Highest Paid', 'Lowest Paid'],
        selectedValue: currentFilters.sort,
        onSelected: (value) {
          final newFilters = currentFilters.copyWith(sort: value);
          context.read<PaymentCubit>().applyFilters(newFilters);
        },
      ),
    );
  }

  Widget _buildFilterBottomSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    ...options.map(
                      (option) => _buildFilterOption(
                        option,
                        selectedValue == option,
                        () {
                          onSelected(option);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 91, 42, 134).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color.fromARGB(255, 91, 42, 134)
                      : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 18,
                  color: Color.fromARGB(255, 91, 42, 134),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
