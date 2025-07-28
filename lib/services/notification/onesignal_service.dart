import 'package:omspos/utils/custom_log.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneSignalService {
  static const String _appId = 'YOUR_ONESIGNAL_APP_ID';
  static const String _apiKey =
      'YOUR_ONESIGNAL_REST_API_KEY'; // Get this from OneSignal dashboard

  static Future<void> initialize() async {
    // Initialization for push notifications (if needed)
    // Email doesn't require initialization in the SDK
  }

  static Future<void> sendBookingConfirmationEmail({
    required String email,
    required String tenantName,
    required String propertyName,
    required String roomName,
    required DateTime moveInDate,
    required int monthlyRent,
  }) async {
    try {
      const url = 'https://onesignal.com/api/v1/notifications';

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Basic $_apiKey',
      };

      final body = {
        'app_id': _appId,
        'email_subject': 'Booking Confirmation: $roomName at $propertyName',
        'email_body': '''
Hello $tenantName,<br><br>

Your booking for $roomName at $propertyName has been confirmed!<br><br>

<b>Move-in Date:</b> ${moveInDate.toLocal().toString().split(' ')[0]}<br>
<b>Monthly Rent:</b> \$${monthlyRent.toString()}<br><br>

Thank you for choosing us!
''',
        'include_email_tokens': [email],
        'email_from_name': 'Your Company Name', // Change this
        'email_from_address': 'noreply@yourdomain.com', // Change this
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        CustomLog.successLog(value: 'Email notification sent successfully');
      } else {
        CustomLog.errorLog(
          value: 'Failed to send email notification: ${responseData['errors']}',
        );
        throw Exception('Failed to send email: ${responseData['errors']}');
      }
    } catch (e) {
      CustomLog.errorLog(value: 'OneSignal email error: ${e.toString()}');
      rethrow;
    }
  }
}
