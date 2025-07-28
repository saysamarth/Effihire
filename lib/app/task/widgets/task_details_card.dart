import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDetailsCard extends StatelessWidget {
  final String taskId;
  final String startDate;
  final String endDate;
  final String workingHours;
  final String breakTime;
  final String paymentStructure;
  final List<String> requirements;

  const TaskDetailsCard({
    super.key,
    required this.taskId,
    required this.startDate,
    required this.endDate,
    required this.workingHours,
    required this.breakTime,
    required this.paymentStructure,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Text(
            'Task Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Grid layout for better organization
          _buildDetailGrid([
            _DetailItem('Task ID', taskId, Icons.tag),
            _DetailItem('Working Hours', workingHours, Icons.schedule),
            _DetailItem('Start Date', startDate, Icons.play_circle_outline),
            _DetailItem('End Date', endDate, Icons.stop_circle_outlined),
          ]),

          const SizedBox(height: 16),

          // Payment in separate row for emphasis
          _buildDetailRow(
            Icons.payments,
            'Payment',
            paymentStructure,
            const Color(0xFF10B981),
          ),

          const SizedBox(height: 16),

          // Simplified requirements
          if (requirements.isNotEmpty) ...[
            Text(
              'Requirements',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...requirements.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5B3E86),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildGridItem(items[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem(items[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGridItem(items[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildGridItem(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(_DetailItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 16, color: const Color(0xFF5B3E86)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}
