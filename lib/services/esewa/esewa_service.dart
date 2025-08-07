// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
// import 'package:esewa_flutter_sdk/esewa_config.dart';
// import 'package:esewa_flutter_sdk/esewa_payment.dart';
// import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
// import 'package:flutter/material.dart';
// import 'package:omspos/constants/esewa.dart';
// import 'package:omspos/utils/custom_log.dart';

// class Esewa {
//   pay() {
//     try {
//       EsewaFlutterSdk.initPayment(
//         esewaConfig: EsewaConfig(
//           environment: Environment.test,
//           clientId: kEsewaClientId,
//           secretId: kEsewaSecretKey,
//         ),
//         esewaPayment: EsewaPayment(
//           productId: "1d71jd81",
//           productName: "Product One",
//           productPrice: "1000",
//           callbackUrl: 'https://umesh-shahi.com.np/',
//         ),
//         onPaymentSuccess: (EsewaPaymentSuccessResult result) {
//           debugPrint('SUCCESS UMESH');
//           verify(result);
//         },
//         onPaymentFailure: () {
//           debugPrint('FAILURE');
//         },
//         onPaymentCancellation: () {
//           debugPrint('CANCEL');
//         },
//       );
//     } catch (e) {
//       debugPrint('EXCEPTION');
//     }
//   }

//   verify(EsewaPaymentSuccessResult result) async {
//     try {
//       Dio dio = Dio();
//       String basic =
//           'Basic ${base64.encode(utf8.encode('JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R:BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ=='))}';
//       Response response = await dio.get(
//         'https://esewa.com.np/mobile/transaction',
//         queryParameters: {
//           'txnRefId': result.refId,
//         },
//         options: Options(
//           headers: {
//             'Authorization': basic,
//           },
//         ),
//       );
//       print(response.data);
//     } catch (e) {
//       print(e);
//     }
//   }
// }

//This is the new method for the e sewa method for verify the pay after transaction
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:omspos/constants/esewa.dart';
import 'package:omspos/utils/custom_log.dart';

class Esewa {
  Future<void> pay({
    required String amount,
    required Function(EsewaPaymentSuccessResult) onSuccess,
    required Function() onFailure,
    required Function() onCancel,
  }) async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: kEsewaClientId,
          secretId: kEsewaSecretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: "1d71jd81",
          productName: "Product One",
          productPrice: "1000",
          //Call Back Url
          callbackUrl: 'https://umesh-shahi.com.np/',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) async {
          CustomLog.successLog(value: 'eSewa Payment Success: $result');

          // Verify payment with eSewa server
          final verificationSuccess = await _verifyPayment(result);
          if (verificationSuccess) {
            onSuccess(result);
          } else {
            onFailure();
          }
        },
        onPaymentFailure: () {
          CustomLog.errorLog(value: 'eSewa Payment Failed');
          onFailure();
        },
        onPaymentCancellation: () {
          CustomLog.warningLog(value: 'eSewa Payment Cancelled');
          onCancel();
        },
      );
    } catch (e) {
      CustomLog.errorLog(value: 'eSewa Exception: ${e.toString()}');
      onFailure();
    }
  }

  Future<bool> _verifyPayment(EsewaPaymentSuccessResult result) async {
    try {
      Dio dio = Dio();
      String basic =
          'Basic ${base64.encode(utf8.encode('$kEsewaClientId:$kEsewaSecretKey'))}';

      Response response = await dio.get(
        'https://esewa.com.np/mobile/transaction',
        queryParameters: {'txnRefId': result.refId},
        options: Options(headers: {'Authorization': basic}),
      );

      CustomLog.successLog(
          value: 'eSewa Verification Response: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      CustomLog.errorLog(value: 'eSewa Verification Error: ${e.toString()}');
      return false;
    }
  }
}
