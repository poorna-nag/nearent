import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

class LocationUtils {
  LocationUtils._();

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionException('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionException('Location permission permanently denied');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // Bounding box for geo queries (approximate, fast)
  static Map<String, double> getBoundingBox(
    double lat, double lng, double radiusKm,
  ) {
    const kmPerDegree = 111.0;
    final latDelta = radiusKm / kmPerDegree;
    final lngDelta = radiusKm / (kmPerDegree * _cosD(lat));
    return {
      'minLat': lat - latDelta,
      'maxLat': lat + latDelta,
      'minLng': lng - lngDelta,
      'maxLng': lng + lngDelta,
    };
  }

  static double _cosD(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}
