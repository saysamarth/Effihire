// screens/referral_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/service/shared_pref.dart';
import '../widgets/how_to_earn_section.dart';
import '../widgets/learn_more_section.dart';
import '../widgets/referral_bottom_sheet.dart';
import '../widgets/referral_header_card.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String get userName => SharedPrefsService.getUserName() ?? 'User';
  String get userReferralCode =>
      SharedPrefsService.getReferralCode() ?? 'b19fs9t';

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
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      extendBodyBehindAppBar: true,
      //appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header (scrollable but starts from top)
              ReferralHeaderCard(
                userName: userName,
                referralCode: userReferralCode,
                onInviteFriends: _onInviteFriends,
                onCopyCode: _onCopyCode,
              ),

              // Content below header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // How to Earn Section
                    const HowToEarnSection(),

                    const SizedBox(height: 20),

                    // Learn More Section
                    LearnMoreSection(
                      onFullRulesPressed: _onFullRulesPressed,
                      onFAQPressed: _onFAQPressed,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onInviteFriends() {
    final String shareMessage =
        "🎉 Join me on EffiHire and earn ₹100 cashback!\n\n"
        "Use my referral code: $userReferralCode\n\n"
        "✨ How it works:\n"
        "• Download EffiHire app\n"
        "• Sign up with my code\n"
        "• Complete your first gig\n"
        "• We both earn ₹50 cashback!\n\n"
        "💰 Bonus: Complete 4 gigs and earn ₹50 more!\n\n"
        "Download now: https://EffiHire.com/";

    Share.share(shareMessage, subject: 'Join EffiHire and Earn ₹100!');
  }

  void _onCopyCode() {
    Clipboard.setData(ClipboardData(text: userReferralCode));
    _showSnackBar('Referral code copied to clipboard!');
  }

  void _onFullRulesPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomSheet(
        title: 'Full Rules',
        content: _getFullRulesContent(),
      ),
    );
  }

  void _onFAQPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomSheet(
        title: 'Frequently Asked Questions',
        content: _getFAQContent(),
      ),
    );
  }

  List<Map<String, String>> _getFullRulesContent() {
    return [
      {
        'title': 'Eligibility Requirements',
        'content':
            'Both you and your referred friend must be new users to EffiHire. Existing users or previously registered accounts are not eligible for referral rewards.',
      },
      {
        'title': 'Referral Process',
        'content':
            'Share your unique referral code with friends during their registration. The code must be entered at sign-up to qualify for rewards. Referral codes cannot be applied after account creation.',
      },
      {
        'title': 'Reward Activation',
        'content':
            'Your referred friend must complete their first gig within 30 days of registration to activate the ₹50 cashback for both parties. The gig must be successfully completed and payment received.',
      },
      {
        'title': 'Bonus Rewards',
        'content':
            'An additional ₹50 bonus is awarded to both referrer and referee when the referred friend completes 4 gigs successfully. All gigs must be completed within 60 days of registration.',
      },
      {
        'title': 'Payment & Verification',
        'content':
            'Cashback is credited to your bank account within 48-72 hours after your friend meets the requirements. Rewards are subject to verification and may be withheld for suspicious activity.',
      },
      {
        'title': 'Terms & Conditions',
        'content':
            'EffiHire reserves the right to modify or terminate this program at any time. Rewards cannot be transferred between accounts or converted to direct cash payments. One referral reward per unique user.',
      },
    ];
  }

  List<Map<String, String>> _getFAQContent() {
    return [
      {
        'title': 'How long is my referral code valid?',
        'content':
            'Your referral code never expires and can be used by unlimited friends. Each successful referral earns you rewards as long as the program is active.',
      },
      {
        'title': 'When will I receive my cashback?',
        'content':
            'The first ₹50 is credited within 48-72 hours after your friend completes their first gig. The bonus ₹50 is credited after they complete their 4th gig.',
      },
      {
        'title': 'Is there a limit to how many people I can refer?',
        'content':
            'No limit! You can refer as many friends as you want and earn ₹100 cashback for each person who successfully completes the requirements.',
      },
      {
        'title': 'What if my friend forgets to use my referral code?',
        'content':
            'Unfortunately, referral codes must be entered during registration and cannot be applied retroactively. Make sure your friend uses your code when signing up.',
      },
      {
        'title': 'What types of gigs count toward the referral rewards?',
        'content':
            'All completed gigs on the EffiHire platform count toward referral requirements, including delivery, services, freelance work, and part-time jobs posted on our platform.',
      },
      {
        'title': 'Can I refer family members or roommates?',
        'content':
            'Yes, you can refer family members as long as they create separate accounts with unique phone numbers and email addresses and are genuine new users to the platform.',
      },
      {
        'title': 'How do I track my referral progress?',
        'content':
            'You can monitor your referrals and their progress in the "My Referrals" section of your EffiHire profile. You\'ll see when friends sign up and complete their gigs.',
      },
      {
        'title':
            'What happens if my referred friend doesn\'t complete any gigs?',
        'content':
            'If your friend doesn\'t complete their first gig within 30 days of registration, neither of you will receive the referral reward. Encourage them to start working on gigs soon after signing up!',
      },
    ];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5B3E86), // Changed to match app theme
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
