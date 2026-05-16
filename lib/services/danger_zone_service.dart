import 'package:geolocator/geolocator.dart';
import '../models/danger_zone.dart';
import 'package:flutter/material.dart';

class DangerZoneService {
  // Radius in meters to trigger an alert
  static const double alertRadiusMeters = 500.0;
  
  // Track zones we are currently inside to avoid spamming alerts
  final Set<String> _activeZones = {};

  final Function(DangerZone zone)? onEnterDangerZone;
  final Function(DangerZone zone)? onExitDangerZone;

  DangerZoneService({
    this.onEnterDangerZone,
    this.onExitDangerZone,
  });

  /// Evaluate the user's distance against all known Bangalore danger zones
  void evaluateZones(Position currentPosition) {
    for (final zone in DangerZonesData.bangaloreZones) {
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      bool isInside = distance <= alertRadiusMeters;
      bool wasInside = _activeZones.contains(zone.area);

      if (isInside && !wasInside) {
        // Entering a danger zone
        _activeZones.add(zone.area);
        if (zone.riskLevel == 'High' || zone.riskLevel == 'Medium') {
          onEnterDangerZone?.call(zone);
        }
      } else if (!isInside && wasInside) {
        // Exiting a danger zone
        _activeZones.remove(zone.area);
        onExitDangerZone?.call(zone);
      }
    }
  }
}
