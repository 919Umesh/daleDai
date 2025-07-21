// room_state.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/utils/custom_log.dart';

class RoomState extends ChangeNotifier {
  RoomState();

  BuildContext? _context;
  BuildContext? get context => _context;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  List<RoomModel> _rooms = [];
  List<RoomModel> get rooms => List.unmodifiable(_rooms);

  List<ImageModel> _images = [];
  List<ImageModel> get images => List.unmodifiable(_images);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentPropertyId;
  String? get currentPropertyId => _currentPropertyId;

  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  Future<void> initialize() async {
    await clean();
  }

  Future<void> clean() async {
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    _rooms.clear();
    _images.clear();
    _currentPropertyId = null;
    notifyListeners();
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

  Future<void> getAllImages(String propertyId, {bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _setRefreshing(true);
      }

      final images = await RoomApi.getPropertyImages(propertyId);
      _images = images;
      _setError(null);
      CustomLog.successLog(value: 'Loaded ${_images.length} images');
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      _images.clear();
      CustomLog.errorLog(value: 'Images load error: $errorMsg');
    } finally {
      if (isRefresh) {
        _setRefreshing(false);
      } else {
        _setLoading(false);
      }
      notifyListeners();
    }
  }

  Future<void> loadRoomsByProperty(String propertyId,
      {bool isRefresh = false}) async {
    // Prevent multiple concurrent loads for the same property
    if ((_isLoading && !isRefresh) ||
        (_currentPropertyId == propertyId && _rooms.isNotEmpty && !isRefresh)) {
      return;
    }

    _currentPropertyId = propertyId;

    if (isRefresh) {
      _setRefreshing(true);
    } else {
      _setLoading(true);
    }

    try {
      final rooms = await RoomApi.getRoomsByProperty(propertyId);
      _rooms = rooms;
      _setError(null);
      CustomLog.successLog(value: 'Loaded ${_rooms.length} rooms');
    } catch (e) {
      final errorMsg = e.toString();
      _setError(errorMsg);
      _rooms.clear();
      CustomLog.errorLog(value: 'Rooms load error: $errorMsg');
    } finally {
      if (isRefresh) {
        _setRefreshing(false);
      } else {
        _setLoading(false);
      }
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (_currentPropertyId == null || _isRefreshing) return;

    try {
      await Future.wait([
        loadRoomsByProperty(_currentPropertyId!, isRefresh: true),
        getAllImages(_currentPropertyId!, isRefresh: true),
      ]);
    } catch (e) {
      CustomLog.errorLog(value: 'Refresh error: ${e.toString()}');
    }
  }

  // Separate methods for individual refresh (kept for backward compatibility)
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

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }
}
