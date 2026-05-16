import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/location_provider.dart';
import '../models/danger_zone.dart';
import '../config/routes.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (_, loc, __) {
        final lat = loc.latitude ?? AppConstants.defaultLat;
        final lng = loc.longitude ?? AppConstants.defaultLng;

        return SafeArea(
          child: Stack(
            children: [
              // Full Map
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: AppConstants.osmTileUrl,
                    userAgentPackageName: 'com.safenetai.safenet_ai',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(lat, lng),
                        radius: 200,
                        color: AppTheme.dangerRed.withAlpha(15),
                        borderColor: AppTheme.dangerRed.withAlpha(60),
                        borderStrokeWidth: 1.5,
                      ),
                      ...DangerZonesData.bangaloreZones.map((zone) {
                        final isHigh = zone.riskLevel == 'High';
                        return CircleMarker(
                          point: LatLng(zone.latitude, zone.longitude),
                          color: (isHigh ? AppTheme.dangerRed : Colors.orange).withAlpha(40),
                          borderStrokeWidth: 2,
                          borderColor: (isHigh ? AppTheme.dangerRed : Colors.orange).withAlpha(150),
                          radius: 500,
                          useRadiusInMeter: true,
                        );
                      }),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withAlpha(40),
                          ),
                          child: const Center(
                            child: Icon(Icons.my_location, color: AppTheme.primaryBlue, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryBlue.withAlpha(20),
                        child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('SafeNet AI', style: AppTheme.brandText),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.grey100),
                        child: const Icon(Icons.notifications_outlined, color: AppTheme.grey600, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar
              Positioned(
                top: 64,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 15)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.grey400, size: 22),
                      const SizedBox(width: 10),
                      Text('Search locations or safe zones', style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey400)),
                      const Spacer(),
                      const Icon(Icons.mic_rounded, color: AppTheme.grey400, size: 22),
                    ],
                  ),
                ),
              ),

              // High risk zone label
              Positioned(
                top: 130,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (loc.currentDangerZone != null ? AppTheme.dangerRed : AppTheme.safeGreen).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (loc.currentDangerZone != null ? AppTheme.dangerRed : AppTheme.safeGreen).withAlpha(50),
                    ),
                  ),
                  child: Text(
                    loc.currentDangerZone != null 
                        ? 'DANGER ZONE: ${loc.currentDangerZone!.area.toUpperCase()}' 
                        : 'SAFE AREA DETECTED',
                    style: AppTheme.bodySmall.copyWith(
                      color: loc.currentDangerZone != null ? AppTheme.dangerRed : AppTheme.safeGreen, 
                      fontWeight: FontWeight.w700, 
                      fontSize: 10, 
                      letterSpacing: 1
                    ),
                  ),
                ),
              ),

              // Bottom info card
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 30, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Current Location', style: AppTheme.labelLarge),
                                Text('${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SAFETY SCORE', style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, color: AppTheme.primaryBlue, size: 8),
                                    const SizedBox(width: 6),
                                    Text('8.4 / 10', style: AppTheme.headingSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RESPONDERS', style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('3 Nearby', style: AppTheme.headingSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Starting Safe Walk monitoring...')),
                            );
                          },
                          icon: const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
                          label: Text('Initiate Safe Walk', style: AppTheme.buttonText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SOS FAB
              Positioned(
                bottom: 230,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.dangerRed,
                      boxShadow: [BoxShadow(color: AppTheme.dangerRed.withAlpha(60), blurRadius: 15)],
                    ),
                    child: const Icon(Icons.emergency, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
