import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/screen/room/model/esewa_payment_model.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/review_user.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/model/room_model_images.dart';
import 'package:omspos/services/esewa/esewa_service.dart';
import 'package:omspos/services/notification/onesignal_service.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';

class RoomState extends ChangeNotifier {
  RoomState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hanInternet => _hasInternet;

  List<RoomModelImage> _rooms = [];
  List<RoomModelImage> get rooms => _rooms;

  RoomModelImage? _room;
  RoomModelImage? get room => _room;

  RoomModel? _roomUpdated;
  RoomModel? get roomUpdated => _roomUpdated;

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
      checkConnection();
    }
  }

  RoomModelImage? _selectedRoom;
  RoomModelImage? get selectedRoom => _selectedRoom;

  Future<void> checkConnection() async {
    bool network = await CheckNetwork.check();
    if (network) {
      await networkSuccess();
    } else {
      await netWorkFailed();
    }
  }

  Future<void> networkSuccess() async {
    _isLoading = true;
    notifyListeners();
    CustomLog.successLog(value: '--------------Internet-----------------');
    await initialize();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> netWorkFailed() async {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

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

  Future<void> processPaymentAndBooking(
      RoomModelImage room, GlobalKey<FormBuilderState> formKey) async {
    if (!formKey.currentState!.saveAndValidate()) return;

    try {
      var userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );
      var landlordId = await SharedPrefService.getValue<String>(
        PrefKey.landLordId,
        defaultValue: "-",
      );
      var propertyId = await SharedPrefService.getValue<String>(
        PrefKey.propertyID,
        defaultValue: "-",
      );

      // Fallback to active property values if not present in shared preferences
      if (propertyId == "-" && _currentPropertyId != null) {
        propertyId = _currentPropertyId;
      }
      if (landlordId == "-" && _property != null) {
        landlordId = _property!.landlordId;
      }

      final formValues = formKey.currentState!.value;
      final formatDate = (DateTime date) => date.toIso8601String().split('T')[0];

      final int rent = (double.tryParse(formValues['monthly_rent'].toString()) ?? 0).toInt();
      final int deposit = (double.tryParse(formValues['security_deposit'].toString()) ?? 0).toInt();

      final Map<String, dynamic> formData = {
        'booking_date': formatDate(formValues['booking_date'] as DateTime),
        'move_in_date': formatDate(formValues['move_in_date'] as DateTime),
        'move_out_date': formValues['move_out_date'] != null
            ? formatDate(formValues['move_out_date'] as DateTime)
            : null,
        'monthly_rent': rent,
        'security_deposit': deposit,
        'profession': formValues['profession'] as String,
        'peoples': (formValues['peoples'] as double).toInt(),
        'room_id': room.roomId,
        'tenant_id': userId,
        'landlord_id': landlordId,
        'property_id': propertyId,
        'payment_method': formValues['payment_method'] as String,
        'status': 'pending',
      };

      CustomLog.successLog(value: 'Booking Form Data: $formData');
      await createBooking(formData, room);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
      CustomLog.errorLog(value: 'Payment Processing Error: ${e.toString()}');
    }
  }

  Future<void> createBooking(
      Map<String, dynamic> formData, RoomModelImage room) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> createdBooking =
          await RoomApi.createBooking(formData);
      CustomLog.successLog(value: 'Booking created: $createdBooking');

      final String bookingId = createdBooking['booking_id']?.toString() ?? '0';

      // Send email notification non-blockingly
      try {
        await OneSignalService.sendEmail(
          email: "thakuriumesh919@gmail.com",
          emailType: "BOOKING_CONFIRMED",
          bookingData: {
            "customer_name": "Tenant",
            "booking_id": bookingId,
            "room_type": room.roomId,
            "checkin_date": formData['move_in_date'],
            "checkout_date": formData['move_out_date'] ?? 'N/A',
            "number_of_guests": formData['peoples'],
            "total_amount": "${(formData['monthly_rent'] + formData['security_deposit'])}",
            "property_name": _property?.title ?? "Property",
            "property_address": _property?.address ?? "Kathmandu",
            "property_phone": "+977-9841000000"
          },
        );
      } catch (emailErr) {
        CustomLog.errorLog(value: 'Non-blocking email notification info: $emailErr');
      }

      if (formData['payment_method'] == 'esewa') {
        await SharedPrefService.setValue<String>(PrefKey.bookingId, bookingId);
        final int totalAmount = (formData['monthly_rent'] + formData['security_deposit']);

        final EsewaPaymentModel paymentDetails = EsewaPaymentModel(
          productId: bookingId,
          productName: 'Room Booking ${room.roomNumber}',
          amount: totalAmount.toString(),
          callbackUrl: "https://daledai.com.np/callback",
        );

        await initiatePayment(paymentDetails);
      } else {
        Fluttertoast.showToast(
          msg: 'Booking created successfully!',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to create booking: ${e.toString()}';
      CustomLog.errorLog(value: _errorMessage!);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initiatePayment(EsewaPaymentModel paymentDetails) async {
    _isLoading = true;
    notifyListeners();

    try {
      await EsewaService.initiatePayment(
        payment: paymentDetails,
        onSuccess: _handlePaymentSuccess,
        onFailure: _handlePaymentFailure,
        onCancellation: _handlePaymentCancellation,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error initiating eSewa payment: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handlePaymentSuccess(EsewaPaymentSuccessResult data) {
    debugPrint(":::eSewa Payment Success::: => $data");
    Fluttertoast.showToast(
      msg: 'Payment successful! Confirming booking...',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.green,
    );
    _verifyTransactionOnServer(data.refId);
  }

  void _handlePaymentFailure(dynamic data) {
    debugPrint(":::eSewa Payment Failure::: => $data");
    Fluttertoast.showToast(
      msg: 'eSewa Payment failed or was declined.',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
    );
  }

  void _handlePaymentCancellation(dynamic data) {
    debugPrint(":::eSewa Payment Cancelled::: => $data");
    Fluttertoast.showToast(
      msg: 'eSewa Payment was cancelled.',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<void> _verifyTransactionOnServer(String refId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await EsewaService.verifyTransaction(refId);

      if (result['success'] == true) {
        if (result['status'] == 'COMPLETE') {
          final bookingId = await SharedPrefService.getValue<String>(
            PrefKey.bookingId,
            defaultValue: "-",
          );
          CustomLog.successLog(
              value: '-------------UpdateBooking-----------------');
          CustomLog.successLog(value: bookingId);
          await updateBooking(bookingId ?? '0');
          debugPrint("Payment verification successful");
        } else {
          debugPrint("Payment verification failed");
        }
      } else {
        debugPrint("Payment verification error");
      }
    } catch (e) {
      debugPrint("Error in transaction verification: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {
        'payment_method': 'esewa',
        'status': 'confirmed',
      };

      await RoomApi.updateBooking(bookingId, updateData);
      CustomLog.successLog(value: '-------------BSDK-----------------');
      _errorMessage = null;
      CustomLog.successLog(value: 'Booking $bookingId updated successfully');
    } catch (e) {
      _errorMessage = e.toString();
      CustomLog.errorLog(value: 'Booking update error: $_errorMessage');
      rethrow; // Re-throw to handle in calling function
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
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
  Future<void> retry() async {
    await checkConnection();
  }
}
