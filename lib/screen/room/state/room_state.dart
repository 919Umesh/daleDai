import 'package:flutter/material.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/review_model.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/utils/custom_log.dart';

class RoomState extends ChangeNotifier {
  // Private state variables
  BuildContext? _context;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final List<RoomModel> _rooms = [];
  final List<ImageModel> _images = [];
  final List<ReviewModel> _reviews = [];
  String? _errorMessage;
  String? _currentPropertyId;
  RoomModel? _selectedRoom;

  // Public getters
  BuildContext? get context => _context;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  List<RoomModel> get rooms => List.unmodifiable(_rooms);
  List<ImageModel> get images => List.unmodifiable(_images);
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  String? get errorMessage => _errorMessage;
  String? get currentPropertyId => _currentPropertyId;
  RoomModel? get selectedRoom => _selectedRoom;

  // Context setter
  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  // Initialization and cleanup
  Future<void> initialize() async => await clean();

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
  Future<void> getAllImages(String propertyId, {bool isRefresh = false}) async {
    try {
      _setRefreshingState(isRefresh, true);
      _images.clear();

      final images = await RoomApi.getPropertyImages(propertyId);
      _images.addAll(images);
      _handleSuccess('Loaded ${_images.length} images');
    } catch (e) {
      _handleError('Images load error: ${e.toString()}');
      _images.clear();
    } finally {
      _setRefreshingState(isRefresh, false);
    }
  }

  Future<void> loadRoomsByProperty(String propertyId,
      {bool isRefresh = false}) async {
    if (_shouldSkipLoad(propertyId, isRefresh)) return;

    _currentPropertyId = propertyId;
    _setLoadingState(isRefresh, true);

    try {
      _rooms.clear();
      final rooms = await RoomApi.getRoomsByProperty(propertyId);
      _rooms.addAll(rooms);
      _handleSuccess('Loaded ${_rooms.length} rooms');
    } catch (e) {
      _handleError('Rooms load error: ${e.toString()}');
      _rooms.clear();
    } finally {
      _setLoadingState(isRefresh, false);
    }
  }

  Future<void> getRoomDetails(String roomID, {bool isRefresh = false}) async {
    try {
      _setLoadingState(isRefresh, true);
      _selectedRoom = null;

      final room = await RoomApi.getRoomById(roomID);
      _selectedRoom = room;
      _handleSuccess('Loaded room details');
    } catch (e) {
      _handleError('Room details load error: ${e.toString()}');
      _selectedRoom = null;
    } finally {
      _setLoadingState(isRefresh, false);
    }
  }

  // Data creation methods
  Future<void> createBooking(Map<String, dynamic> formData) async {
    try {
      _setLoading(true);

      await RoomApi.createBooking(formData);
      _handleSuccess('Booking created successfully!');

      if (_currentPropertyId != null) {
        await loadRoomsByProperty(_currentPropertyId!);
      }
    } catch (e) {
      _handleError('Booking failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createReview(Map<String, dynamic> formData) async {
    try {
      _setLoading(true);

      await RoomApi.createReview(formData);
      _handleSuccess('Review created successfully!');

      if (_currentPropertyId != null) {
        await getReviewsByProperty(_currentPropertyId!);
      }
    } catch (e) {
      _handleError('Review creation failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getReviewsByProperty(String propertyId,
      {bool isRefresh = false}) async {
    try {
      _setRefreshingState(isRefresh, true);
      _reviews.clear();

      final reviews = await RoomApi.getReviewsByProperty(propertyId);
      _reviews.addAll(reviews);
      if (reviews is List) {
        for (var review in reviews) {
          CustomLog.successLog(value: review.comment);
        }
      }
      _handleSuccess('Loaded ${_reviews.length} reviews');
    } catch (e) {
      _handleError('Reviews load error: ${e.toString()}');
      _reviews.clear();
    } finally {
      _setRefreshingState(isRefresh, false);
    }
  }

  // Refresh methods
  Future<void> refreshData() async {
    if (_currentPropertyId == null || _isRefreshing) return;

    try {
      await Future.wait([
        loadRoomsByProperty(_currentPropertyId!, isRefresh: true),
        getAllImages(_currentPropertyId!, isRefresh: true),
        getReviewsByProperty(_currentPropertyId!, isRefresh: true),
      ]);
    } catch (e) {
      CustomLog.errorLog(value: 'Refresh error: ${e.toString()}');
    }
  }

  Future<void> refreshRooms() async {
    if (_currentPropertyId != null) {
      await loadRoomsByProperty(_currentPropertyId!, isRefresh: true);
    }
  }

  Future<void> refreshImages() async {
    if (_currentPropertyId != null) {
      await getAllImages(_currentPropertyId!, isRefresh: true);
    }
  }

  Future<void> refreshReviews() async {
    if (_currentPropertyId != null) {
      await getReviewsByProperty(_currentPropertyId!, isRefresh: true);
    }
  }

  // Cleanup
  @override
  void dispose() {
    _context = null;
    super.dispose();
  }

  // Private helper methods
  bool _shouldSkipLoad(String propertyId, bool isRefresh) {
    return (_isLoading && !isRefresh) ||
        (_currentPropertyId == propertyId && _rooms.isNotEmpty && !isRefresh);
  }

  void _setLoadingState(bool isRefresh, bool value) {
    isRefresh ? _setRefreshing(value) : _setLoading(value);
  }

  void _setRefreshingState(bool isRefresh, bool value) {
    isRefresh ? _setRefreshing(value) : _setLoading(value);
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _handleSuccess(String message) {
    _setError(null);
    CustomLog.successLog(value: message);
  }

  void _handleError(String error) {
    _setError(error.toString());
    CustomLog.errorLog(value: error);
  }
}
