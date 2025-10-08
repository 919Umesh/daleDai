import 'dart:io';

import 'package:dio/dio.dart';

import '../../constants/api_const.dart';
import '../../utils/custom_log.dart';

class APIProvider {
  static getAPI({required String endPoint}) async {
    try {
      String api = "dummyurl";
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
      String api = "dummyurl";

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
//Umesh Shahi
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/foundation.dart';

// class APIProvider {
//   static final CacheManager _cacheManager = DefaultCacheManager();
//   static const Duration _cacheDuration = Duration(days: 30); // Cache for 30 days

//   static Future<dynamic> getAPI({
//     required String endPoint,
//     bool forceRefresh = false,
//     Map<String, String>? headers,
//   }) async {
//     try {
//       String api = "dummyurl"; // Replace with your actual API URL
//       CustomLog.warningLog(value: "API => $api");

//       // Check if we have cached data and not forcing refresh
//       if (!forceRefresh) {
//         final cachedFile = await _cacheManager.getFileFromCache(api);
//         if (cachedFile != null) {
//           final file = cachedFile.file;
//           final cachedData = await file.readAsString();
//           CustomLog.infoLog(value: "Using cached data for $endPoint");
          
//           try {
//             return _parseResponse(cachedData);
//           } catch (e) {
//             CustomLog.errorLog(value: "Failed to parse cached data: $e");
//             // Continue to fetch fresh data if cache parsing fails
//           }
//         }
//       }

//       // Fetch fresh data from API
//       Response response = await Dio().get(
//         api,
//         options: Options(headers: headers),
//       );

//       if (response.statusCode == 200) {
//         // Cache the successful response
//         await _cacheResponse(api, response.data);
//         return response.data;
//       } else {
//         // Try to return cached data if available
//         final cachedFile = await _cacheManager.getFileFromCache(api);
//         if (cachedFile != null) {
//           final file = cachedFile.file;
//           final cachedData = await file.readAsString();
//           CustomLog.infoLog(value: "Using cached data for $endPoint due to API error");
//           return _parseResponse(cachedData);
//         }
//         return response.data;
//       }
//     } on DioException catch (e) {
//       // Try to return cached data on network errors
//       final cachedFile = await _cacheManager.getFileFromCache(api);
//       if (cachedFile != null) {
//         final file = cachedFile.file;
//         final cachedData = await file.readAsString();
//         CustomLog.infoLog(value: "Using cached data for $endPoint due to network error: ${e.message}");
//         return _parseResponse(cachedData);
//       }
      
//       if (e.error is SocketException) {
//         CustomLog.errorLog(value: "API Provider SOCKET EXCEPTION $e");
//         return ConstantAPIText.errorNetworkMap;
//       } else {
//         CustomLog.errorLog(value: "API Provider ERROR $e");
//         return ConstantAPIText.errorMap;
//       }
//     } catch (e) {
//       // Try to return cached data on any other errors
//       final cachedFile = await _cacheManager.getFileFromCache(api);
//       if (cachedFile != null) {
//         final file = cachedFile.file;
//         final cachedData = await file.readAsString();
//         CustomLog.infoLog(value: "Using cached data for $endPoint due to unexpected error: $e");
//         return _parseResponse(cachedData);
//       }
      
//       CustomLog.errorLog(value: "API Provider UNEXPECTED ERROR $e");
//       return ConstantAPIText.errorMap;
//     }
//   }

//   static Future<dynamic> postAPI({
//     required String endPoint,
//     required dynamic body,
//     bool forceRefresh = false,
//     Map<String, String>? headers,
//   }) async {
//     try {
//       String api = "dummyurl"; // Replace with your actual API URL

//       CustomLog.actionLog(value: "API DETAILS => $api $body");

//       // For POST requests, we can cache based on a combination of endpoint and body
//       final cacheKey = _generatePostCacheKey(api, body);
      
//       // Check if we have cached data and not forcing refresh
//       if (!forceRefresh) {
//         final cachedFile = await _cacheManager.getFileFromCache(cacheKey);
//         if (cachedFile != null) {
//           final file = cachedFile.file;
//           final cachedData = await file.readAsString();
//           CustomLog.infoLog(value: "Using cached data for POST $endPoint");
//           return _parseResponse(cachedData);
//         }
//       }

//       final Options options = Options(headers: headers ?? {'Content-Type': 'application/json'});
//       Response response = await Dio().post(api, data: body, options: options);

//       CustomLog.successLog(value: "StatusCode is ${response.statusCode}");
//       CustomLog.actionLog(value: "API RESPONSE => ${response.data}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // Cache successful POST responses if appropriate (e.g., for idempotent requests)
//         await _cacheResponse(cacheKey, response.data);
//         return response.data;
//       } else {
//         return response.data;
//       }
//     } on DioException catch (e) {
//       // For POST requests, we generally don't fall back to cache
//       // since POST typically changes server state
//       if (e.error is SocketException) {
//         CustomLog.errorLog(value: "API Provider SOCKET EXCEPTION $e");
//         return ConstantAPIText.errorNetworkMap;
//       } else {
//         CustomLog.errorLog(value: "API Provider ERROR $e");
//         return ConstantAPIText.errorMap;
//       }
//     }
//   }

//   // Helper method to cache API responses
//   static Future<void> _cacheResponse(String key, dynamic data) async {
//     try {
//       String dataToCache;
//       if (data is Map || data is List) {
//         dataToCache = jsonEncode(data);
//       } else if (data is String) {
//         dataToCache = data;
//       } else {
//         dataToCache = data.toString();
//       }
      
//       await _cacheManager.putFile(
//         key,
//         Uint8List.fromList(dataToCache.codeUnits),
//         maxAge: _cacheDuration,
//       );
//       CustomLog.infoLog(value: "Cached response for key: $key");
//     } catch (e) {
//       CustomLog.errorLog(value: "Failed to cache response: $e");
//     }
//   }

//   // Helper method to parse response data
//   static dynamic _parseResponse(String data) {
//     try {
//       return jsonDecode(data);
//     } catch (e) {
//       return data;
//     }
//   }

//   // Generate a unique cache key for POST requests based on endpoint and body
//   static String _generatePostCacheKey(String endpoint, dynamic body) {
//     String bodyHash = '';
//     if (body is Map) {
//       bodyHash = jsonEncode(body);
//     } else if (body is String) {
//       bodyHash = body;
//     } else {
//       bodyHash = body.toString();
//     }
    
//     return '$endPoint${bodyHash.hashCode}';
//   }

//   // Method to clear cache for specific endpoint or all cache
//   static Future<void> clearCache({String? key}) async {
//     try {
//       if (key != null) {
//         await _cacheManager.removeFile(key);
//         CustomLog.infoLog(value: "Cleared cache for key: $key");
//       } else {
//         await _cacheManager.emptyCache();
//         CustomLog.infoLog(value: "Cleared all API cache");
//       }
//     } catch (e) {
//       CustomLog.errorLog(value: "Failed to clear cache: $e");
//     }
//   }

//   // Method to get cache information
//   static Future<FileInfo?> getCacheInfo(String key) async {
//     return await _cacheManager.getFileFromCache(key);
//   }
// }
