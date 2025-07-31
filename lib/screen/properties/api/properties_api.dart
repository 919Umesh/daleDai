import 'package:omspos/screen/properties/model/properties_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class PropertiesApi {
  static Future<List<PropertiesModel>> getAllProperties({int limit = 10}) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'properties',
      limit: limit,
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

  static Future<List<PropertiesModel>> getPropertiesByArea(String areaId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'properties',
      filterColumn: 'area_id',
      filterValue: areaId,
      limit: 10,
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

  static Future<PropertiesModel> getPropertyById(String propertyId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'properties',
      filterColumn: 'property_id',
      filterValue: propertyId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch property');
    }

    if (response['data'].isEmpty) {
      throw Exception('Property not found');
    }

    return PropertiesModel.fromJson(response['data'][0]);
  }


}
