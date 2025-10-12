import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class BookingAPI {
  static Future<List<BookingModel>> getBookingsByUser(
    String userId, {
    String? status,
    bool isRefresh = false,
  }) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'booking_details',
      filterColumn: 'tenant_id',
      filterValue: userId,
      cacheFirst: isRefresh != null ? !isRefresh : false,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch bookings');
    }
    final data = response['data'] as List<dynamic>;

 
    final filtered = status != null
        ? data
            .where((e) => e['status']?.toLowerCase() == status.toLowerCase())
            .toList()
        : data;

    return filtered.map((json) => BookingModel.fromJson(json)).toList();
  }
}
