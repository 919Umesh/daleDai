import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:omspos/screen/booking/api/booking_api.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/pdf/booking_pdf.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingState extends ChangeNotifier {
  BookingState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCalling = false;
  bool get isCalling => _isCalling;

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

  Future<void> loadBookings({bool? isRefresh}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );

      if (userId == "-") throw Exception('User not authenticated');

      _allBookings = await BookingAPI.getBookingsByUserId(
        userId.toString(),
        isRefresh ?? false,
      );
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

  Future<void> generatePdf(BookingModel bookingData) async {
    try {
      // Generate the PDF
      final pdfBytes = await generateBookingPdf(
        bookingData: bookingData,
        companyName: 'Dale Dai',
        companyPhone: '9868732774',
        companyPan: '456452853',
        agentName: 'Umesh',
      );

      // Save the PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/Booking_${bookingData.bookingId}.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      // Open the PDF
      OpenFilex.open(file.path);
    } catch (e) {
      _errorMessage = 'Failed to generate PDF: ${e.toString()}';
      CustomLog.errorLog(value: 'PDF generation error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> callDialer(String phoneNumber) async {
    _isCalling = true;
    notifyListeners();

    try {
      final url = 'tel:$phoneNumber';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch dialer';
      }
    } on PlatformException catch (e) {
      throw 'Failed to make call: ${e.message}';
    } catch (e) {
      throw 'Failed to make call: $e';
    } finally {
      _isCalling = false;
      notifyListeners();
    }
  }

  Future<void> refreshBookings() async => loadBookings(isRefresh: true);
}
