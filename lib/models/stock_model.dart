// lib/models/stock_model.dart
class Stock {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      changePercent: (map['changePercent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'changePercent': changePercent,
    };
  }
}