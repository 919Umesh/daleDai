import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:omspos/constants/esewa.dart';
import 'package:omspos/screen/room/model/esewa_payment_model.dart';

class EsewaService {
  static Future<void> initiatePayment({
    required EsewaPaymentModel payment,
    required Function(EsewaPaymentSuccessResult) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onCancellation,
  }) async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: payment.productId,
          productName: payment.productName,
          productPrice: payment.amount,
          callbackUrl: payment.callbackUrl??'https://umesh-shahi.com.np/',
        ),
        onPaymentSuccess: onSuccess,
        onPaymentFailure: onFailure,
        onPaymentCancellation: onCancellation,
      );
    } on Exception catch (e) {
      onFailure(e.toString());
    }
  }

  static Future<Map<String, dynamic>> verifyTransaction(String refId) async {
    try {
      final response = await http.get(
        Uri.parse('$ESEWA_VERIFICATION_URL?txnRefId=$refId'),
        headers: {
          'merchantId': MERCHANT_ID,
          'merchantSecret': MERCHANT_SECRET,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> resultList = jsonDecode(response.body);
        if (resultList.isNotEmpty) {
          return {
            'success': true,
            'status': resultList[0]['transactionDetails']['status'],
            'data': resultList[0],
          };
        } else {
          return {'success': false, 'error': 'Transaction not found'};
        }
      } else {
        return {'success': false, 'error': 'HTTP Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}