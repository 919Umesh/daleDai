import 'package:flutter/material.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/review_user.dart';
import 'package:omspos/screen/room/model/room_model_images.dart';
import 'package:omspos/utils/custom_log.dart';

class RoomState extends ChangeNotifier {
  RoomState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<RoomModelImage> _rooms = [];
  List<RoomModelImage> get rooms => _rooms;

  RoomModelImage? _room;
  RoomModelImage? get room => _room;

  List<ImageModel> _images = [];
  List<ImageModel> get images => _images;

  List<ReviewUser> _reviews = [];
  List<ReviewUser> get reviews => _reviews;

  PropertyModel? _property;
  PropertyModel? get property => _property;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentPropertyId;
  String? get currentPropertyId => _currentPropertyId;
  set currentPropertyId(String? propertyId) {
    _currentPropertyId = propertyId;
    if (propertyId != null) {
      initialize();
    }
  }

  RoomModelImage? _selectedRoom;
  RoomModelImage? get selectedRoom => _selectedRoom;

  Future<void> initialize() async {
    if (_currentPropertyId == null) return;
    await clean();
    await loadRooms(_currentPropertyId!);
    await loadImages(_currentPropertyId!);
    await loadReviews(_currentPropertyId!);
    await loadPropertyDetails(_currentPropertyId!);
  }

  Future<void> clean() async {
    _isLoading = false;
    _errorMessage = null;
    _rooms = [];
    _images = [];
    _reviews = [];
    _property = null;
    _room = null;
    _selectedRoom = null;
    notifyListeners();
  }

  Future<void> loadPropertyDetails(String propertyId,
      {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _property =
          await RoomApi.getPropertyDetails(propertyId, isRefresh: refresh);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_property!.title} property');
    } catch (e) {
      _errorMessage = e.toString();
      CustomLog.errorLog(value: 'Property load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRooms(String propertyId, {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await RoomApi.getRoomsByProperty(propertyId, isRefresh: refresh);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_rooms.length} Rooms');
    } catch (e) {
      _errorMessage = e.toString();
      _rooms = [];
      CustomLog.errorLog(value: 'Rooms load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoomDetails(String roomId, {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _room = await RoomApi.getRoomsDetails(roomId, isRefresh: refresh);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_property!.title} property');
    } catch (e) {
      _errorMessage = e.toString();
      CustomLog.errorLog(value: 'Property load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadImages(String propertyId, {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _images = await RoomApi.getPropertyImages(propertyId, isRefresh: refresh);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_images.length} Images');
    } catch (e) {
      _errorMessage = e.toString();
      _images = [];
      CustomLog.errorLog(value: 'Images load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviews(String propertyId, {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _reviews =
          await RoomApi.getReviewsByProperty(propertyId, isRefresh: refresh);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_images.length} Reviews');
    } catch (e) {
      _errorMessage = e.toString();
      _reviews = [];
      CustomLog.errorLog(value: 'Reviews load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // // Data creation methods
  // Future<void> createBooking(Map<String, dynamic> formData) async {
  //   _setLoading(true);

  //   try {
  //     await RoomApi.createBooking(formData);
  //     _handleSuccess('Booking created successfully!');

  //     // Refresh rooms data to reflect booking changes
  //     if (_currentPropertyId != null) {
  //       await _loadRooms(_currentPropertyId!);
  //     }
  //   } catch (e) {
  //     _setError('Failed to create booking: ${e.toString()}');
  //     rethrow;
  //   }
  // }

  // Future<void> createReview(Map<String, dynamic> formData) async {
  //   _setLoading(true);

  //   try {
  //     await RoomApi.createReview(formData);
  //     _handleSuccess('Review created successfully!');
  //   } catch (e) {
  //     _setError('Failed to create review: ${e.toString()}');
  //     rethrow;
  //   }
  // }
}
