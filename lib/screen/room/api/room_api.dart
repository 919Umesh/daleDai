import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class RoomApi {
  static Future<List<RoomModel>> getRoomsByProperty(String propertyId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'rooms',
      filterColumn: 'property_id',
      filterValue: propertyId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch rooms');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((roomJson) => RoomModel.fromJson(roomJson))
        .toList();
  }

  static Future<RoomModel> getRoomById(String roomId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'rooms',
      filterColumn: 'room_id',
      filterValue: roomId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch room');
    }

    if (response['data'].isEmpty) {
      throw Exception('Room not found');
    }

    return RoomModel.fromJson(response['data'][0]);
  }

  static Future<RoomModel> createRoom(Map<String, dynamic> roomData) async {
    final response = await SupabaseProvider.insertData(
      tableName: 'rooms',
      data: roomData,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to create room');
    }

    return RoomModel.fromJson(response['data']);
  }

  static Future<RoomModel> updateRoom(
    String roomId,
    Map<String, dynamic> updateData,
  ) async {
    final response = await SupabaseProvider.updateData(
      tableName: 'rooms',
      columnName: 'room_id',
      columnValue: roomId,
      data: updateData,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to update room');
    }

    return RoomModel.fromJson(response['data'][0]);
  }

  static Future<void> deleteRoom(String roomId) async {
    final response = await SupabaseProvider.deleteData(
      tableName: 'rooms',
      columnName: 'room_id',
      columnValue: roomId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to delete room');
    }
  }
}