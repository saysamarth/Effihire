import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors/app_colors.dart';

class BankConfirmationWidget extends StatefulWidget {
  final bool isConfirmed;
  final ValueChanged<bool> onConfirmationChanged;

  const BankConfirmationWidget({
    super.key,
    required this.isConfirmed,
    required this.onConfirmationChanged,
  });

  @override
  State<BankConfirmationWidget> createState() => _BankConfirmationWidgetState();
}

class _BankConfirmationWidgetState extends State<BankConfirmationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
              const SizedBox(width: 6),
              Text(
                'Verification Required',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => widget.onConfirmationChanged(!widget.isConfirmed),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: widget.isConfirmed,
                      onChanged: (bool? value) {
                        if (value != null) {
                          widget.onConfirmationChanged(value);
                        }
                      },
                      activeColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
            'Verify account details before proceeding.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}