// lib/services/cache_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

/// Simple cache service to avoid hitting API rate limits
/// Caches stock data for 5 minutes
class CacheService {
  static const String _prefix = 'stock_cache_';

  /// Save data to cache with current timestamp
  static Future<void> save(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_prefix$key', jsonEncode(cacheData));
      Env.log('Cached data for: $key');
    } catch (e) {
      Env.log('Cache save error: $e');
    }
  }

  /// Get data from cache if not expired (returns null if expired or not found)
  static Future<Map<String, dynamic>?> get(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_prefix$key');
      
      if (cached == null) {
        Env.log('Cache miss: $key');
        return null;
      }
      
      final cacheData = jsonDecode(cached);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      final now = DateTime.now();
      
      // Check if cache is still valid
      if (now.difference(timestamp) < Env.cacheDuration) {
        Env.log('Cache hit: $key (age: ${now.difference(timestamp).inMinutes}m)');
        return cacheData['data'] as Map<String, dynamic>;
      }
      
      // Cache expired
      Env.log('Cache expired: $key');
      await prefs.remove('$_prefix$key');
      return null;
    } catch (e) {
      Env.log('Cache read error: $e');
      return null;
    }
  }

  /// Clear all cached stock data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      Env.log('Cleared all cache');
    } catch (e) {
      Env.log('Cache clear error: $e');
    }
  }

  /// Clear specific cache entry
  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$key');
      Env.log('Cleared cache: $key');
    } catch (e) {
      Env.log('Cache clear error: $e');
    }
  }
}