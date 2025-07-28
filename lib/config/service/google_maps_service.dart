import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsService {
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY']!;

  static const double _defaultLat = 28.6139;
  static const double _defaultLng = 77.2090;

  static String getStaticMapUrl({
    double? latitude,
    double? longitude,
    int zoom = 15,
    String size = '400x200',
    String markerColor = 'red',
    String mapType = 'roadmap',
  }) {
    final lat = latitude ?? _defaultLat;
    final lng = longitude ?? _defaultLng;

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$lat,$lng&'
        'zoom=$zoom&'
        'size=$size&'
        'maptype=$mapType&'
        'markers=color:$markerColor%7Clabel:W%7C$lat,$lng&'
        'style=feature:poi|visibility:simplified&'
        'style=feature:transit|visibility:simplified&'
        'key=$_apiKey';
  }

  static String getHighResStaticMapUrl({
    double? latitude,
    double? longitude,
    int zoom = 15,
    String size = '800x400',
    String markerColor = 'red',
  }) {
    return '${getStaticMapUrl(latitude: latitude, longitude: longitude, zoom: zoom, size: size, markerColor: markerColor)}&scale=2';
  }

  static String getRouteMapUrl({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String size = '400x200',
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'size=$size&'
        'markers=color:blue%7Clabel:S%7C$startLat,$startLng&'
        'markers=color:red%7Clabel:W%7C$endLat,$endLng&'
        'path=color:0x0000ff%7Cweight:3%7C$startLat,$startLng%7C$endLat,$endLng&'
        'key=$_apiKey';
  }

  static Future<bool> openDirections({
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final lat = latitude ?? _defaultLat;
    final lng = longitude ?? _defaultLng;
    final mapUrls = [
      {
        'scheme': 'comgooglemaps://',
        'url': 'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
      },
      {
        'scheme': 'maps://',
        'url': 'maps://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
      },
      {'scheme': 'waze://', 'url': 'waze://?ll=$lat,$lng&navigate=yes'},
      {
        'scheme': 'https://',
        'url':
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      },
    ];

    for (final mapUrl in mapUrls) {
      try {
        final uri = Uri.parse(mapUrl['url']!);

        if (mapUrl['scheme'] == 'https://') {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        } else if (await canLaunchUrl(Uri.parse(mapUrl['scheme']!))) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  static Future<bool> openInMaps({
    double? latitude,
    double? longitude,
    int zoom = 15,
  }) async {
    final lat = latitude ?? _defaultLat;
    final lng = longitude ?? _defaultLng;

    final mapOptions = [
      // Google Maps app
      'comgooglemaps://?center=$lat,$lng&zoom=$zoom',
      // Apple Maps app
      'maps://maps.apple.com/?ll=$lat,$lng&z=$zoom',
      // Web fallback
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    ];

    for (final mapUrl in mapOptions) {
      try {
        final uri = Uri.parse(mapUrl);

        if (mapUrl.startsWith('https://')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        } else if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  static Future<bool> shareLocation({
    required String locationName,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? _defaultLat;
    final lng = longitude ?? _defaultLng;

    final shareText =
        '''
📍 $locationName

📧 Address: $address

🗺️ Coordinates: $lat, $lng

🔗 Open in Maps: ${getWebMapUrl(latitude: lat, longitude: lng)}

🚗 Get Directions: https://www.google.com/maps/dir/?api=1&destination=$lat,$lng
    '''
            .trim();

    try {
      await Share.share(shareText, subject: 'Work Location - $locationName');
      return true;
    } catch (e) {
      return false;
    }
  }

  static String getWebMapUrl({
    double? latitude,
    double? longitude,
    int zoom = 15,
  }) {
    final lat = latitude ?? _defaultLat;
    final lng = longitude ?? _defaultLng;
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&zoom=$zoom';
  }

  static bool isValidCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  static double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double earthRadius = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  static double calculateBearing({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLng = _degreesToRadians(lng2 - lng1);
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final y = sin(dLng) * cos(lat2Rad);
    final x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLng);

    final bearing = atan2(y, x);
    return _radiansToDegrees(bearing);
  }

  static String getCardinalDirection(double bearing) {
    final normalizedBearing = (bearing + 360) % 360;

    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((normalizedBearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static double _radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  static String formatDistance(double distanceKm) {
    if (distanceKm < 0.1) {
      return '${(distanceKm * 1000).round()}m away';
    } else if (distanceKm < 1) {
      return '${(distanceKm * 1000 / 50).round() * 50}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.round()}km away';
    }
  }

  static String formatDistanceDetailed(double distanceKm) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters meters';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  static Duration estimateTravelTime({
    required double distanceKm,
    String mode = 'driving',
  }) {
    double speedKmh;

    switch (mode.toLowerCase()) {
      case 'walking':
        speedKmh = 5.0;
        break;
      case 'cycling':
        speedKmh = 15.0;
        break;
      case 'transit':
        speedKmh = 25.0;
        break;
      case 'driving':
      default:
        speedKmh = 30.0;
        break;
    }

    final timeHours = distanceKm / speedKmh;
    return Duration(milliseconds: (timeHours * 3600 * 1000).round());
  }

  static String formatTravelTime(Duration duration) {
    if (duration.inMinutes < 1) {
      return '< 1 min';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }

  static bool isWithinRadius({
    required double centerLat,
    required double centerLng,
    required double pointLat,
    required double pointLng,
    required double radiusKm,
  }) {
    final distance = calculateDistance(
      lat1: centerLat,
      lng1: centerLng,
      lat2: pointLat,
      lng2: pointLng,
    );
    return distance <= radiusKm;
  }

  static String getApproximateLocation(double lat, double lng) {
    if (lat >= 28.0 && lat <= 29.0 && lng >= 76.0 && lng <= 78.0) {
      return 'Delhi, India';
    } else if (lat >= 18.0 && lat <= 20.0 && lng >= 72.0 && lng <= 73.5) {
      return 'Mumbai, India';
    } else if (lat >= 12.5 && lat <= 13.5 && lng >= 77.0 && lng <= 78.0) {
      return 'Bangalore, India';
    }
    return 'Unknown location';
  }
}
