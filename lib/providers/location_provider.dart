import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/danger_zone_service.dart';
import '../models/danger_zone.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  late final DangerZoneService _dangerZoneService;

  Position? _currentPosition;
  bool _isTracking = false;
  bool _hasPermission = false;
  String? _error;
  
  bool _dangerZoneAlertsEnabled = true;
  DangerZone? _currentDangerZone;

  bool get dangerZoneAlertsEnabled => _dangerZoneAlertsEnabled;
  DangerZone? get currentDangerZone => _currentDangerZone;

  LocationProvider() {
    _dangerZoneService = DangerZoneService(
      onEnterDangerZone: (zone) {
        if (_dangerZoneAlertsEnabled) {
          _currentDangerZone = zone;
          notifyListeners();
        }
      },
      onExitDangerZone: (zone) {
        if (_currentDangerZone?.area == zone.area) {
          _currentDangerZone = null;
          notifyListeners();
        }
      },
    );
  }

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  String? get error => _error;
  double get latitude => _currentPosition?.latitude ?? 12.9716;
  double get longitude => _currentPosition?.longitude ?? 77.5946;

  // ── Initialize ──
  Future<void> initialize() async {
    _hasPermission = await _locationService.checkPermissions();
    if (_hasPermission) {
      await getCurrentLocation();
    }
    notifyListeners();
  }

  // ── Get Current Location ──
  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _error = null;
    } catch (e) {
      _error = 'Failed to get location: $e';
    }
    notifyListeners();
  }

  // ── Start Tracking ──
  Future<void> startTracking({Function(Position)? onUpdate}) async {
    _isTracking = true;
    await _locationService.startLocationStream(
      onLocationUpdate: (position) {
        _currentPosition = position;
        
        if (_dangerZoneAlertsEnabled) {
          _dangerZoneService.evaluateZones(position);
        }
        
        onUpdate?.call(position);
        notifyListeners();
      },
    );
    notifyListeners();
  }

  // ── Toggle Danger Zone Alerts ──
  void toggleDangerZoneAlerts(bool value) {
    _dangerZoneAlertsEnabled = value;
    if (!value) {
      _currentDangerZone = null;
    }
    notifyListeners();
  }

  // ── Stop Tracking ──
  void stopTracking() {
    _isTracking = false;
    _locationService.stopLocationStream();
    notifyListeners();
  }

  // ── Update in Firestore ──
  Future<void> updateInFirestore(String userId) async {
    if (_currentPosition != null) {
      await _locationService.updateLocationInFirestore(
        userId,
        _currentPosition!,
      );
    }
  }

  // ── Distance To ──
  double distanceTo(double lat, double lng) {
    return _locationService.calculateDistance(
      latitude, // Uses getter with fallback
      longitude, // Uses getter with fallback
      lat,
      lng,
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
