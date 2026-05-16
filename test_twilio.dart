import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  final twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  final twilioPhoneNumber = '+916360577780'; 
  final toPhoneNumber = '+916360577780'; 

  final url = Uri.parse(
    'https://api.twilio.com/2010-04-01/Accounts/'+twilioAccountSid+'/Messages.json',
  );

  print('Sending to Twilio...');
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode(twilioAccountSid+':'+twilioAuthToken)),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': twilioPhoneNumber,
        'To': toPhoneNumber,
        'Body': 'SafeNet Test SMS',
      },
    );
    print('Status: ' + response.statusCode.toString());
    print('Body: ' + response.body);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
