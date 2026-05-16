import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/nearby_alert_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/alert_model.dart';
import '../providers/location_provider.dart';
import '../services/routing_service.dart';
import 'dart:async';

class ResponderAlertScreen extends StatefulWidget {
  final Map<String, dynamic> alertData;

  const ResponderAlertScreen({super.key, required this.alertData});

  @override
  State<ResponderAlertScreen> createState() => _ResponderAlertScreenState();
}

class _ResponderAlertScreenState extends State<ResponderAlertScreen> {
  bool _isResponding = false;
  bool _accepted = false;

  late String _alertId;
  late String _type; // 'tier1_alert' or 'tier2_alert'
  String? _victimName;
  
  // Track current victim location locally for non-stream UI elements
  double? _liveLat;
  double? _liveLng;
  final MapController _mapController = MapController();
  
  List<LatLng> _routePoints = [];
  final RoutingService _routingService = RoutingService();
  Timer? _routeRefreshTimer;
  double? _roadDistance;

  @override
  void initState() {
    super.initState();
    _alertId = widget.alertData['alert_id'];
    _type = widget.alertData['type'];
    _victimName = widget.alertData['victim_name'];
    // Initial coords from widget data
    _liveLat = double.tryParse(widget.alertData['lat'].toString());
    _liveLng = double.tryParse(widget.alertData['lng'].toString());
  }

  Future<void> _acceptRequest() async {
    setState(() => _isResponding = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nearbyService = NearbyAlertService();
    
    final success = await nearbyService.acceptAlert(
      _alertId, 
      auth.user!.id, 
      auth.user!.isVerified
    );

    if (mounted) {
      if (success) {
        setState(() {
          _accepted = true;
          _isResponding = false;
        });
        _startRouteTracking();
      } else {
        setState(() => _isResponding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not accept alert. Help may already be on the way.')),
        );
      }
    }
  }

  Future<void> _openNavigation() async {
    if (_liveLat == null || _liveLng == null) return;
    final url = 'google.navigation:q=$_liveLat,$_liveLng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web map
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=$_liveLat,$_liveLng';
      await launchUrl(Uri.parse(webUrl));
    }
  }
  
  void _startRouteTracking() {
    _updateRoute();
    // Refresh route every 10 seconds while chasing
    _routeRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updateRoute());
  }

  Future<void> _updateRoute() async {
    if (!mounted || !_accepted || _liveLat == null || _liveLng == null) return;

    final myLoc = Provider.of<LocationProvider>(context, listen: false);
    if (myLoc.latitude == null) return;

    final start = LatLng(myLoc.latitude!, myLoc.longitude!);
    final end = LatLng(_liveLat!, _liveLng!);

    final points = await _routingService.getRoute(start, end);
    final dist = await _routingService.getRouteDistance(start, end);

    if (mounted) {
      setState(() {
        _routePoints = points;
        if (dist > 0) _roadDistance = dist;
      });
    }
  }

  @override
  void dispose() {
    _routeRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTier1 = _type == 'tier1_alert';

    return StreamBuilder<AlertModel?>(
      stream: NearbyAlertService().getAlertStream(_alertId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _liveLat = snapshot.data!.latitude;
          _liveLng = snapshot.data!.longitude;
          
          // Auto-center map if victim moves (optional: only if accepted)
          if (_accepted) {
            _mapController.move(LatLng(_liveLat!, _liveLng!), 15);
          }
        }

        final lat = _liveLat ?? 0.0;
        final lng = _liveLng ?? 0.0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppTheme.grey600),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isTier1 ? AppTheme.dangerRed.withAlpha(20) : AppTheme.cautionYellow.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isTier1 ? Icons.emergency : Icons.warning_amber_rounded,
                      color: isTier1 ? AppTheme.dangerRed : AppTheme.cautionYellow,
                      size: 40,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  Text(
                    isTier1 ? 'Emergency Response Requested' : 'Nearby Assistance Needed',
                    textAlign: TextAlign.center,
                    style: AppTheme.headingLarge.copyWith(
                      color: isTier1 ? AppTheme.dangerRed : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isTier1 
                      ? '$_victimName needs help immediately. You are a verified responder nearby.' 
                      : 'An emergency was detected ~300m away from you. Can you assist?',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Distance & ETA Display
                  Consumer<LocationProvider>(
                    builder: (_, myLoc, __) {
                      // Use road distance if available, else fallback to straight line
                      double dist = _roadDistance ?? myLoc.distanceTo(lat, lng);
                      bool isDirect = _roadDistance == null;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withAlpha(10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryBlue.withAlpha(20)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isDirect ? Icons.straighten : Icons.directions_car_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 20
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDirect ? 'Straight Line: ' : 'Shortest Road Path: ',
                                  style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  dist < 1000 ? '${dist.toInt()}m' : '${(dist / 1000).toStringAsFixed(1)}km',
                                  style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue, fontSize: 18),
                                ),
                              ],
                            ),
                            if (!isDirect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Est. Travel Time: ${((dist / 1000) / 40 * 60).toInt()} mins (@ 40km/h)',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Map Preview
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(lat, lng),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: AppConstants.osmDarkTileUrl,
                              userAgentPackageName: 'com.safenetai.safenet_ai',
                            ),
                            if (_routePoints.isNotEmpty)
                              PolylineLayer<Object>(
                                polylines: [
                                  Polyline(
                                    points: _routePoints,
                                    color: AppTheme.primaryBlue,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),

                            // Victim Marker
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(lat, lng),
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.dangerRed.withAlpha(40),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person_pin_circle, color: AppTheme.dangerRed, size: 30),
                                  ),
                                ),
                              ],
                            ),

                            // Responder (Me) Marker
                            if (_accepted)
                              Consumer<LocationProvider>(
                                builder: (_, myLoc, __) {
                                  if (myLoc.latitude == null) return const SizedBox.shrink();
                                  return MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(myLoc.latitude!, myLoc.longitude!),
                                        width: 40,
                                        height: 40,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                          ),
                                          child: const Icon(Icons.my_location, color: AppTheme.primaryBlue, size: 24),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            // Obfuscation removed as per user request to always show Map UI
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!_accepted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isResponding ? null : _acceptRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTier1 ? AppTheme.dangerRed : AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isResponding 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isTier1 ? 'ACCEPT EMERGENCY' : 'HELP NOW', style: AppTheme.buttonText),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Ignore Request', style: AppTheme.labelLarge.copyWith(color: AppTheme.grey500)),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.safeGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.safeGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Request accepted! Live tracking enabled.',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.safeGreen, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openNavigation,
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text('OPEN LIVE NAVIGATION'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
