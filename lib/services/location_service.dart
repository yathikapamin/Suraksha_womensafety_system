import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  // ── Check & Request Permissions ──
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // ── Get Current Location (one-time) ──
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // ── Start Continuous Location Stream ──
  Future<void> startLocationStream({
    required Function(Position) onLocationUpdate,
    int intervalMs = AppConstants.locationUpdateIntervalMs,
  }) async {
    // Re-check permissions before starting stream
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      print('Location permission denied. Cannot start stream.');
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // minimum 10 meters between updates
    );

    try {
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
        (Position position) {
          _currentPosition = position;
          onLocationUpdate(position);
        },
        onError: (error) {
          print('Location stream error: $error');
          stopLocationStream();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Failed to start location stream: $e');
    }
  }

  // ── Update Location in Firestore ──
  Future<void> updateLocationInFirestore(String userId, Position position) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  // ── Stop Location Stream ──
  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // ── Calculate Distance ──
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // ── Dispose ──
  void dispose() {
    stopLocationStream();
  }
}
