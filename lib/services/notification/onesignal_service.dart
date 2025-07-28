class OneSignalService {
  static const String _appId = 'YOUR_ONESIGNAL_APP_ID';

  static Future<void> initialize() async {
    await OneSignal.initialize(_appId);
    OneSignal.Notifications.requestPermission(true);
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
      final response = await OneSignal.Notifications.sendEmail(
        emailAddress: email,
        subject: 'Booking Confirmation: $roomName at $propertyName',
        body: '''
Hello $tenantName,

Your booking for $roomName at $propertyName has been confirmed!

Move-in Date: ${moveInDate.toLocal().toString().split(' ')[0]}
Monthly Rent: \$${monthlyRent.toString()}

Thank you for choosing us!
''',
      );

      if (response['success'] == true) {
        CustomLog.successLog(value: 'Email notification sent successfully');
      } else {
        CustomLog.errorLog(
            value: 'Failed to send email notification: ${response['errors']}');
      }
    } catch (e) {
      CustomLog.errorLog(value: 'OneSignal email error: ${e.toString()}');
    }
  }
}
