// lib/models/stock_prediction_data.dart

class StockPredictionData {
  final String ticker;
  final double currentPrice;
  final double predictedPrice; // The Fusion output
  final double sentimentScore; // Value from 0.0 to 1.0, derived from FinBERT
  final String riskIndication; // e.g., 'BULLISH', 'BEARISH'
  final List<Map<String, String>> newsFeed; // Must contain keys: 'headline', 'sentiment' ('Positive', 'Negative', 'Neutral')
  final List<double> historicalChartData; // Input for LineChartPainter

  const StockPredictionData({
    required this.ticker,
    required this.currentPrice,
    required this.predictedPrice,
    required this.sentimentScore,
    required this.riskIndication,
    required this.newsFeed,
    required this.historicalChartData,
  });

  factory StockPredictionData.fromMap(Map<String, dynamic> map) {
    return StockPredictionData(
      ticker: map['ticker'] ?? '',
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      predictedPrice: (map['predictedPrice'] ?? 0.0).toDouble(),
      sentimentScore: (map['sentimentScore'] ?? 0.5).toDouble(),
      riskIndication: map['riskIndication'] ?? 'NEUTRAL',
      newsFeed: List<Map<String, String>>.from(
        (map['newsFeed'] ?? []).map((item) => Map<String, String>.from(item)),
      ),
      historicalChartData: List<double>.from(
        (map['historicalChartData'] ?? []).map((v) => (v as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticker': ticker,
      'currentPrice': currentPrice,
      'predictedPrice': predictedPrice,
      'sentimentScore': sentimentScore,
      'riskIndication': riskIndication,
      'newsFeed': newsFeed,
      'historicalChartData': historicalChartData,
    };
  }
}
