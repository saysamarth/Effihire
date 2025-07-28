import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/service/google_maps_service.dart';
import '../widgets/location_map_card.dart';
import '../widgets/supervisor_contact_card.dart';
import '../widgets/task_details_card.dart';
import '../widgets/task_header_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Work location coordinates - Connaught Place, New Delhi
  static const double _workLatitude = 28.6315;
  static const double _workLongitude = 77.2167;
  static const String _workLocationName = 'Swiggy Hub - Connaught Place';
  static const String _workAddress =
      'Block A, Connaught Place, New Delhi, Delhi 110001';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
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
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF5B3E86),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Header Card
                  TaskHeaderCard(
                    companyName: 'Swiggy',
                    companyLogo: 'assets/logos/swiggy_logo.png',
                    workType: 'Food Delivery',
                    totalPayout: '₹2,500',
                    duration: '5 days',
                  ),

                  const SizedBox(height: 20),

                  // Task Details Card
                  TaskDetailsCard(
                    taskId: 'TSK-2024-001',
                    startDate: 'Jan 29, 2025',
                    endDate: 'Feb 2, 2025',
                    workingHours: '10:00 AM - 8:00 PM',
                    breakTime: '1 hour lunch break',
                    paymentStructure: '₹500 per day',
                    requirements: [
                      'Own smartphone required',
                      'Valid driving license',
                      'Two-wheeler preferred',
                      'English communication skills',
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Supervisor Contact Card
                  SupervisorContactCard(
                    supervisorName: 'Rajesh Kumar',
                    designation: 'Area Manager',
                    phoneNumber: '+91 98765 43210',
                    email: 'rajesh.kumar@swiggy.in',
                    profileImage: null,
                  ),

                  const SizedBox(height: 20),

                  // Location Map Card with real coordinates
                  LocationMapCard(
                    locationName: _workLocationName,
                    address: _workAddress,
                    latitude: _workLatitude,
                    longitude: _workLongitude,
                    onDirectionsPressed: () => _handleCustomDirections(context),
                    onSharePressed: () => _handleCustomShare(context),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Generic refresh - can be extended for other data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleCustomDirections(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B3E86)),
      ),
    );

    final success = await MapsService.openDirections(
      latitude: _workLatitude,
      longitude: _workLongitude,
      locationName: _workLocationName,
    );

    if (mounted) {
      Navigator.pop(context);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open directions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCustomShare(BuildContext context) async {
    final success = await MapsService.shareLocation(
      locationName: _workLocationName,
      address: _workAddress,
      latitude: _workLatitude,
      longitude: _workLongitude,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Current Task',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      toolbarHeight: 64,
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
}
