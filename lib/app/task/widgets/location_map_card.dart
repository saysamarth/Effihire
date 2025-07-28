import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/Fetch Location/Location Cubit/location_cubit.dart';
import '../../../auth/Fetch Location/Location Cubit/location_state.dart';
import '../../../config/service/google_maps_service.dart';

class LocationMapCard extends StatefulWidget {
  final String locationName;
  final String address;
  final double latitude;
  final double longitude;
  final VoidCallback? onDirectionsPressed;
  final VoidCallback? onSharePressed;

  const LocationMapCard({
    super.key,
    required this.locationName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.onDirectionsPressed,
    this.onSharePressed,
  });

  @override
  State<LocationMapCard> createState() => _LocationMapCardState();
}

class _LocationMapCardState extends State<LocationMapCard> {
  String? _distanceText;
  bool _isCalculatingDistance = false;
  bool _hasCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _checkAndCalculateDistance();
  }

  void _checkAndCalculateDistance() {
    final locationCubit = context.read<LocationCubit>();
    final currentPosition = locationCubit.currentPosition;

    if (currentPosition != null) {
      _calculateDistance(currentPosition.latitude, currentPosition.longitude);
    } else {
      setState(() {
        _isCalculatingDistance = true;
      });

      locationCubit
          .getCurrentLocation()
          .then((_) {
            if (mounted) {
              final newPosition = locationCubit.currentPosition;
              if (newPosition != null) {
                _calculateDistance(newPosition.latitude, newPosition.longitude);
              } else {
                setState(() {
                  _isCalculatingDistance = false;
                  _hasCurrentLocation = false;
                });
              }
            }
          })
          .catchError((_) {
            if (mounted) {
              setState(() {
                _isCalculatingDistance = false;
                _hasCurrentLocation = false;
              });
            }
          });
    }
  }

  void _calculateDistance(double userLat, double userLng) {
    final distance = MapsService.calculateDistance(
      lat1: userLat,
      lng1: userLng,
      lat2: widget.latitude,
      lng2: widget.longitude,
    );

    setState(() {
      _distanceText = MapsService.formatDistance(distance);
      _isCalculatingDistance = false;
      _hasCurrentLocation = true;
    });
  }

  void _refreshDistance() {
    setState(() {
      _isCalculatingDistance = true;
      _distanceText = null;
    });
    _checkAndCalculateDistance();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (context, state) {
        if (state is LocationSuccess && _isCalculatingDistance) {
          _calculateDistance(state.position.latitude, state.position.longitude);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMapPreview(context),
            const SizedBox(height: 16),
            _buildLocationInfo(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.red, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Work Location',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        if (_hasCurrentLocation || _isCalculatingDistance)
          GestureDetector(
            onTap: _isCalculatingDistance ? null : _refreshDistance,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isCalculatingDistance
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCalculatingDistance
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCalculatingDistance) ...[
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ] else ...[
                    Icon(Icons.refresh, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _distanceText ?? 'Calculating...',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isCalculatingDistance ? Colors.grey : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    final mapUrl = MapsService.getStaticMapUrl(
      latitude: widget.latitude,
      longitude: widget.longitude,
      zoom: 15,
      size: '400x200',
      markerColor: 'red',
    );

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              mapUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildMapPlaceholder(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF5B3E86),
                  ),
                  text: 'Loading map...',
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildMapPlaceholder(
                  child: Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  text: 'Map not available',
                  subtitle: 'Tap to open in maps app',
                );
              },
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openFullMap(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to view',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder({
    required Widget child,
    required String text,
    String? subtitle,
  }) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(height: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.locationName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            if (_hasCurrentLocation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'GPS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.address,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
        if (_hasCurrentLocation) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              BlocBuilder<LocationCubit, LocationState>(
                builder: (context, state) {
                  if (state is LocationSuccess && _distanceText != null) {
                    final distance = MapsService.calculateDistance(
                      lat1: state.position.latitude,
                      lng1: state.position.longitude,
                      lat2: widget.latitude,
                      lng2: widget.longitude,
                    );
                    final estimatedMinutes = (distance * 3).round();
                    return Text(
                      '~$estimatedMinutes min away',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    );
                  }
                  return Text(
                    'Calculating travel time...',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            Icons.directions,
            'Directions',
            Colors.blue,
            () => _handleDirections(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            Icons.share,
            'Share',
            const Color(0xFF5B3E86),
            () => _handleShare(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullMap(BuildContext context) async {
    final success = await MapsService.openInMaps(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDirections() {
    if (widget.onDirectionsPressed != null) {
      widget.onDirectionsPressed!();
    } else {
      MapsService.openDirections(
        latitude: widget.latitude,
        longitude: widget.longitude,
        locationName: widget.locationName,
      );
    }
  }

  void _handleShare() {
    if (widget.onSharePressed != null) {
      widget.onSharePressed!();
    } else {
      MapsService.shareLocation(
        locationName: widget.locationName,
        address: widget.address,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
    }
  }
}
