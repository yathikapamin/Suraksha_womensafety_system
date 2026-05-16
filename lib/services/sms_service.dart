import 'package:flutter/services.dart';

class SmsService {
  static const MethodChannel _smsChannel = MethodChannel('com.safenetai.safenet_ai/sms');

  // ── Send SMS via Native Logic ──
  Future<bool> sendSms({
    required String to,
    required String message,
  }) async {
    try {
      await _smsChannel.invokeMethod('sendSms', {
        'phone': to,
        'message': message,
      });
      print('SMS sent successfully to $to');
      return true;
    } catch (e) {
      print('SMS error: $e');
      return false;
    }
  }

  // ── Send Emergency Alert SMS ──
  Future<void> sendEmergencyAlert({
    required String userName,
    required double latitude,
    required double longitude,
    required List<String> phoneNumbers,
  }) async {
    final message = '''
🚨 EMERGENCY ALERT - SafeNet AI 🚨

$userName needs immediate help!

📍 Location: https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=18/$latitude/$longitude

⏰ Time: ${DateTime.now().toString().substring(0, 19)}

Please respond immediately or call emergency services.
''';

    for (final phone in phoneNumbers) {
      await sendSms(to: phone, message: message);
    }
  }

  // ── Send Responder Notification SMS ──
  Future<void> sendResponderAlert({
    required String responderPhone,
    required String userName,
    required double latitude,
    required double longitude,
    required bool exactLocation,
  }) async {
    String locationInfo;
    if (exactLocation) {
      locationInfo =
          '📍 Exact Location: https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=18/$latitude/$longitude';
    } else {
      // Approximate location (rounded to 2 decimal places)
      final approxLat = (latitude * 100).round() / 100;
      final approxLng = (longitude * 100).round() / 100;
      locationInfo =
          '📍 Approximate Area: https://www.openstreetmap.org/?mlat=$approxLat&mlon=$approxLng#map=15/$approxLat/$approxLng';
    }

    final message = '''
🛡️ SafeNet AI - Help Needed Nearby 🛡️

$userName has triggered an emergency alert near your location.

$locationInfo

Open SafeNet AI to respond and get directions.
''';

    await sendSms(to: responderPhone, message: message);
  }
}
