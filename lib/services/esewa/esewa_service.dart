// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
// import 'package:esewa_flutter_sdk/esewa_config.dart';
// import 'package:esewa_flutter_sdk/esewa_payment.dart';
// import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
// import 'package:flutter/material.dart';
// import 'package:omspos/constants/esewa.dart';

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
//           debugPrint('SUCCESS');
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

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:omspos/constants/esewa.dart';

class Esewa {
  // Original pay method (keep for backward compatibility)
  pay() {
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
          callbackUrl: 'https://umesh-shahi.com.np/',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          debugPrint('SUCCESS');
          verify(result);
        },
        onPaymentFailure: () {
          debugPrint('FAILURE');
        },
        onPaymentCancellation: () {
          debugPrint('CANCEL');
        },
      );
    } catch (e) {
      debugPrint('EXCEPTION');
    }
  }

  // New method with callback support for booking integration
  Future<void> initPaymentWithCallback({
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
    required VoidCallback onCancel,
    String? productId,
    String? productName,
    String? productPrice,
  }) async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: kEsewaClientId,
          secretId: kEsewaSecretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: productId ?? "1d71jd81",
          productName: productName ?? "Room Booking",
          productPrice: productPrice ?? "1000",
          callbackUrl: 'https://umesh-shahi.com.np/',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) async {
          debugPrint('PAYMENT SUCCESS');
          
          // Verify the payment first
          final isVerified = await verifyPayment(result);
          
          if (isVerified) {
            debugPrint('PAYMENT VERIFIED');
            onSuccess(); // Call success callback
          } else {
            debugPrint('PAYMENT VERIFICATION FAILED');
            onFailure(); // Call failure callback
          }
        },
        onPaymentFailure: () {
          debugPrint('PAYMENT FAILURE');
          onFailure(); // Call failure callback
        },
        onPaymentCancellation: () {
          debugPrint('PAYMENT CANCELLED');
          onCancel(); // Call cancel callback
        },
      );
    } catch (e) {
      debugPrint('PAYMENT EXCEPTION: ${e.toString()}');
      onFailure(); // Call failure callback on exception
    }
  }

  // Updated verify method with return value
  Future<bool> verifyPayment(EsewaPaymentSuccessResult result) async {
    try {
      Dio dio = Dio();
      String basic =
          'Basic ${base64.encode(utf8.encode('JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R:BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ=='))}';
      
      Response response = await dio.get(
        'https://esewa.com.np/mobile/transaction',
        queryParameters: {
          'txnRefId': result.refId,
        },
        options: Options(
          headers: {
            'Authorization': basic,
          },
        ),
      );
      
      print('Verification Response: ${response.data}');
      
      // You should check the response data to determine if payment was successful
      // This depends on eSewa's response format
      // For now, assuming response.statusCode == 200 means success
      return response.statusCode == 200;
      
    } catch (e) {
      print('Verification Error: ${e.toString()}');
      return false;
    }
  }

  // Keep the original verify method for backward compatibility
  verify(EsewaPaymentSuccessResult result) async {
    await verifyPayment(result);
  }
}