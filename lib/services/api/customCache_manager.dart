import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCache {
  static CacheManager instance = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 100,
    ),
  );
}
