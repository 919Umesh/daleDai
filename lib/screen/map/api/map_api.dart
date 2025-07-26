import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class MapLocationApi {
  static Future<List<PropertyModel>> getAllProperties() async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'properties',
      limit: 100, // Increased limit for better map coverage
      cacheFirst: false,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch properties');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((propertyJson) => PropertyModel.fromJson(propertyJson))
        .toList();
  }
}
