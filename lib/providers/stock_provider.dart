// lib/providers/stock_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/models/stock_model.dart';
import 'package:smartcents/services/stock_service.dart';

final stockServiceProvider = Provider<StockService>((ref) {
  return StockService();
});

final watchlistSymbolsProvider = StateProvider<List<String>>((ref) {
  return ['AAPL', 'GOOGL', 'MSFT', 'AMZN'];
});

final watchlistStocksProvider = StreamProvider<List<Stock>>((ref) {
  final stockService = ref.watch(stockServiceProvider);
  final symbols = ref.watch(watchlistSymbolsProvider);
  return stockService.watchStocks(symbols);
});