import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  final twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  final twilioPhoneNumber = '+16067334723'; 
  final toPhoneNumber = '+916360577780'; 

  final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/'+twilioAccountSid+'/Messages.json');

  try {
    final response = await http.post(
      url, headers: {'Authorization': 'Basic ' + base64Encode(utf8.encode(twilioAccountSid+':'+twilioAuthToken)), 'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'From': twilioPhoneNumber, 'To': toPhoneNumber, 'Body': 'SafeNet SMS Test'},
    );
    final j = jsonDecode(response.body);
    if(response.statusCode == 201) print('SMS SUCCESS: ' + j['sid']);
    else print('SMS ERROR ' + response.statusCode.toString() + ': ' + j['message']);
  } catch(e) {}

  try {
    final response2 = await http.post(
      url, headers: {'Authorization': 'Basic ' + base64Encode(utf8.encode(twilioAccountSid+':'+twilioAuthToken)), 'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'From': 'whatsapp:'+twilioPhoneNumber, 'To': 'whatsapp:'+toPhoneNumber, 'Body': 'SafeNet WTSP Test'},
    );
    final j2 = jsonDecode(response2.body);
    if(response2.statusCode == 201) print('WTSP SUCCESS: ' + j2['sid']);
    else print('WTSP ERROR ' + response2.statusCode.toString() + ': ' + j2['message']);
  } catch(e) {}
}
