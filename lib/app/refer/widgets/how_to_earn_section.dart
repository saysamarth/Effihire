// widgets/how_to_earn_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToEarnSection extends StatelessWidget {
  const HowToEarnSection({super.key});

  void _copyReferralCode(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'b19fs9t'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
        backgroundColor: const Color(
          0xFF5B3E86,
        ), // Changed to app's main purple
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to earn ₹100 cashback',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5B3E86),
          ),
        ),
        const SizedBox(height: 20),

        // Steps with connecting line
        Stack(
          children: [
            // Connecting line
            Positioned(
              left: 25, // Center of the icon container
              top: 50,
              bottom: 50,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(
                        0xFF5B3E86,
                      ).withOpacity(0.3), // Purple gradient
                      const Color(
                        0xFF8B5CF6,
                      ).withOpacity(0.2), // Lighter purple
                      const Color(
                        0xFF5B3E86,
                      ).withOpacity(0.3), // Back to main purple
                    ],
                  ),
                ),
              ),
            ),

            // Steps
            Column(
              children: [
                _buildStep(
                  stepNumber: 1,
                  emoji: '💬',
                  backgroundColor: const Color(0xFF5B3E86), // Main app purple
                  title:
                      'Invite a friend to join EffiHire\nusing your referral code:',
                  subtitle: 'b19fs9t',
                  showCopyButton: true,
                  context: context,
                ),
                _buildStep(
                  stepNumber: 2,
                  emoji: '✅',
                  backgroundColor: const Color(0xFF8B5CF6), // Light purple
                  title: 'Earn ₹50 when your friend\ncompletes their first gig',
                  subtitle: 'You both get rewarded for getting started',
                  showCopyButton: false,
                  context: context,
                ),
                _buildStep(
                  stepNumber: 3,
                  emoji: '🎁',
                  backgroundColor: const Color(0xFF7C5BA6), // Medium purple
                  title:
                      'Get an extra ₹50 bonus when your friend completes 4 gigs',
                  subtitle: 'Extra rewards for referring active workers',
                  showCopyButton: false,
                  showMultiplier: true,
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String emoji,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required bool showCopyButton,
    required BuildContext context,
    bool showMultiplier = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon Container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: backgroundColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                if (showMultiplier)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'x4',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors
                        .black87, // Changed to dark text for white background
                    height: 1.3,
                  ),
                ),
                if (showCopyButton) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B3E86), // Changed to main purple
                      letterSpacing: 1,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors
                          .grey
                          .shade600, // Changed to gray for better contrast
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Copy button on the right side
          if (showCopyButton) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _copyReferralCode(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF5B3E86,
                  ).withOpacity(0.1), // Purple tint
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(
                      0xFF5B3E86,
                    ).withOpacity(0.2), // Purple border
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.copy,
                  color: const Color(0xFF5B3E86), // Purple icon
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
