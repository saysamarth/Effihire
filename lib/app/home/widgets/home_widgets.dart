import 'package:effihire/auth/Bank%20Registration/screens/bank_detail_input_screen.dart';
import 'package:effihire/auth/Registration/views/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/Fetch Location/Location Cubit/location_cubit.dart';
import '../../../auth/Fetch Location/Location Cubit/location_state.dart';
import '../../../config/service/shared_pref.dart';
import '../models/opportunity.dart';

class WelcomeSection extends StatelessWidget {
  final Animation<double> animation;

  const WelcomeSection({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child!,
          ),
        );
      },
      child: _WelcomeContent(screenWidth: screenWidth),
    );
  }
}

class _WelcomeContent extends StatefulWidget {
  final double screenWidth;

  const _WelcomeContent({required this.screenWidth});

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent> {
  int _registrationStatus = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    //SharedPrefsService.setRegistrationStatus(0);
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _registrationStatus = SharedPrefsService.getRegistrationStatus();
      _userName = SharedPrefsService.getUserName();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(250),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName != null ? 'Welcome, $_userName' : 'Welcome',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: widget.screenWidth * 0.060,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5B3E86),
                  ),
                ),
                SizedBox(height: widget.screenWidth * 0.02),
                Text(
                  _getSubtitle(_registrationStatus),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: widget.screenWidth * 0.035,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: widget.screenWidth * 0.03),
                _buildActionWidget(_registrationStatus),
              ],
            ),
          ),
          _LogoCircle(screenWidth: widget.screenWidth),
        ],
      ),
    );
  }

  String _getSubtitle(int status) {
    switch (status) {
      case 1:
        return 'Just one more step to go!';
      case 2:
        return 'Your details have been submitted.';
      case 3:
        return 'Find your perfect opportunity';
      default:
        return 'Create a profile to get started.';
    }
  }

  Widget _buildActionWidget(int status) {
    switch (status) {
      case 0:
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          style: _buttonStyle(),
          child: Text('Register now', style: _buttonTextStyle()),
        );
      case 1:
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BankDetailsScreen(),
              ),
            );
          },
          style: _buttonStyle(),
          child: Text('Complete bank registration', style: _buttonTextStyle()),
        );
      case 2:
        return _buildStatusContainer(
          text: 'Profile Under Review',
          isHighlighted: false,
        );
      case 3:
        return _buildStatusContainer(
          text: 'Profile Verified',
          isHighlighted: true,
          trailing: Icon(
            Icons.done_all_rounded,
            color: Colors.white,
            size: widget.screenWidth * 0.05,
          ),
        );
      default:
        return _buildTappableContainer(
          text: 'Register Now',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
        );
    }
  }

  Widget _buildStatusContainer({
    required String text,
    required bool isHighlighted,
    bool isButton = false,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF5B3E86) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isButton
            ? [
                BoxShadow(
                  color: const Color(0xFF5B3E86).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: widget.screenWidth * 0.033,
              color: isHighlighted ? Colors.white : Colors.grey.shade700,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: widget.screenWidth * 0.02),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildTappableContainer({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildStatusContainer(
        text: text,
        isHighlighted: true,
        isButton: true,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B3E86),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.025,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
    );
  }

  TextStyle _buttonTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: widget.screenWidth * 0.033,
    );
  }
}

class _LogoCircle extends StatelessWidget {
  final double screenWidth;

  const _LogoCircle({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.15,
      height: screenWidth * 0.15,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF5B3E86)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B3E86).withAlpha(75),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'E!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class LocationSection extends StatelessWidget {
  final Animation<double> animation;

  const LocationSection({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child!,
          ),
        );
      },
      child: _LocationContent(screenWidth: screenWidth),
    );
  }
}

class _LocationContent extends StatelessWidget {
  final double screenWidth;

  const _LocationContent({required this.screenWidth});

  void _handleLocationTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing location...'),
        duration: Duration(seconds: 1),
      ),
    );
    context.read<LocationCubit>().updateLocation();
  }

  String _getLocationText(LocationState state, BuildContext context) {
    if (state is LocationLoading) {
      return 'Getting location...';
    } else if (state is LocationSuccess) {
      return state.address;
    } else if (state is LocationError) {
      return 'Unable to get location';
    } else {
      // LocationInitial or cached location
      final cubit = context.read<LocationCubit>();
      return cubit.currentAddress ?? 'Tap to get location';
    }
  }

  bool _isLoading(LocationState state) {
    return state is LocationLoading;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final isLoading = _isLoading(state);
        final locationText = _getLocationText(state, context);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => _handleLocationTap(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: const Color(0x195B3E86),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF5B3E86),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.location_on,
                            color: const Color(0xFF5B3E86),
                            size: screenWidth * 0.05,
                          ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          locationText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF757575),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isLoading)
                    Icon(
                      Icons.refresh,
                      color: Colors.grey,
                      size: screenWidth * 0.035,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EarningCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;

  const EarningCard({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.08;
    final cacheSize = (logoSize * MediaQuery.of(context).devicePixelRatio)
        .toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(screenWidth * 0.035),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: opportunity.color.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        opportunity.logoPath,
                        fit: BoxFit.cover,
                        cacheWidth: cacheSize,
                        cacheHeight: cacheSize,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            color: opportunity.color,
                            size: logoSize * 0.5,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          opportunity.location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: screenWidth * 0.028,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.earning,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'per week',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenWidth * 0.028,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: opportunity.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: opportunity.color,
                      size: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
