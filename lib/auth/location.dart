// location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_service.dart';
import '../app/bottom_navbar.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _errorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _errorShakeAnimation;

  LocationState _locationState = LocationState.loading;
  String _statusText = 'Finding your location...';
  String _locationText = '';
  String _errorMessage = '';

  // Cache text styles to avoid recreating them
  late TextStyle _titleTextStyle;
  late TextStyle _subtitleTextStyle;
  late TextStyle _locationTextStyle;
  late TextStyle _buttonTextStyle;

  @override
  void initState() {
    super.initState();
    _initTextStyles();
    _initAnimations();
    _findLocation();
  }

  void _initTextStyles() {
    _titleTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    _subtitleTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.8),
      height: 1.4,
    );
    _locationTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.8),
    );
    _buttonTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _errorShakeAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _errorController, curve: Curves.elasticIn),
    );

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _findLocation() async {
    try {
      if (mounted) {
        setState(() {
          _locationState = LocationState.loading;
          _statusText = 'Finding your location...';
        });
      }

      final result = await LocationService.getCurrentLocation();
      
      if (!mounted) return;

      if (result.success && result.position != null) {
        setState(() {
          _locationState = LocationState.success;
          _statusText = 'Location found!';
          _locationText = result.address ?? 'Location acquired';
        });

        // Navigate to home after a brief delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          _navigateToHome();
        }
      } else {
        _handleLocationError(result.error!);
      }
    } catch (e) {
      if (mounted) {
        _handleLocationError(LocationError.unknown);
      }
    }
  }

  void _handleLocationError(LocationError error) {
    if (!mounted) return;
    
    _errorController.forward().then((_) => _errorController.reset());
    
    setState(() {
      _locationState = LocationState.error;
      switch (error) {
        case LocationError.permissionDenied:
          _statusText = 'Location permission needed';
          _errorMessage = 'We need location access to show you nearby delivery tasks';
          break;
        case LocationError.permissionDeniedForever:
          _statusText = 'Location access blocked';
          _errorMessage = 'Please enable location permission in settings to continue';
          break;
        case LocationError.serviceDisabled:
          _statusText = 'Location services disabled';
          _errorMessage = 'Please turn on location services to find delivery tasks near you';
          break;
        case LocationError.noInternet:
          _statusText = 'No internet connection';
          _errorMessage = 'Please check your internet connection and try again';
          break;
        case LocationError.timeout:
          _statusText = 'Location request timed out';
          _errorMessage = 'Unable to get your location. Please try again';
          break;
        case LocationError.unknown:
          _statusText = 'Something went wrong';
          _errorMessage = 'Unable to get your location. Please try again';
          break;
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const BottomNavBar(),
      ),
    );
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 91, 62, 134),
              Color.fromARGB(255, 91, 42, 134),
              Color.fromARGB(255, 101, 32, 134),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles - simplified
            _buildBackgroundCircles(),
            
            // Main content
            Center(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLocationIcon(),
                      const SizedBox(height: 40),
                      _buildStatusText(),
                      if (_locationState == LocationState.success) ...[
                        const SizedBox(height: 16),
                        _buildLocationText(),
                      ],
                      if (_locationState == LocationState.error) ...[
                        const SizedBox(height: 24),
                        _buildErrorActions(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return RepaintBoundary(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Positioned(
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
              );
            },
          ),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Positioned(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _errorShakeAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _errorShakeAnimation.value, 
              50 * (1 - _fadeAnimation.value)
            ),
            child: Transform.scale(
              scale: _locationState == LocationState.loading 
                  ? _pulseAnimation.value 
                  : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _getLocationIcon(),
                  size: 60,
                  color: _getIconColor(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                Text(
                  _statusText,
                  style: _titleTextStyle,
                ),
                if (_locationState == LocationState.error) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: _subtitleTextStyle,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationText() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
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
                      _locationText,
                      style: _locationTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorActions() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _findLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 91, 42, 134),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try Again',
                      style: _buttonTextStyle,
                    ),
                  ),
                ),
                
                if (_locationState == LocationState.error && 
                    (_errorMessage.contains('permission') || _errorMessage.contains('settings'))) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _openSettings,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        ),
                      ),
                      child: Text(
                        'Open Settings',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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

  Color _getIconBackgroundColor() {
    switch (_locationState) {
      case LocationState.loading:
        return const Color.fromARGB(255, 229, 220, 246);
      case LocationState.success:
        return Colors.green.shade100;
      case LocationState.error:
        return Colors.red.shade100;
    }
  }

  Color _getIconColor() {
    switch (_locationState) {
      case LocationState.loading:
        return const Color.fromARGB(255, 91, 42, 134);
      case LocationState.success:
        return Colors.green;
      case LocationState.error:
        return Colors.red.shade700;
    }
  }

  IconData _getLocationIcon() {
    switch (_locationState) {
      case LocationState.loading:
        return Icons.my_location;
      case LocationState.success:
        return Icons.check_circle;
      case LocationState.error:
        return Icons.location_off;
    }
  }
}