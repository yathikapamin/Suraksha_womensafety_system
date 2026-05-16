class AppConstants {
  // ── App Info ──
  static const String appName = 'SafeNet AI';
  static const String appTagline = 'Your Safety, Our Priority';

  // ── Risk Thresholds ──
  static const double riskThresholdSafe = 0.3;
  static const double riskThresholdCaution = 0.6;
  static const double riskThresholdDanger = 0.6;

  // ── Risk Weights ──
  static const double motionWeight = 0.3;
  static const double audioWeight = 0.4;
  static const double locationWeight = 0.3;

  // ── Geo Radius ──
  static const double nearbyRadiusMeters = 500.0;
  static const double nearbyRadiusKm = 0.5;
  static const int maxTier2ExactLocation = 3;

  // ── Firestore Collections ──
  static const String usersCollection = 'users';
  static const String alertsCollection = 'alerts';
  static const String contextCollection = 'context';
  static const String emergencyContactsCollection = 'emergency_contacts';
  static const String verificationCollection = 'verification_requests';
  static const String notificationsCollection = 'notifications';

  // ── Cloudinary Storage ──
  static const String cloudinaryCloudName = 'dycudtwkj';
  static const String cloudinaryUploadPreset = 'safenet-ai';


  // ── ML API ──
  static const String mlApiBaseUrl = 'http://10.0.2.2:5000'; // Android emulator localhost
  static const String riskEndpoint = '/api/calculate-risk';
  static const String locationRiskEndpoint = '/api/location-risk';



  // ── Map Constants ──
  static const double defaultLat = 12.9716;
  static const double defaultLng = 77.5946;
  static const double defaultZoom = 15.0;

  // ── OpenStreetMap ──
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmDarkTileUrl =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';

  // ── Timing ──
  static const int locationUpdateIntervalMs = 5000;
  static const int otpResendSeconds = 60;
  static const int splashDurationMs = 3000;

  // ── Demo Data ──
  static const double demoMotionScore = 0.85;
  static const double demoAudioScore = 0.9;
  static const double demoLocationRisk = 0.7;
}
