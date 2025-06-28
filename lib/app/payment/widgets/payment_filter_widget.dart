import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payment_models.dart';

class PaymentFiltersWidget extends StatefulWidget {
  final PaymentFilters filters;
  final Function(PaymentFilters) onFiltersChanged;
  final List<String> companies;

  const PaymentFiltersWidget({
    Key? key,
    required this.filters,
    required this.onFiltersChanged,
    required this.companies,
  }) : super(key: key);

  @override
  State<PaymentFiltersWidget> createState() => _PaymentFiltersWidgetState();
}

class _PaymentFiltersWidgetState extends State<PaymentFiltersWidget> {
  @override
  Widget build(BuildContext context) {
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
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 91, 42, 134),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showApplyFiltersMessage(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Date Range',
                  value: widget.filters.dateRange,
                  isSelected: true,
                  onTap: () => _showDateRangeOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Company',
                  value: widget.filters.company,
                  isSelected: widget.filters.company != 'All Companies',
                  onTap: () => _showCompanyOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Status',
                  value: widget.filters.status,
                  isSelected: widget.filters.status != 'All Status',
                  onTap: () => _showStatusOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Sort By',
                  value: widget.filters.sort,
                  isSelected: true,
                  onTap: () => _showSortOptions(),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showDateRangeOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Date Range',
        options: ['Today', 'Last Week', 'Last Month', 'Custom'],
        selectedValue: widget.filters.dateRange,
        onSelected: (value) {
            widget.onFiltersChanged(widget.filters.copyWith(dateRange: value));
        },
      ),
    );
  }

  void _showCompanyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Company',
        options: widget.companies,
        selectedValue: widget.filters.company,
        onSelected: (value) {
          widget.onFiltersChanged(widget.filters.copyWith(company: value));
        },
      ),
    );
  }

  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Status',
        options: ['All Status', 'Paid', 'Processing', 'Pending'],
        selectedValue: widget.filters.status,
        onSelected: (value) {
          widget.onFiltersChanged(widget.filters.copyWith(status: value));
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Sort By',
        options: ['Newest', 'Oldest', 'Highest Paid', 'Lowest Paid'],
        selectedValue: widget.filters.sort,
        onSelected: (value) {
          widget.onFiltersChanged(widget.filters.copyWith(sort: value));
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                ...options
                    .map(
                      (option) => _buildFilterOption(
                        option,
                        selectedValue == option,
                        () {
                          onSelected(option);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
                const SizedBox(height: 10),
              ],
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

  void _showApplyFiltersMessage(BuildContext context) {
    _showSnackBar(context, 'Filters applied successfully');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 91, 42, 134),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}