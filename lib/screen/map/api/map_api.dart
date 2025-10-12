import 'package:omspos/screen/map/model/location_view_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class MapLocationApi {
  static Future<List<LocationView>> getLocations(bool? isRefresh) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'location_view',
      limit: 100,
      cacheFirst:  isRefresh != null ? !isRefresh : false,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch properties');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((locationJson) => LocationView.fromJson(locationJson))
        .toList();
  }
}
