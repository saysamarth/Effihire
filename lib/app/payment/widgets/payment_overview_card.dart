import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payment_models.dart';

class PaymentOverviewCard extends StatelessWidget {
  final PaymentOverviewData data;

  const PaymentOverviewCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 91, 42, 134),
            const Color.fromARGB(255, 91, 42, 134).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 91, 42, 134).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                'Total Earnings',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '₹${data.totalEarnings.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'All-time earnings from completed gigs',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewStatItem(
                  label: 'This Month',
                  value: '₹${data.thisMonthEarnings.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildOverviewStatItem(
                  label: 'Pending',
                  value: '₹${data.pendingAmount.toStringAsFixed(0)}',
                  icon: Icons.schedule,
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildOverviewStatItem(
                  label: 'In Progress',
                  value: '₹${data.inProgressAmount.toStringAsFixed(0)}',
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}