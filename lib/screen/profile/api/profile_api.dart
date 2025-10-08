import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class UserAPI {
  static Future<UserModel> getUserById(String userId,bool? isRefresh) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'users',
      filterColumn: 'user_id',
      filterValue: userId,
      cacheFirst: isRefresh != null ? !isRefresh : false
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch user');
    }

    if (response['data'].isEmpty) {
      throw Exception('User not found');
    }
   
    return UserModel.fromJson(response['data'][0]);
  }
}
