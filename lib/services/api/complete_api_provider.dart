import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:omspos/services/api/customCache_manager.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:omspos/utils/network_util.dart';




class APIProvider {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  /// ========== GET API ==========
  static Future<dynamic> getAPI({required String endPoint}) async {
    final String url = "dummyUrl";

    CustomLog.warningLog(value: "GET API => $url");

    bool isOnline = await NetworkUtil.hasInternetConnection();

    if (isOnline) {
      try {
        Response response = await _dio.get(url);
        if (response.statusCode == 200) {
          // Cache response
          await CustomCache.instance.putFile(
            url,
            Uint8List.fromList(utf8.encode(jsonEncode(response.data))),
          );
          return response.data;
        } else {
          return _handleErrorResponse(response);
        }
      } catch (e) {
        return _handleException(e, url);
      }
    } else {
      // Load from cache if offline
      return _getFromCache(url);
    }
  }

  /// ========== POST API ==========
  static Future<dynamic> postAPI({required String endPoint, required dynamic body}) async {
    final String url = "dummyap";

    CustomLog.actionLog(value: "POST API => $url \nBody => $body");

    bool isOnline = await NetworkUtil.hasInternetConnection();

    if (!isOnline) {
      return {"error": true, "message": "No internet connection"};
    }

    try {
      Response response = await _dio.post(url, data: body);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e, url);
    }
  }



  static dynamic _handleErrorResponse(Response response) {
    CustomLog.errorLog(value: "API error ${response.statusCode}: ${response.data}");
    return {
      "error": true,
      "status": response.statusCode,
      "message": response.statusMessage ?? "Something went wrong",
    };
  }

  static dynamic _handleException(dynamic e, String url) {
    if (e is DioException) {
      if (e.error is SocketException) {
        CustomLog.errorLog(value: "Socket Exception: $e");
      } else {
        CustomLog.errorLog(value: "Dio Error: $e");
      }
    } else {
      CustomLog.errorLog(value: "Unknown Error: $e");
    }

    return {
      "error": true,
      "message": "Unexpected error occurred",
    };
  }

  /// ========== Cache Handler ==========
  static Future<dynamic> _getFromCache(String url) async {
    try {
      final file = await CustomCache.instance.getFileFromCache(url);
      if (file != null) {
        final jsonString = await file.file.readAsString();
        CustomLog.warningLog(value: "⚠️ Loaded from cache: $url");
        return jsonDecode(jsonString);
      } else {
        return {
          "error": true,
          "message": "No internet and no cached data available",
        };
      }
    } catch (e) {
      CustomLog.errorLog(value: "Cache Read Error: $e");
      return {
        "error": true,
        "message": "Failed to load cached data",
      };
    }
  }
}


// final result = await APIProvider.getAPI(endPoint: "/products");

// if (result['error'] == true) {
//   // Show error UI
// } else {
//   // Use result
// }
