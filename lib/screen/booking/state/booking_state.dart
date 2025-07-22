import 'package:flutter/widgets.dart';
import 'package:omspos/screen/booking/api/booking_api.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';

class BookingState extends ChangeNotifier {
  BookingState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BookingModel> _allBookings = [];
  String? _errorMessage;

  List<BookingModel> get pendingBookings =>
      _allBookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingModel> get confirmedBookings =>
      _allBookings.where((b) => b.status == BookingStatus.confirmed).toList();

  List<BookingModel> get completedBookings =>
      _allBookings.where((b) => b.status == BookingStatus.completed).toList();

  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _resetState();
    await loadBookings();
  }

  Future<void> _resetState() async {
    _isLoading = false;
    _errorMessage = null;
    _allBookings = [];
    notifyListeners();
  }

  Future<void> loadBookings() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );

      if (userId == "-") throw Exception('User not authenticated');

      _allBookings = await BookingAPI.getBookingsByUserId(userId.toString());
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_allBookings.length} bookings');
    } catch (e) {
      _errorMessage = e.toString();
      _allBookings = [];
      CustomLog.errorLog(value: 'Booking load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBookings() async => loadBookings();
}
