import 'dart:io';


import 'package:dio/dio.dart';

import '../../constants/api_const.dart';
import '../../utils/custom_log.dart';
import '../sharepref/get_all_pref.dart';

class APIProvider {
  static getAPI({required String endPoint}) async {
    try {
      String api = await GetAllPref.apiUrl() + endPoint;
      CustomLog.warningLog(value: " API =>  $api");

      Response response = await Dio().get(api);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return response.data;
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        CustomLog.errorLog(value: " API Provider SOCKET EXCEPTION $e ");
        return ConstantAPIText.errorNetworkMap;
      } else {
        CustomLog.errorLog(value: " API Provider ERROR $e ");
        return ConstantAPIText.errorMap;
      }
    }
  }

  static postAPI({required String endPoint, required String body}) async {
    try {
      String api = await GetAllPref.apiUrl() + endPoint.trim();

      CustomLog.actionLog(value: "API DETAILS => $api $body ");

      var headers = {'Content-Type': 'application/json'};
      Response response =
      await Dio().post(api, data: body, queryParameters: headers);

      ///
      ///
      CustomLog.successLog(value: "StatusCode is ${response.statusCode}");
      CustomLog.actionLog(value: " API RESPONSE => ${response.data} ");

      ///
      ///
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return response.data;
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        CustomLog.errorLog(value: " API Provider SOCKET EXCEPTION $e ");
        return ConstantAPIText.errorNetworkMap;
      } else {
        CustomLog.errorLog(value: " API Provider ERROR $e ");
        return ConstantAPIText.errorMap;
      }
    }
  }
}
