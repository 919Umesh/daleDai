import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class HomeApi {
  static Future<List<AreaModel>> getAllAreas() async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'area',
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch areas');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((areaJson) => AreaModel.fromJson(areaJson))
        .toList();
  }

  static Future<AreaModel> getAreaById(String areaId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'area',
      filterColumn: 'area_id',
      filterValue: areaId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch area');
    }

    if (response['data'].isEmpty) {
      throw Exception('Area not found');
    }

    return AreaModel.fromJson(response['data'][0]);
  }
}

