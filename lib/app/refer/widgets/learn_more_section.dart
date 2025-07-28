// widgets/learn_more_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnMoreSection extends StatelessWidget {
  final VoidCallback onFullRulesPressed;
  final VoidCallback onFAQPressed;

  const LearnMoreSection({
    super.key,
    required this.onFullRulesPressed,
    required this.onFAQPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn more',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5B3E86),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            // Full Rules Card
            Expanded(
              child: _buildLearnMoreCard(
                title: 'Full rules',
                icon: Icons.description,
                iconColor: const Color(0xFF5B3E86),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 82, 39, 137),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                onPressed: onFullRulesPressed,
              ),
            ),

            const SizedBox(width: 16),

            // FAQ Card
            Expanded(
              child: _buildLearnMoreCard(
                title: 'FAQ',
                icon: Icons.help_outline,
                iconColor: const Color(0xFF8B5CF6),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 78, 30, 141),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                onPressed: onFAQPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLearnMoreCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 140,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and decorative elements
                Stack(
                  children: [
                    // Background decorative circles
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 15,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Main icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  ],
                ),

                const Spacer(),

                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                // Subtle arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
