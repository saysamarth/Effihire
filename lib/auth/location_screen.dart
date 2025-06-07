// location_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_cubit.dart';
import 'location_state.dart';
import 'location_service.dart';
import '../app/bottom_navbar.dart';

/// Performance-optimized location screen using Bloc pattern
/// Key optimizations:
/// - Single AnimationController with staggered animations
/// - Strategic RepaintBoundary usage
/// - Cached text styles
/// - Optimized BlocBuilder usage
/// - Memory leak prevention
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  
  // PERFORMANCE OPTIMIZATION: Single AnimationController instead of 3
  late AnimationController _animationController;
  
  // Staggered animations from single controller
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // Start location acquisition immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationCubit>().getCurrentLocation();
    });
  }

  /// Initialize all animations with a single controller for better performance
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Staggered animations for different UI elements
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _errorShakeAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticIn),
      ),
    );

    // Start fade and slide animations immediately
    _animationController.forward();
  }

  /// Handle auto-navigation after successful location acquisition
  void _handleAutoNavigation() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildGradientDecoration(),
        child: Stack(
          children: [
            // PERFORMANCE: RepaintBoundary for expensive background
            _buildOptimizedBackground(),
            
            // Main content with BlocBuilder
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  /// PERFORMANCE: Cached gradient decoration
  static const BoxDecoration _gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 91, 62, 134),
        Color.fromARGB(255, 91, 42, 134),
        Color.fromARGB(255, 101, 32, 134),
      ],
    ),
  );

  BoxDecoration _buildGradientDecoration() => _gradientDecoration;

  /// PERFORMANCE: Optimized background with RepaintBoundary
  Widget _buildOptimizedBackground() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: -100 * _fadeAnimation.value,
                right: -100 * _fadeAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150 * _fadeAnimation.value,
                left: -50 * _fadeAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Main content with optimized BlocBuilder usage
  Widget _buildMainContent() {
    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: BlocConsumer<LocationCubit, LocationState>(
            listener: (context, state) {
              // Handle side effects like navigation and animation changes
              if (state is LocationSuccess) {
                _handleAutoNavigation();
              } else if (state is LocationError) {
                // Trigger error shake animation
                _animationController.reset();
                _animationController.forward();
              } else if (state is LocationLoading) {
                // Start pulse animation for loading state
                _animationController.repeat(reverse: true);
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLocationIcon(state),
                  const SizedBox(height: 40),
                  _buildStatusContent(state),
                  if (state is LocationError) ...[
                    const SizedBox(height: 24),
                    _buildErrorActions(state),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// PERFORMANCE: Optimized location icon with strategic RepaintBoundary
  Widget _buildLocationIcon(LocationState state) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              state is LocationError ? _errorShakeAnimation.value : 0,
              _slideAnimation.value,
            ),
            child: Transform.scale(
              scale: state is LocationLoading ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(state),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _getLocationIcon(state),
                  size: 60,
                  color: _getIconColor(state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Status content with optimized animations
  Widget _buildStatusContent(LocationState state) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.6),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                Text(
                  _getStatusTitle(state),
                  style: _CachedTextStyles.title,
                ),
                if (state is LocationSuccess) ...[
                  const SizedBox(height: 16),
                  _buildLocationDisplay(state.address),
                ],
                if (state is LocationError) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: _CachedTextStyles.subtitle,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Location display widget for success state
  Widget _buildLocationDisplay(String address) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.place_outlined,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              address,
              style: _CachedTextStyles.location,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Error action buttons
  Widget _buildErrorActions(LocationError errorState) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.4),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<LocationCubit>().getCurrentLocation(),
                    style: _CachedButtonStyles.primary,
                    child: Text(
                      'Try Again',
                      style: _CachedTextStyles.button,
                    ),
                  ),
                ),
                
                // Settings button for permission-related errors
                if (errorState.needsSettings) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => openAppSettings(),
                      style: _CachedButtonStyles.secondary,
                      child: Text(
                        'Open Settings',
                        style: _CachedTextStyles.buttonSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods for state-based UI properties
  String _getStatusTitle(LocationState state) {
    return switch (state) {
      LocationLoading() => state.message,
      LocationSuccess() => state.message,
      LocationError() => state.title,
      _ => 'Finding your location...',
    };
  }

  Color _getIconBackgroundColor(LocationState state) {
    return switch (state) {
      LocationLoading() => const Color.fromARGB(255, 229, 220, 246),
      LocationSuccess() => Colors.green.shade100,
      LocationError() => Colors.red.shade100,
      _ => const Color.fromARGB(255, 229, 220, 246),
    };
  }

  Color _getIconColor(LocationState state) {
    return switch (state) {
      LocationLoading() => const Color.fromARGB(255, 91, 42, 134),
      LocationSuccess() => Colors.green,
      LocationError() => Colors.red.shade700,
      _ => const Color.fromARGB(255, 91, 42, 134),
    };
  }

  IconData _getLocationIcon(LocationState state) {
    return switch (state) {
      LocationLoading() => Icons.my_location,
      LocationSuccess() => Icons.check_circle,
      LocationError() => Icons.location_off,
      _ => Icons.my_location,
    };
  }
}

/// PERFORMANCE: Cached text styles to prevent recreation on every build
class _CachedTextStyles {
  static final TextStyle title = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final TextStyle subtitle = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.8),
    height: 1.4,
  );

  static final TextStyle location = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.8),
  );

  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonSecondary = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

/// PERFORMANCE: Cached button styles
class _CachedButtonStyles {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: const Color.fromARGB(255, 91, 42, 134),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );

  static final ButtonStyle secondary = TextButton.styleFrom(
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.white.withOpacity(0.4)),
    ),
  );
}