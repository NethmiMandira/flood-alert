import 'package:geolocator/geolocator.dart';

// Reasons why getting the location can fail
enum LocationError { serviceDisabled, denied, deniedForever, unknown }

class LocationException implements Exception {
  final LocationError error;
  LocationException(this.error);
}

class LocationService {
  // Returns the current GPS position, or throws a LocationException
  Future<Position> getCurrentPosition() async {
    // 1. Is the phone's location (GPS) switched on?
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException(LocationError.serviceDisabled);
    }

    // 2. Check the app's permission, ask the user if needed
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationException(LocationError.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(LocationError.deniedForever);
    }

    // 3. Read the position (give up after 15 seconds)
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      throw LocationException(LocationError.unknown);
    }
  }

  // Opens the phone's location settings screen
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  // Opens this app's settings screen (used when permission is denied forever)
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}