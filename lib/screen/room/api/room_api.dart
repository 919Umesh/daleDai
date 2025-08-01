import 'package:omspos/screen/room/model/images_model.dart';
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

  static Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    final response = await SupabaseProvider.insertData(
      tableName: 'bookings',
      data: bookingData,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to create booking');
    }

    return response['data']; // Return the created booking record
  }

  static Future<Map<String, dynamic>> createReview(
      Map<String, dynamic> reviewData) async {
    final response = await SupabaseProvider.insertData(
      tableName: 'reviews',
      data: reviewData,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to create review');
    }

    return response['data']; // Return the created booking record
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

  static Future<List<ImageModel>> getPropertyImages(String propertyId) async {
    final response = await SupabaseProvider.fetchData(
      tableName: 'images',
      filterColumn: 'property_id',
      filterValue: propertyId,
    );

    if (response['error'] == true) {
      throw Exception(response['message'] ?? 'Failed to fetch property images');
    }

    if (response['data'].isEmpty) {
      return [];
    }

    return (response['data'] as List)
        .map((imageJson) => ImageModel.fromJson(imageJson))
        .toList();
  }
}
