import 'package:omspos/screen/properties/model/properties_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class PropertiesApi {
  static Future<List<PropertiesModel>> getAllProperties({int limit = 10,bool isRefresh = false}) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'property_with_images',
      limit: limit,
      cacheFirst: !isRefresh
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch properties');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((propertyJson) => PropertiesModel.fromJson(propertyJson))
        .toList();
  }

  static Future<List<PropertiesModel>> getPropertiesByArea(String areaId, {bool isRefresh = false}) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'property_with_images',
      filterColumn: 'area_id',
      filterValue: areaId,
      limit: 10,
      cacheFirst: !isRefresh
    );

    if (response['error'] == true) {
      throw Exception(
          response['message'] ?? 'Failed to fetch properties by area');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((propertyJson) => PropertiesModel.fromJson(propertyJson))
        .toList();
  }

}
