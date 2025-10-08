// https://xuq.supabase.co/functions/v1/order-email
// Content-Type  application/json
// Authorization Anon key of supabae eg ("Bearer eyvdfdfhfgh...................")
// apikey Anon key of supabase eg("eydgdfgdfg.............")
// {
//   "email": "thakuriumesh919@gmail.com",
//   "email_type": "BOOKING_CONFIRMED",
//   "booking_data": {
//     "customer_name": "Thakuri Umesh",
//     "booking_id": "BK-2025-001684",
//     "room_type": "KING SUITE",
//     "checkin_date": "2024-01-15",
//     "checkout_date": "2024-01-20",
//     "number_of_guests": 2,
//     "total_amount": "$450.00",
//     "property_name": "Solti Hotel",
//     "property_address": "Kalimati,Kathmandu",
//     "property_phone": "+977-9868732774"
//   }
// }

import 'package:omspos/config/env_config.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneSignalService {
  static String _baseUrl = '${EnvConfig.supabaseUrl}/functions/v1';
  static const String _orderEmailEndpoint = '/order-email';

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${EnvConfig.supabaseAnonKey}',
      'apikey': EnvConfig.supabaseAnonKey,
    };
  }

  static Future<Map<String, dynamic>> sendEmail({
    required String email,
    required String emailType,
    required Map<String, dynamic> bookingData,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'email': email,
        'email_type': emailType,
        'booking_data': bookingData,
      };

      CustomLog.successLog(value: 'Sending email to: $email, Type: $emailType');

      final response = await http.post(
        Uri.parse('$_baseUrl$_orderEmailEndpoint'),
        headers: _headers,
        body: json.encode(requestBody),
      );
      CustomLog.successLog(
          value:
              'Email API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email sent successfully',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send email',
          'error': 'Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      CustomLog.successLog(value: 'Error sending email: $e');
      return {
        'success': false,
        'message': 'Error sending email',
        'error': e.toString(),
      };
    }
  }
}
