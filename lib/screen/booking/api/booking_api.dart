import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class BookingAPI {
  static Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'bookings',
      filterColumn: 'tenant_id',
      filterValue: userId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch bookings');
    }

    return (response['data'] as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }
}
