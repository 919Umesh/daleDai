import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:omspos/utils/network_util.dart';

class CustomCache {
  static final CacheManager instance = CacheManager(
    Config(
      'customSupabaseCache',
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 100,
    ),
  );
}

class SupabaseProvider {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Generates a unique cache key for each query
  static String _generateCacheKey({
    required String tableName,
    String? filterColumn,
    dynamic filterValue,
    int? limit,
    List<String>? columns,
  }) {
    final params = {
      'table': tableName,
      'filter': filterColumn,
      'value': filterValue?.toString(),
      'limit': limit,
      'columns': columns?.join(','),
    };
    return jsonEncode(params);
  }

  /// ========== GET DATA WITH CACHING ==========
  static Future<dynamic> fetchData({
    required String tableName,
    String? filterColumn,
    dynamic filterValue,
    int? limit,
    List<String>? columns,
    bool cacheFirst = true,
  }) async {
    final cacheKey = _generateCacheKey(
      tableName: tableName,
      filterColumn: filterColumn,
      filterValue: filterValue,
      limit: limit,
      columns: columns,
    );

    CustomLog.warningLog(value: "Supabase GET => $tableName");

    final isOnline = await NetworkUtil.hasInternetConnection();
    if (!isOnline || cacheFirst) {
      try {
        final cachedData = await _getFromCache(cacheKey);
        if (cachedData != null) {
          CustomLog.warningLog(value: "Loaded from cache: $tableName");
          return cachedData;
        }
      } catch (e) {
        CustomLog.errorLog(value: "Cache read error: $e");
      }

      if (!isOnline) {
        return {
          "error": true,
          "message": "No internet and no cached data available",
        };
      }
    }

    try {
      // Create a base query builder
      var queryBuilder =
          _client.from(tableName).select(columns?.join(',') ?? '*');

      // Apply filters if needed
      if (filterColumn != null && filterValue != null) {
        queryBuilder = queryBuilder.eq(filterColumn, filterValue);
      }

      // Execute the query with limit if specified
      final response =
          limit != null ? await queryBuilder.limit(limit) : await queryBuilder;

      await _cacheResponse(cacheKey, response);

      return {
        "error": false,
        "data": response,
      };
    } catch (e) {
      try {
        final cachedData = await _getFromCache(cacheKey);
        if (cachedData != null) {
          CustomLog.warningLog(value: "⚠️ Fallback to cached data: $tableName");
          return cachedData;
        }
      } catch (e) {
        CustomLog.errorLog(value: "Cache fallback error: $e");
      }

      return _handleSupabaseError(e);
    }
  }

  /// ========== INSERT ==========
  static Future<dynamic> insertData({
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    try {
      CustomLog.actionLog(value: "Supabase INSERT => $tableName \nData: $data");

      final response = await _client.from(tableName).insert(data).select();

      await _invalidateTableCache(tableName);

      return {
        "error": false,
        "data": response.first,
      };
    } catch (e) {
      return _handleSupabaseError(e);
    }
  }

  /// ========== UPDATE ==========
  static Future<dynamic> updateData({
    required String tableName,
    required String columnName,
    required dynamic columnValue,
    required Map<String, dynamic> data,
  }) async {
    try {
      CustomLog.actionLog(value: "Supabase UPDATE => $tableName \nData: $data");

      final response = await _client
          .from(tableName)
          .update(data)
          .eq(columnName, columnValue)
          .select();

      await _invalidateTableCache(tableName);

      return {
        "error": false,
        "data": response,
      };
    } catch (e) {
      return _handleSupabaseError(e);
    }
  }

  /// ========== DELETE ==========
  static Future<dynamic> deleteData({
    required String tableName,
    required String columnName,
    required dynamic columnValue,
  }) async {
    try {
      CustomLog.actionLog(value: "Supabase DELETE => $tableName");

      final response =
          await _client.from(tableName).delete().eq(columnName, columnValue);

      await _invalidateTableCache(tableName);

      return {
        "error": false,
        "data": response,
      };
    } catch (e) {
      return _handleSupabaseError(e);
    }
  }

  /// ========== AUTHENTICATION ==========
  static Future<Map<String, dynamic>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw Exception('No user returned');
      return {
        'error': false,
        'userId': response.user!.id,
        'email': response.user!.email ?? email,
        'message': 'Login successful',
      };
    } on AuthException catch (e) {
      return {
        'error': true,
        'message': 'Auth error: ${e.message}',
        'code': e.statusCode?.toString(),
      };
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to authenticate: $e',
      };
    }
  }

  /// ========== GOOGLE SIGN IN HELPERS ==========
  static Future<Map<String, dynamic>> signWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        return {
          'error': true,
          'message': 'Google login failed. No user found',
        };
      }

      return {
        'error': false,
        'userId': user.id,
        'email': user.email,
        'message': 'Google login successful',
      };
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }

  /// ========== CACHE HELPERS ==========

  static Future<void> _cacheResponse(String key, dynamic data) async {
    try {
      await CustomCache.instance.putFile(
        key,
        Uint8List.fromList(utf8.encode(jsonEncode({
          "error": false,
          "data": data,
          "cachedAt": DateTime.now().toIso8601String(),
        }))),
      );
    } catch (e) {
      CustomLog.errorLog(value: "Cache write error: $e");
    }
  }

  static Future<Map<String, dynamic>?> _getFromCache(String key) async {
    try {
      final file = await CustomCache.instance.getFileFromCache(key);
      if (file != null) {
        final jsonString = await file.file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      CustomLog.errorLog(value: "Cache read error: $e");
    }
    return null;
  }

  static Future<void> _invalidateTableCache(String tableName) async {
    try {
      final keysToRemove = <String>[];
      final cacheDir = await CustomCache.instance.getFileFromMemory('keys');

      if (cacheDir != null) {
        final cachedKeys = await cacheDir.file.readAsString();
        final allKeys = cachedKeys.split('\n');

        for (final key in allKeys) {
          if (key.contains('"table":"$tableName"')) {
            keysToRemove.add(key);
          }
        }
      }

      for (final key in keysToRemove) {
        await CustomCache.instance.removeFile(key);
      }
    } catch (e) {
      CustomLog.errorLog(value: "Cache invalidation error: $e");
    }
  }

  /// ========== ERROR HANDLING ==========
  static Map<String, dynamic> _handleSupabaseError(dynamic e) {
    CustomLog.errorLog(value: "Supabase Error: $e");

    return {
      "error": true,
      "message":
          e is PostgrestException ? e.message : "Unexpected error occurred",
      "code": e is PostgrestException ? e.code : null,
    };
  }
}
