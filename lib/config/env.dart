// lib/config/env.dart
import 'package:flutter/foundation.dart';
class Env {
  // ⚠️ REPLACE THESE WITH YOUR ACTUAL API KEYS
  static const String alphaVantageKey = '1KRHT1HG2ULDZNLB';
  static const String newsApiKey = '0bb5a08cd7084c4f9c948d603d5edc26';
  
  // API Endpoints
  static const String alphaVantageBase = 'https://www.alphavantage.co/query';
  static const String newsApiBase = 'https://newsapi.org/v2/everything';
  
  // Cache duration (15 minutes to avoid hitting API limits)
  // Stock prices don't change that rapidly, so we can cache longer
  static const Duration cacheDuration = Duration(minutes: 15);
  
  // News cache duration (60 minutes - news changes slower)
  static const Duration newsCacheDuration = Duration(minutes: 60);
  // Enable/disable real API (set to false to use mock data during development)
  static const bool useRealApi = true;
  
  // Debug logging
  static const bool enableDebugLogs = true;
  
  static void log(String message) {
    if (enableDebugLogs) {
     debugPrint('🔧 [StockAPI] $message');
    }
  }
}