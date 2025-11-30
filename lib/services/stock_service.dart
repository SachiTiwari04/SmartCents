// lib/services/stock_service.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/stock_model.dart';

class StockService {
  final Map<String, Stock> _stocks = {};

  // In a real app, this would fetch from an actual API
  Future<List<Stock>> getWatchlistStocks(List<String> symbols) async {
    if (_stocks.isEmpty) {
      // Initialize with some mock data
      _stocks['AAPL'] = Stock(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 150.0 + Random().nextDouble() * 10,
        changePercent: -0.5 + Random().nextDouble() * 3,
      );
      _stocks['GOOGL'] = Stock(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        price: 2500.0 + Random().nextDouble() * 100,
        changePercent: -0.5 + Random().nextDouble() * 3,
      );
      _stocks['MSFT'] = Stock(
        symbol: 'MSFT',
        name: 'Microsoft Corporation',
        price: 300.0 + Random().nextDouble() * 20,
        changePercent: -0.5 + Random().nextDouble() * 3,
      );
      _stocks['AMZN'] = Stock(
        symbol: 'AMZN',
        name: 'Amazon.com, Inc.',
        price: 3200.0 + Random().nextDouble() * 150,
        changePercent: -0.5 + Random().nextDouble() * 3,
      );
    } else {
      // Update prices with random changes
      for (var stock in _stocks.values) {
        final change = -0.5 + Random().nextDouble() * 3;
        final newPrice = stock.price * (1 + change / 100);
        _stocks[stock.symbol] = Stock(
          symbol: stock.symbol,
          name: stock.name,
          price: newPrice,
          changePercent: change,
        );
      }
    }

    // Return stocks in the order of the requested symbols
    return symbols
        .where((symbol) => _stocks.containsKey(symbol))
        .map((symbol) => _stocks[symbol]!)
        .toList();
  }

  // Simulate real-time updates
  Stream<List<Stock>> watchStocks(List<String> symbols) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield await getWatchlistStocks(symbols);
    }
  }

  // In a real app, this would fetch historical data from an API
  Future<List<Map<String, dynamic>>> getHistoricalData(
      String symbol, String interval) async {
    debugPrint('Fetching historical data for $symbol ($interval)');
    // Return mock data
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];
    double price = 100.0;

    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      price = price * (0.99 + Random().nextDouble() * 0.02); // Random walk
      data.add({
        'date': date,
        'price': price,
      });
    }

    return data;
  }
}