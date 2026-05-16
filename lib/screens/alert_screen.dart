import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/nearby_alert_service.dart';
import '../models/alert_model.dart';
import '../providers/location_provider.dart';
import '../screens/responder_alert_screen.dart';
import 'package:intl/intl.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final MapController _mapController = MapController();
  final NearbyAlertService _nearbyService = NearbyAlertService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AlertModel>>(
      stream: _nearbyService.getActiveAlertsStream(),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];
        final activeAlerts = alerts.where((a) => a.status == 'active').toList();

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 28),
                    const SizedBox(width: 8),
                    Text('SafeNet AI', style: AppTheme.brandText),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.grey100),
                      child: const Icon(Icons.tune_outlined, color: AppTheme.grey600, size: 18),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Live SOS Monitor', style: AppTheme.displayLarge),
                            const SizedBox(height: 4),
                            Text('Situational awareness of active emergencies.', style: AppTheme.bodyMedium),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── NEW: Live Map UI ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.grey200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Consumer<LocationProvider>(
                                builder: (_, loc, __) => FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
                                    initialZoom: 13,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: AppConstants.osmDarkTileUrl,
                                      userAgentPackageName: 'com.safenetai.safenet_ai',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        // My Location
                                        if (loc.latitude != null)
                                          Marker(
                                            point: LatLng(loc.latitude!, loc.longitude!),
                                            width: 30,
                                            height: 30,
                                            child: const Icon(Icons.my_location, color: AppTheme.primaryBlue, size: 20),
                                          ),
                                        // Active SOS Pins
                                        ...activeAlerts.map((a) => Marker(
                                          point: LatLng(a.latitude, a.longitude),
                                          width: 45,
                                          height: 45,
                                          child: GestureDetector(
                                            onTap: () => _focusAlert(a),
                                            child: Icon(
                                              Icons.location_on,
                                              color: a.tier == 'tier1' ? AppTheme.dangerRed : AppTheme.cautionYellow,
                                              size: 38,
                                            ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(160),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.circle, color: AppTheme.dangerRed, size: 8),
                                      const SizedBox(width: 6),
                                      Text('LIVE', style: AppTheme.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.emergency_share_outlined, color: Colors.white, size: 24),
                                    const SizedBox(height: 8),
                                    Text('ACTIVE SOS', style: AppTheme.bodySmall.copyWith(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                                    Text(activeAlerts.length.toString().padLeft(2, '0'), style: AppTheme.displayLarge.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.cardDecoration,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.verified_user_outlined, color: AppTheme.safeGreen, size: 24),
                                    const SizedBox(height: 8),
                                    Text('RESOLVED', style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 1)),
                                    Text(alerts.where((a) => a.status == 'resolved').length.toString().padLeft(2, '0'), style: AppTheme.displayLarge),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Active Alerts List
                      if (activeAlerts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, color: AppTheme.grey300, size: 60),
                                const SizedBox(height: 12),
                                Text('All Secure', style: AppTheme.labelLarge.copyWith(color: AppTheme.grey400)),
                                Text('No active emergencies in your area.', style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DISPATCH LOG', style: AppTheme.labelLarge.copyWith(fontSize: 12, color: AppTheme.grey500)),
                              const SizedBox(height: 12),
                              ...activeAlerts.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AlertCard(
                                  alert: a,
                                  onView: () => _responderAction(a),
                                ),
                              )).toList(),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _focusAlert(AlertModel alert) {
    _mapController.move(LatLng(alert.latitude, alert.longitude), 15);
  }

  void _responderAction(AlertModel alert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResponderAlertScreen(
          alertData: {
            'alert_id': alert.alertId,
            'victim_name': alert.userName,
            'lat': alert.latitude.toString(),
            'lng': alert.longitude.toString(),
            'type': alert.tier == 'tier1' ? 'tier1_alert' : 'tier2_alert',
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onView;

  const _AlertCard({
    required this.alert,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTier1 = alert.tier == 'tier1';
    final String timeAgo = alert.status == 'resolved' 
        ? 'Resolved' 
        : '${DateTime.now().difference(alert.createdAt).inMinutes}m ago';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isTier1 ? AppTheme.dangerRed : AppTheme.cautionYellow),
              ),
              const SizedBox(width: 8),
              Text(
                isTier1 ? 'HIGH PRIORITY' : 'ASSISTANCE NEEDED', 
                style: AppTheme.bodySmall.copyWith(
                  color: isTier1 ? AppTheme.dangerRed : AppTheme.cautionYellow, 
                  fontWeight: FontWeight.w700, 
                  fontSize: 11, 
                  letterSpacing: 0.5
                )
              ),
              const Spacer(),
              Text(timeAgo, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Emergency: ${alert.userName}', style: AppTheme.labelLarge.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            'Victim is located at GPS: ${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}. Tier ${isTier1 ? "1" : "2"} response protocol active.', 
            style: AppTheme.bodySmall.copyWith(height: 1.4)
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              InkWell(
                onTap: onView,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('RESPOND NOW', style: AppTheme.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('STANDBY', style: AppTheme.bodySmall.copyWith(color: AppTheme.grey700, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
