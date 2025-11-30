// lib/models/prediction_model.dart

class PredictionHistory {
  final String id;
  final String userId;
  final String ticker;
  final double currentPrice;
  final double predictedPrice;
  final double sentimentScore;
  final String riskIndication;
  final DateTime timestamp;
  final bool isRealData;

  const PredictionHistory({
    required this.id,
    required this.userId,
    required this.ticker,
    required this.currentPrice,
    required this.predictedPrice,
    required this.sentimentScore,
    required this.riskIndication,
    required this.timestamp,
    required this.isRealData,
  });

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ticker': ticker,
      'currentPrice': currentPrice,
      'predictedPrice': predictedPrice,
      'sentimentScore': sentimentScore,
      'riskIndication': riskIndication,
      'timestamp': timestamp.toIso8601String(),
      'isRealData': isRealData,
    };
  }

  // Create from Firestore data
  factory PredictionHistory.fromMap(Map<String, dynamic> map) {
    return PredictionHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      ticker: map['ticker'] ?? '',
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      predictedPrice: (map['predictedPrice'] ?? 0.0).toDouble(),
      sentimentScore: (map['sentimentScore'] ?? 0.5).toDouble(),
      riskIndication: map['riskIndication'] ?? 'NEUTRAL',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRealData: map['isRealData'] ?? false,
    );
  }

  // Calculate prediction accuracy (call this after time has passed)
  double calculateAccuracy(double actualPrice) {
    final predicted = predictedPrice;
    final error = (predicted - actualPrice).abs();
    final percentError = (error / actualPrice) * 100;
    return (100 - percentError).clamp(0, 100);
  }
}