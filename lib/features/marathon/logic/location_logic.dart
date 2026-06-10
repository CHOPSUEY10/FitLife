import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationLogic {
  /// Check and request location permissions. 
  /// Returns true if permission is granted (always or while in use).
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  /// Gets the current location of the user as a LatLng.
  /// Returns null if unable to fetch location.
  Future<LatLng?> getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Returns a continuous stream of the user's location.
  Stream<LatLng> getLocationStream({int distanceFilter = 5}) {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position pos) => LatLng(pos.latitude, pos.longitude));
  }

  /// Calculates the distance in meters between two LatLng points.
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}
