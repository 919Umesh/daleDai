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
      cacheFirst: !isRefresh,
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

    static Future<Map<String, dynamic>> addComment(
      {required String bookingId,
      required String propertyId,
      required String tenantId,
      required String comment}) async {
    try {
      // Insert into existing `reviews` table to store comments from tenants.
      final response = await SupabaseProvider.insertData(
        tableName: 'reviews',
        data: {
          'property_id': propertyId,
          'user_id': tenantId,
          'rating': 0,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response['error'] == true) {
        throw Exception(response['message'] ?? 'Failed to add comment');
      }

      return response['data'];
    } catch (e) {
      // Provide a clearer error when the table does not exist or insert fails
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }
}
