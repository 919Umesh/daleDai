import 'package:flutter/material.dart';
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

  List<RoomModel> _rooms = [];
  List<RoomModel> get rooms => _rooms;

  List<ImageModel> _images = [];
  List<ImageModel> get images => _images;

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
    _errorMessage = null;
    _rooms = [];
    _images = [];
    _currentPropertyId = null;
    notifyListeners();
  }

  Future<void> getAllImages(String propertyId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _images = await RoomApi.getPropertyImages(propertyId);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_images.length} images');
    } catch (e) {
      _errorMessage = e.toString();
      _images = [];
      CustomLog.errorLog(value: 'Images load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoomsByProperty(String propertyId) async {
    if (_isLoading) return;

    _isLoading = true;
    _currentPropertyId = propertyId;
    notifyListeners();

    try {
      _rooms = await RoomApi.getRoomsByProperty(propertyId);
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_rooms.length} rooms');
    } catch (e) {
      _errorMessage = e.toString();
      _rooms = [];
      CustomLog.errorLog(value: 'Rooms load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRooms() async {
    if (_currentPropertyId != null) {
      await loadRoomsByProperty(_currentPropertyId!);
    }
  }

  Future<void> refreshImages() async {
    if (_currentPropertyId != null) {
      await getAllImages(_currentPropertyId!);
    }
  }
}