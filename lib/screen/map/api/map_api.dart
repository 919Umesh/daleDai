import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class MapLocationApi {
  // Fetches all active properties (you might want to adjust the query)
  static Future<List<PropertyModel>> getAllProperties() async {
    try {
      // Adjust the select query and filters as needed for your Supabase table
      final response = await SupabaseProvider.fetchData(
        tableName: 'properties',
        // Example: Add filter for active properties if needed in your helper
        // filters: {'is_active': 'eq.true'}, 
        limit: 100, // Increase limit or implement pagination if needed
      );

      if (response['error'] == true) {
        throw Exception(response['message'] ?? 'Failed to fetch properties');
      }

      if (response['data'] == null || (response['data'] as List).isEmpty) {
        return [];
      }

      return (response['data'] as List)
          .map((propertyJson) => PropertyModel.fromJson(propertyJson))
          .toList();
    } catch (e) {
      print("Error fetching properties: $e");
      rethrow; // Re-throw to be caught by the state management
    }
  }
}
