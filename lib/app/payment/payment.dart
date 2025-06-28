import 'package:effihire/app/payment/widgets/payment_filter_widget.dart';
import 'package:effihire/app/payment/widgets/payment_overview_card.dart';
import 'package:effihire/app/payment/widgets/transition_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './models/payment_models.dart';

class PaymentTab extends StatefulWidget {
  @override
  _PaymentTabState createState() => _PaymentTabState();
}

class _PaymentTabState extends State<PaymentTab> with TickerProviderStateMixin {
  String selectedDateRange = 'Last Week';
  String selectedCompany = 'All Companies';
  String selectedStatus = 'All Status';
  String selectedSort = 'Newest';
  DateTime? customFromDate;
  DateTime? customToDate;

  List<String> companies = [
    'All Companies',
    'TechCorp Solutions',
    'Digital Dynamics',
    'Innovation Hub',
    'StartupXYZ',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Overview Header Card
              PaymentOverviewCard(
                data: PaymentOverviewData(
                  totalEarnings: 52560.60,
                  thisMonthEarnings: 14820,
                  pendingAmount: 3340,
                  inProgressAmount: 6600,
                ),
              ),
              const SizedBox(height: 20),

              // Quick Stats Cards
              _buildQuickStatsSection(),
              const SizedBox(height: 20),

              // Transaction History Section
              _buildTransactionSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Payments',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 24,
      toolbarHeight: 64,
      actions: [
        // Contact Support Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showSnackBar(context, 'Contacting support...'),
                child: const Icon(
                  Icons.support_agent,
                  color: Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        // Download Report Button
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showDownloadOptions(context),
                child: const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFE5E7EB).withAlpha(200),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Completed Gigs',
            value: '24',
            subtitle: 'This month',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Average Rating',
            value: '4.8',
            subtitle: 'From clients',
            icon: Icons.star_outline,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentFiltersWidget( filters: selectedFilters,
            onFiltersChanged: _onFiltersChanged,
            companies: ['All Companies', 'TechCorp Solutions', 'Digital Dynamics'],),
        const SizedBox(height: 16),
        TransactionListWidget(transactions: transactionData, onLoadMore:(){ showSnackBar(context, 'Loading more transactions...');}),
      ],
    );
  }


PaymentFilters selectedFilters = PaymentFilters(
  dateRange: 'Last Week',
  company: 'All Companies',
  status: 'All Status',
  sort: 'Newest',
  customFromDate: null,
  customToDate: null,
);

void _onFiltersChanged(PaymentFilters newFilters) {
  setState(() {
    selectedFilters = newFilters;
  });
  // You can also trigger filtered transaction list update here
}

  final List<PaymentTransaction> transactionData = [
    PaymentTransaction(
      companyName: 'TechCorp Solutions',
      deliveryAddress: '123 Main St, Mumbai',
      status: PaymentStatus.paid,
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      amount: 10.00,
    ),
    PaymentTransaction(
      companyName: 'Digital Dynamics',
      deliveryAddress: '456 Oak Ave, Delhi',
      status: PaymentStatus.processing,
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      amount: 32.00,
    ),
    PaymentTransaction(
      companyName: 'Innovation Hub',
      deliveryAddress: '789 Pine Rd, Bangalore',
      status: PaymentStatus.pending,
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      amount: 25.50,
    ),
    PaymentTransaction(
      companyName: 'StartupXYZ',
      deliveryAddress: '321 Elm St, Pune',
      status: PaymentStatus.paid,
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      amount: 68.00,
    ),
  ];

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                      'Download Options',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDownloadOption(
                      icon: Icons.picture_as_pdf,
                      title: 'Download as PDF',
                      subtitle: 'Complete transaction history',
                      onTap: () {
                        Navigator.pop(context);
                        showSnackBar(context, 'PDF download started...');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDownloadOption(
                      icon: Icons.table_chart,
                      title: 'Download as CSV',
                      subtitle: 'Spreadsheet format',
                      onTap: () {
                        Navigator.pop(context);
                        showSnackBar(context, 'CSV download started...');
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    91,
                    42,
                    134,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 91, 42, 134),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
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