import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';
import '../config/constants.dart';

import '../services/nearby_alert_service.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import 'package:provider/provider.dart';

class EmergencyAlertScreen extends StatefulWidget {
  const EmergencyAlertScreen({super.key});

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen> {
  bool _broadcastSent = false;
  String? _alertId;

  @override
  void initState() {
    super.initState();
    _triggerNearbyBroadcast();
  }

  Future<void> _triggerNearbyBroadcast() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loc = Provider.of<LocationProvider>(context, listen: false);
    
    if (auth.user != null && loc.latitude != null) {
      final nearbyService = NearbyAlertService();
      final id = await nearbyService.broadcastEmergency(
        victimId: auth.user!.id,
        victimName: auth.user!.name,
        lat: loc.latitude!,
        lng: loc.longitude!,
      );
      if (mounted) {
        setState(() {
          _alertId = id;
          _broadcastSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.dangerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SAFENET AI',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Emergency Mode',
                          style: AppTheme.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.safeGreen)),
                          const SizedBox(width: 6),
                          Text('GPS ACTIVE', style: AppTheme.bodySmall.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Warning Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(30),
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.white, size: 44),
              ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                  ),

              const SizedBox(height: 20),

              Text(
                'DANGER\nDETECTED',
                textAlign: TextAlign.center,
                style: AppTheme.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),

              Text(
                'Dispatching emergency responders\nto your exact coordinates.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge.copyWith(color: Colors.white.withAlpha(200)),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              // Mini map
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.osmDarkTileUrl,
                        userAgentPackageName: 'com.safenetai.safenet_ai',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppTheme.dangerRed, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 24),

              // Broadcast Status Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      _broadcastSent 
                        ? const Icon(Icons.check_circle, color: AppTheme.safeGreen, size: 20)
                        : const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _broadcastSent 
                            ? 'Safety Broadcast Sent to 500m radius' 
                            : 'Scanning for nearby responders...',
                          style: AppTheme.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 12),

              Text(
                '📍 Current Location',
                style: AppTheme.bodySmall.copyWith(color: Colors.white70),
              ),

              const SizedBox(height: 8),

              Text('Automatic Call in 10s', style: AppTheme.bodySmall.copyWith(color: Colors.white54, fontSize: 11)),

              const Spacer(),

              // Call Emergency
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, color: AppTheme.dangerRed),
                    label: Text('CALL EMERGENCY NOW', style: AppTheme.buttonText.copyWith(color: AppTheme.dangerRed)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms),

              const SizedBox(height: 12),

              // Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel Alert',
                  style: AppTheme.labelLarge.copyWith(color: Colors.white.withAlpha(200)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
