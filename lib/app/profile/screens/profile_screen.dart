import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/profile_action_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String? userPhone;

  const ProfileScreen({super.key, required this.userPhone});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isDarkMode = false;
  bool _isOnline = false;
  bool _notificationsEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Header Card
              ProfileHeaderCard(
                userPhone: widget.userPhone ?? 'User',
                userName: 'John Doe', // This would come from backend
                gigId: 'GIG001234',
                rating: 4.8,
                profileImageUrl: null, // This would come from backend
                onEditProfile: _onEditProfile,
              ),
              
              const SizedBox(height: 24),
              
              // Account Settings Section
              SettingsSection(
                title: 'Account & Preferences',
                items: [
                  SettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: _onLanguageSettings,
                    showTrailing: true,
                  ),
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                    onTap: _onNotificationSettings,
                    showTrailing: true,
                  ),
                  SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: _isDarkMode ? 'On' : 'Off',
                    onTap: null,
                    showTrailing: false,
                    trailingWidget: Switch.adaptive(
                      value: _isDarkMode,
                      onChanged: _onDarkModeToggle,
                      activeColor: const Color.fromARGB(255, 91, 42, 134),
                    ),
                  ),
                  SettingsItem(
                    icon: Icons.devices,
                    title: 'Active Sessions',
                    subtitle: _isOnline ? 'Online' : 'Offline',
                    onTap: null,
                    showTrailing: false,
                    trailingWidget: Switch.adaptive(
                      value: _isOnline,
                      onChanged: _onOnlineToggle,
                      activeColor: const Color.fromARGB(255, 91, 42, 134),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Earnings & Business Section
              SettingsSection(
                title: 'Earnings & Business',
                items: [
                  SettingsItem(
                    icon: Icons.card_giftcard,
                    title: 'Refer & Earn',
                    subtitle: 'Invite friends and earn rewards',
                    onTap: _onReferAndEarn,
                    showTrailing: true,
                    iconColor: Colors.orange,
                  ),
                  SettingsItem(
                    icon: Icons.file_download_outlined,
                    title: 'Download Earning Statement',
                    subtitle: 'Get your earnings report',
                    onTap: _onDownloadStatement,
                    showTrailing: true,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Support & Safety Section
              SettingsSection(
                title: 'Support & Safety',
                items: [
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQ and contact support',
                    onTap: _onHelpSupport,
                    showTrailing: true,
                  ),
                  SettingsItem(
                    icon: Icons.emergency,
                    title: 'SOS Emergency',
                    subtitle: 'Emergency contact settings',
                    onTap: _onSOSSettings,
                    showTrailing: true,
                    iconColor: Colors.red,
                  ),
                  SettingsItem(
                    icon: Icons.star_outline,
                    title: 'Rate Us',
                    subtitle: 'Share your feedback',
                    onTap: _onRateApp,
                    showTrailing: true,
                    iconColor: Colors.amber,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Legal Section
              SettingsSection(
                title: 'Legal',
                items: [
                  SettingsItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'App terms and privacy policy',
                    onTap: _onTermsConditions,
                    showTrailing: true,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  ProfileActionButton(
                    title: 'Sign Out',
                    icon: Icons.logout,
                    onPressed: () => _showSignOutDialog(context),
                    backgroundColor: Colors.red.shade700,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  ProfileActionButton(
                    title: 'Delete Account',
                    icon: Icons.delete_forever,
                    onPressed: () => _showDeleteAccountDialog(context),
                    backgroundColor: Colors.red.shade50,
                    textColor: Colors.red.shade700,
                    borderColor: Colors.red.shade300,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: Text(
      'My Profile',
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
      Container(
        margin: const EdgeInsets.only(right: 20),
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 0.5,
                ),
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
                  onTap: () => showSnackBar(context, 'Notifications'),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF6B7280),
                    size: 22,
                  ),
                ),
              ),
            ),
            // Notification badge
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  // Event Handlers
  void _onEditProfile() {
    showSnackBar(context, 'Edit profile feature coming soon');
  }

  void _onLanguageSettings() {
    showSnackBar(context, 'Language settings');
  }

  void _onNotificationSettings() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
    showSnackBar(context, 'Notification preferences updated');
  }

  void _onDarkModeToggle(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // Add haptic feedback
    if (_isDarkMode) {
      showSnackBar(context, 'Dark mode enabled');
    } else {
      showSnackBar(context, 'Light mode enabled');
    }
  }
  void _onOnlineToggle(bool value) {
    setState(() {
      _isOnline = value;
    });
    // Add haptic feedback
    if (_isOnline) {
      showSnackBar(context, 'You are online now.');
    } else {
      showSnackBar(context, 'You are offline now.');
    }
  }

  void _onReferAndEarn() {
    showSnackBar(context, 'Refer and earn');
  }

  void _onDownloadStatement() {
    showSnackBar(context, 'Downloading earning statement...');
  }

  void _onHelpSupport() {
    showSnackBar(context, 'Help & Support');
  }

  void _onSOSSettings() {
    showSnackBar(context, 'SOS Emergency settings');
  }

  void _onRateApp() {
    showSnackBar(context, 'Rate us');
  }

  void _onTermsConditions() {
    showSnackBar(context, 'Terms & Conditions');
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out? You will need to sign in again to access your account.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'This action cannot be undone. All your data will be permanently deleted. Are you sure you want to delete your account?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      showSnackBar(context, 'Signed out successfully');

      if (context.mounted) {
        context.go('/logout-login');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to sign out. Please try again.');
      debugPrint('Error signing out: $e');
    }
  }

  void _deleteAccount(BuildContext context) async {
    try {
      showSnackBar(context, 'Account deletion initiated...');
      // Add your account deletion logic here
      // This might involve calling a backend API to delete user data
    } catch (e) {
      showSnackBar(context, 'Failed to delete account. Please try again.');
      debugPrint('Error deleting account: $e');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 91, 42, 134),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}