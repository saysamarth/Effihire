import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OpportunityFilters {
  final String company;
  final String paymentRange;
  final String distance;
  final String workType;
  final String sort;

  const OpportunityFilters({
    this.company = 'All Companies',
    this.paymentRange = 'All Ranges',
    this.distance = 'All Distances',
    this.workType = 'All Types',
    this.sort = 'Nearest First',
  });

  OpportunityFilters copyWith({
    String? company,
    String? paymentRange,
    String? distance,
    String? workType,
    String? sort,
  }) {
    return OpportunityFilters(
      company: company ?? this.company,
      paymentRange: paymentRange ?? this.paymentRange,
      distance: distance ?? this.distance,
      workType: workType ?? this.workType,
      sort: sort ?? this.sort,
    );
  }
}

class OpportunityFiltersWidget extends StatefulWidget {
  final OpportunityFilters currentFilters;
  final Function(OpportunityFilters) onFiltersChanged;
  final List<String> availableCompanies;

  const OpportunityFiltersWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
    required this.availableCompanies,
  });

  @override
  State<OpportunityFiltersWidget> createState() =>
      _OpportunityFiltersWidgetState();
}

class _OpportunityFiltersWidgetState extends State<OpportunityFiltersWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earning Potential',
              style: GoogleFonts.plusJakartaSans(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            if (_hasActiveFilters())
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5B3E86),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Company',
                  value: widget.currentFilters.company,
                  isSelected: widget.currentFilters.company != 'All Companies',
                  onTap: () => _showCompanyOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Payment',
                  value: widget.currentFilters.paymentRange,
                  isSelected:
                      widget.currentFilters.paymentRange != 'All Ranges',
                  onTap: () => _showPaymentOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Distance',
                  value: widget.currentFilters.distance,
                  isSelected: widget.currentFilters.distance != 'All Distances',
                  onTap: () => _showDistanceOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Work Type',
                  value: widget.currentFilters.workType,
                  isSelected: widget.currentFilters.workType != 'All Types',
                  onTap: () => _showWorkTypeOptions(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Sort By',
                  value: widget.currentFilters.sort,
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
              ? const Color(0xFF5B3E86).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B3E86)
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF5B3E86)
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
                  ? const Color(0xFF5B3E86)
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompanyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Company',
        options: widget.availableCompanies,
        selectedValue: widget.currentFilters.company,
        onSelected: (value) {
          final newFilters = widget.currentFilters.copyWith(company: value);
          widget.onFiltersChanged(newFilters);
        },
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Payment Range',
        options: [
          'All Ranges',
          'Under ₹5,000',
          '₹5,000 - ₹10,000',
          '₹10,000 - ₹20,000',
          '₹20,000 - ₹30,000',
          'Above ₹30,000',
        ],
        selectedValue: widget.currentFilters.paymentRange,
        onSelected: (value) {
          final newFilters = widget.currentFilters.copyWith(
            paymentRange: value,
          );
          widget.onFiltersChanged(newFilters);
        },
      ),
    );
  }

  void _showDistanceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Distance',
        options: [
          'All Distances',
          'Within 2 km',
          'Within 5 km',
          'Within 10 km',
          'Within 20 km',
          'Any Distance',
        ],
        selectedValue: widget.currentFilters.distance,
        onSelected: (value) {
          final newFilters = widget.currentFilters.copyWith(distance: value);
          widget.onFiltersChanged(newFilters);
        },
      ),
    );
  }

  void _showWorkTypeOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Work Type',
        options: [
          'All Types',
          'Full Time',
          'Part Time',
          'Flexible Hours',
          'Contract',
          'Gig Work',
        ],
        selectedValue: widget.currentFilters.workType,
        onSelected: (value) {
          final newFilters = widget.currentFilters.copyWith(workType: value);
          widget.onFiltersChanged(newFilters);
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
        options: [
          'Nearest First',
          'Highest Pay',
          'Lowest Pay',
          'Most Recent',
          'Company A-Z',
          'Company Z-A',
        ],
        selectedValue: widget.currentFilters.sort,
        onSelected: (value) {
          final newFilters = widget.currentFilters.copyWith(sort: value);
          widget.onFiltersChanged(newFilters);
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
                  style: GoogleFonts.plusJakartaSans(
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
                ? const Color(0xFF5B3E86).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF5B3E86)
                      : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check, size: 18, color: Color(0xFF5B3E86)),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.currentFilters.company != 'All Companies' ||
        widget.currentFilters.paymentRange != 'All Ranges' ||
        widget.currentFilters.distance != 'All Distances' ||
        widget.currentFilters.workType != 'All Types';
  }

  void _clearFilters() {
    const clearedFilters = OpportunityFilters();
    widget.onFiltersChanged(clearedFilters);
  }
}
