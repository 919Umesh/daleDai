import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class BookingAPI {
  // Get a single booking by ID
  static Future<BookingModel> getBookingById(String bookingId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'bookings',
      filterColumn: 'booking_id',
      filterValue: bookingId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch booking');
    }

    if (response['data'].isEmpty) {
      throw Exception('Booking not found');
    }

    return BookingModel.fromJson(response['data'][0]);
  }
}
