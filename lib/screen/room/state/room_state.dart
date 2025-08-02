import 'package:flutter/material.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/review_model.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/utils/custom_log.dart';

class RoomState extends ChangeNotifier {
  // Private state variables
  bool _isLoading = false;
  bool _isRefreshing = false;
  final List<RoomModel> _rooms = [];
  final List<ImageModel> _images = [];
  final List<ReviewModel> _reviews = [];
  String? _errorMessage;
  String? _currentPropertyId;
  RoomModel? _selectedRoom;

  // Public getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  List<RoomModel> get rooms => List.unmodifiable(_rooms);
  List<ImageModel> get images => List.unmodifiable(_images);
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  String? get errorMessage => _errorMessage;
  String? get currentPropertyId => _currentPropertyId;
  RoomModel? get selectedRoom => _selectedRoom;

  // Helper methods for state management
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _clearError();
      notifyListeners();
    }
  }

  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    _isRefreshing = false;
    CustomLog.errorLog(value: error);
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  void _handleSuccess(String message) {
    _clearError();
    _isLoading = false;
    _isRefreshing = false;
    CustomLog.successLog(value: message);
    notifyListeners();
  }

  // Initialization and cleanup
  Future<void> initialize() async {
    await clean();
  }

  Future<void> clean() async {
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    _rooms.clear();
    _images.clear();
    _reviews.clear();
    _currentPropertyId = null;
    _selectedRoom = null;
    notifyListeners();
  }

  // Data loading methods
  Future<void> loadInitialData(String propertyId) async {
    _currentPropertyId = propertyId;
    _setLoading(true);

    try {
      await Future.wait([
        _loadRooms(propertyId),
        _loadImages(propertyId),
        _loadReviews(propertyId),
      ]);
      _handleSuccess('Initial data loaded successfully');
    } catch (e) {
      _setError('Failed to load initial data: ${e.toString()}');
    }
  }

  Future<void> refreshData() async {
    if (_currentPropertyId == null) return;
    
    _setRefreshing(true);
    try {
      await Future.wait([
        _loadRooms(_currentPropertyId!),
        _loadImages(_currentPropertyId!),
        _loadReviews(_currentPropertyId!),
      ]);
      _handleSuccess('Data refreshed successfully');
    } catch (e) {
      _setError('Failed to refresh data: ${e.toString()}');
    }
  }

  Future<void> _loadRooms(String propertyId) async {
    try {
      _rooms.clear();
      final rooms = await RoomApi.getRoomsByProperty(propertyId);
      _rooms.addAll(rooms);
    } catch (e) {
      throw Exception('Failed to load rooms: ${e.toString()}');
    }
  }

  Future<void> _loadImages(String propertyId) async {
    try {
      _images.clear();
      final images = await RoomApi.getPropertyImages(propertyId);
      _images.addAll(images);
    } catch (e) {
      throw Exception('Failed to load images: ${e.toString()}');
    }
  }

  Future<void> _loadReviews(String propertyId) async {
    try {
      _reviews.clear();
      final reviews = await RoomApi.getReviewsByProperty(propertyId);
      _reviews.addAll(reviews);
    } catch (e) {
      throw Exception('Failed to load reviews: ${e.toString()}');
    }
  }

  Future<void> loadRoomsByProperty(String propertyId, {bool isRefresh = false}) async {
    _currentPropertyId = propertyId;
    
    if (isRefresh) {
      _setRefreshing(true);
    } else {
      _setLoading(true);
    }

    try {
      await _loadRooms(propertyId);
      _handleSuccess('Loaded ${_rooms.length} rooms');
    } catch (e) {
      _setError('Failed to load rooms: ${e.toString()}');
    }
  }

  Future<void> getAllImages(String propertyId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _setRefreshing(true);
    } else {
      _setLoading(true);
    }

    try {
      await _loadImages(propertyId);
      _handleSuccess('Loaded ${_images.length} images');
    } catch (e) {
      _setError('Failed to load images: ${e.toString()}');
    }
  }

  Future<void> getReviewsByProperty(String propertyId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _setRefreshing(true);
    } else {
      _setLoading(true);
    }

    try {
      await _loadReviews(propertyId);
      _handleSuccess('Loaded ${_reviews.length} reviews');
      
      // Log review comments for debugging
      for (var review in _reviews) {
        CustomLog.successLog(value: 'Review: ${review.comment}');
      }
    } catch (e) {
      _setError('Failed to load reviews: ${e.toString()}');
    }
  }

  Future<void> getRoomDetails(String roomId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _setRefreshing(true);
    } else {
      _setLoading(true);
    }

    try {
      _selectedRoom = null;
      final room = await RoomApi.getRoomById(roomId);
      _selectedRoom = room;
      _handleSuccess('Room details loaded successfully');
    } catch (e) {
      _setError('Failed to load room details: ${e.toString()}');
    }
  }

  // Data creation methods
  Future<void> createBooking(Map<String, dynamic> formData) async {
    _setLoading(true);

    try {
      await RoomApi.createBooking(formData);
      _handleSuccess('Booking created successfully!');

      // Refresh rooms data to reflect booking changes
      if (_currentPropertyId != null) {
        await _loadRooms(_currentPropertyId!);
      }
    } catch (e) {
      _setError('Failed to create booking: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> createReview(Map<String, dynamic> formData) async {
    _setLoading(true);

    try {
      await RoomApi.createReview(formData);
      _handleSuccess('Review created successfully!');

      // Refresh reviews data to show new review
      if (_currentPropertyId != null) {
        await _loadReviews(_currentPropertyId!);
      }
    } catch (e) {
      _setError('Failed to create review: ${e.toString()}');
      rethrow;
    }
  }

  // Utility methods
  void clearSelectedRoom() {
    _selectedRoom = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  bool get hasData => _rooms.isNotEmpty || _images.isNotEmpty || _reviews.isNotEmpty;
  bool get isEmpty => !hasData && !_isLoading;

  @override
  void dispose() {
    clean();
    super.dispose();
  }
}