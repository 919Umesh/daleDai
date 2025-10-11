import 'package:omspos/screen/map/model/location_view_model.dart';
import 'package:omspos/screen/map/model/map_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class MapLocationApi {
  static Future<List<MapModel>> getAllProperties() async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'properties',
      limit: 100,
      cacheFirst: false,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch properties');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((propertyJson) => MapModel.fromJson(propertyJson))
        .toList();
  }

  static Future<List<LocationView>> getLocations() async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'location_view',
      limit: 100,
      cacheFirst: true,
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
