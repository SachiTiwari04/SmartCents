// lib/providers/prediction_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_prediction_data.dart';
import '../services/stock_api_service.dart';
import '../providers/firestore_provider.dart';
import '../providers/auth_provider.dart';

/// Provides the StockApiService instance
final stockApiServiceProvider = Provider<StockApiService>((ref) {
  return StockApiService();
});

/// Holds the current ticker being searched/analyzed
final currentTickerProvider = StateProvider<String>((ref) {
  return 'GOOG';
});

/// Fetches hybrid prediction data for the current ticker
/// Now includes Firebase persistence
final hybridPredictionProvider = FutureProvider<StockPredictionData>((ref) async {
  final service = ref.watch(stockApiServiceProvider);
  final ticker = ref.watch(currentTickerProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  // Get current user ID (may be null if not logged in)
  final userId = authState.asData?.value?.id;
  
  return service.fetchHybridPrediction(
    ticker,
    userId: userId,
    firestoreService: firestoreService,
  );
});

/// Provides a family-based prediction fetcher for any ticker
/// Now includes Firebase persistence
final hybridPredictionFamilyProvider = FutureProvider.family<StockPredictionData, String>((ref, ticker) async {
  final service = ref.watch(stockApiServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  // Get current user ID (may be null if not logged in)
  final userId = authState.asData?.value?.id;
  
  return service.fetchHybridPrediction(
    ticker,
    userId: userId,
    firestoreService: firestoreService,
  );
});