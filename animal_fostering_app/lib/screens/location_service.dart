import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCityName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<bool> isInTimisoara(double lat, double lng) async {
    // Simple bounding box check for Timișoara
    const double minLat = 45.7;
    const double maxLat = 45.8;
    const double minLng = 21.1;
    const double maxLng = 21.3;
    
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  static Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }
}