import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:omspos/screen/booking/api/booking_api.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:omspos/screen/booking/pdf/booking_pdf.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingState extends ChangeNotifier {
  BookingState();

  BuildContext? _context;
  BuildContext? get context => _context;
  set getContext(BuildContext value) {
    _context = value;
    checkConnection();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  bool _isCalling = false;
  bool get isCalling => _isCalling;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkConnection() async {
    bool network = await CheckNetwork.check();
    if (network) {
      await networkSuccess();
    } else {
      await networkFailed();
    }
  }

  Future<void> networkSuccess() async {
    _isLoading = true;
    notifyListeners();
    CustomLog.successLog(
        value: '--------------Internet Connected-----------------');
    await initialize();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> networkFailed() async {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

  Future<void> initialize() async {
    await clean();
    await loadBookings();
  }

  Future<void> clean() async {
    _isLoading = false;
    _isCalling = false;
    _errorMessage = null;
    _bookings = [];
    notifyListeners();
  }

  Future<void> loadBookings({String? status, bool? isRefresh}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );

      if (userId == "-") throw Exception('User not authenticated');

      _bookings = await BookingAPI.getBookingsByUser(
        userId.toString(),
        status: status ?? "confirmed",
        isRefresh: isRefresh ?? false,
      );
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_bookings.length} bookings');
    } catch (e) {
      _errorMessage = e.toString();
      _bookings = [];
      CustomLog.errorLog(value: 'Booking load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generatePdf(BookingModel bookingData) async {
    try {
      final pdfBytes = await generateBookingPdf(
        bookingData: bookingData,
        companyName: 'Dale Dai',
        companyPhone: '9868732774',
        companyPan: '456452853',
        agentName: 'Umesh',
      );

      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/Booking_${bookingData.bookingId}.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      await OpenFilex.open(file.path);
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
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
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
