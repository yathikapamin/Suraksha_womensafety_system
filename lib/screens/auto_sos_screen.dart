import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/agent_provider.dart';
import '../services/motion_detection_service.dart';
import '../services/audio_detection_service.dart';
import '../services/voice_detection_service.dart';
import '../services/emergency_contact_service.dart';
import '../services/nearby_alert_service.dart';

class AutoSOSScreen extends StatefulWidget {
  final MotionEvent motionEvent;
  final AudioEvent audioEvent;
  final VoiceEvent voiceEvent;

  const AutoSOSScreen({
    super.key, 
    this.motionEvent = MotionEvent.normal,
    this.audioEvent = AudioEvent.normal,
    this.voiceEvent = VoiceEvent.normal,
  });

  @override
  State<AutoSOSScreen> createState() => _AutoSOSScreenState();
}

class _AutoSOSScreenState extends State<AutoSOSScreen> {
  int _countdown = 5;
  Timer? _timer;
  bool _alertSent = false;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _triggerInstantNearbyBroadcast();
  }

  Future<void> _triggerInstantNearbyBroadcast() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loc = Provider.of<LocationProvider>(context, listen: false);
    
    if (auth.user != null && loc.latitude != null) {
      final nearbyService = NearbyAlertService();
      _alertId = await nearbyService.broadcastEmergency(
        victimId: auth.user!.id,
        victimName: auth.user!.name,
        lat: loc.latitude!,
        lng: loc.longitude!,
      );
    }
  }

  String? _alertId;

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _countdown--);
        if (_countdown <= 0) {
          timer.cancel();
          _triggerEmergency();
        }
      }
    });
  }

  Future<void> _triggerEmergency() async {
    if (_cancelled) return;
    setState(() => _alertSent = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loc = Provider.of<LocationProvider>(context, listen: false);
    final agent = Provider.of<AgentProvider>(context, listen: false);

    final user = auth.user ?? UserModel(id: 'demo', name: 'User', phone: '', email: '');
    final lat = loc.latitude ?? AppConstants.defaultLat;
    final lng = loc.longitude ?? AppConstants.defaultLng;

    // 1. Run the agent pipeline
    agent.runDangerSimulation(user: user, latitude: lat, longitude: lng);

    // 2. Send SMS to all emergency contacts
    final contactService = EmergencyContactService();
    final contacts = await contactService.getContacts(user.id);

    if (contacts.isNotEmpty) {
      await contactService.sendEmergencyAlerts(
        userId: user.id,
        userName: user.name,
        latitude: lat,
        longitude: lng,
        dangerType: _alertTitle,
        contacts: contacts,
      );
    }

    // Nearby alert was already sent instantly in initState
    
    // 3. START LIVE GPS STREAM to Firestore
    if (_alertId != null) {
      // Use the provider's tracking stream
      loc.startTracking(onUpdate: (pos) {
        if (!_cancelled && _alertSent && _alertId != null) {
          final nearbyService = NearbyAlertService();
          nearbyService.updateAlertLocation(_alertId!, pos.latitude, pos.longitude);
        }
      });
    }
  }

  void _cancelAlert() async {
    _cancelled = true;
    _timer?.cancel();

    // Notify nearby responders that user is safe (Clear false alarm)
    if (_alertId != null) {
      final nearbyService = NearbyAlertService();
      await nearbyService.resolveAlert(_alertId!, 'User cancelled SOS');
    }

    if (mounted) Navigator.pop(context);
    
    // Stop background tracking
    final loc = Provider.of<LocationProvider>(context, listen: false);
    loc.stopTracking();
  }

  String get _alertTitle {
    if (widget.voiceEvent != VoiceEvent.normal) {
      return 'Voice Command Triggered';
    }
    if (widget.audioEvent != AudioEvent.normal) {
      switch (widget.audioEvent) {
        case AudioEvent.scream: return 'Scream Detected';
        case AudioEvent.continuousPanic: return 'Loud Panic Detected';
        default: return 'Audio Alert';
      }
    }
    switch (widget.motionEvent) {
      case MotionEvent.phoneDrop: return 'Phone Drop Detected';
      case MotionEvent.violentMotion: return 'Violent Motion / Struggle';
      case MotionEvent.panicRunning: return 'Panic Running Detected';
      case MotionEvent.normal: return 'Unknown Alert';
    }
  }

  IconData get _alertIcon {
    if (widget.voiceEvent != VoiceEvent.normal) {
      return Icons.record_voice_over;
    }
    if (widget.audioEvent != AudioEvent.normal) {
      return Icons.mic_external_on;
    }
    switch (widget.motionEvent) {
      case MotionEvent.phoneDrop: return Icons.phone_android;
      case MotionEvent.violentMotion: return Icons.warning_rounded;
      case MotionEvent.panicRunning: return Icons.directions_run;
      case MotionEvent.normal: return Icons.info;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: _alertSent ? AppTheme.dangerGradient : null,
          color: _alertSent ? null : AppTheme.white,
        ),
        child: SafeArea(
          child: _alertSent ? _buildAlertSent() : _buildCountdown(),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Danger icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.dangerRed.withAlpha(15),
            ),
            child: Icon(_alertIcon, color: AppTheme.dangerRed, size: 44),
          ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
              ),

          const SizedBox(height: 24),

          Text(
            _alertTitle,
            style: AppTheme.headingLarge.copyWith(color: AppTheme.dangerRed),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'Are you safe? If you don\'t respond, an emergency alert will be sent to your family contacts.',
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Countdown
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.dangerRed, width: 4),
            ),
            child: Center(
              child: Text(
                '$_countdown',
                style: AppTheme.displayLarge.copyWith(
                  fontSize: 48,
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1000.ms,
                color: AppTheme.dangerRed.withAlpha(30),
              ),

          const SizedBox(height: 12),

          Text(
            'seconds until alert is sent',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.grey500),
          ),

          const SizedBox(height: 24),

          // Live Transcript Box
          Consumer<VoiceDetectionService>(
            builder: (_, voice, __) {
              if (!voice.isMonitoring) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.grey200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic, color: AppTheme.dangerRed, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'AI HEARING (LIVE TRANSCRIPT)',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.dangerRed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voice.lastRecognizedWords.isEmpty 
                          ? 'Waiting for voice...' 
                          : '"${voice.lastRecognizedWords}"',
                      style: AppTheme.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.grey800,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // I'm Safe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cancelAlert,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: Text('I\'m Safe — Cancel Alert', style: AppTheme.buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.safeGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Send now button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _timer?.cancel();
                _triggerEmergency();
              },
              icon: const Icon(Icons.warning, color: AppTheme.dangerRed),
              label: Text('Send Alert NOW', style: AppTheme.labelLarge.copyWith(color: AppTheme.dangerRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.dangerRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 70)
              .animate()
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 600.ms),

          const SizedBox(height: 20),

          Text(
            'EMERGENCY ALERT\nSENT',
            textAlign: TextAlign.center,
            style: AppTheme.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Your family contacts have been notified with your live location. Help is on the way.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyLarge.copyWith(color: Colors.white.withAlpha(220)),
          ),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _alertInfoRow(Icons.sms, 'SMS & WhatsApp messages sent'),
                const SizedBox(height: 12),
                _alertInfoRow(Icons.location_on, 'Live GPS location shared'),
                const SizedBox(height: 12),
                _alertInfoRow(Icons.broadcast_on_personal, 'Safety Broadcast: 500m radius'),
                const SizedBox(height: 12),
                _alertInfoRow(Icons.shield, 'Nearby responders notified'),
              ],
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Back to Home', style: AppTheme.buttonText.copyWith(color: AppTheme.dangerRed)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(text, style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
      ],
    );
  }
}
