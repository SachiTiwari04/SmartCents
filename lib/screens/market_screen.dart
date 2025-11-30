// lib/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/stock_prediction_data.dart';
import '../providers/prediction_provider.dart';
import 'package:smartcents/screens/profile_screen.dart';

const Color neonCyan = Color(0xFF18FFFF);
const Color neonPink = Color(0xFFFF4081);
const Color primaryBackground = Color(0xFF0D0D0D);
const Color surfaceColor = Color(0xFF1A1A1A);

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  late TextEditingController _tickerController;

  @override
  void initState() {
    super.initState();
    _tickerController = TextEditingController(text: 'GOOG');
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predictionAsync = ref.watch(hybridPredictionProvider);

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        title: const Text('Market', style: TextStyle(color: neonCyan)),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: neonCyan),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Prediction Data Display
            predictionAsync.when(
              data: (prediction) => _buildPredictionUI(prediction),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: neonCyan),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: neonPink),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _tickerController,
            onChanged: (value) {
              ref.read(currentTickerProvider.notifier).state = value.toUpperCase();
            },
            decoration: const InputDecoration(
              labelText: '// SEARCH TICKER',
              hintText: 'e.g., AAPL',
              prefixIcon: Icon(Icons.search, color: neonCyan),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: neonCyan, fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            ref.read(currentTickerProvider.notifier).state = _tickerController.text.toUpperCase();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: neonCyan,
            foregroundColor: primaryBackground,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          child: const Text('QUERY', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPredictionUI(StockPredictionData prediction) {
    final isPositive = prediction.predictedPrice > prediction.currentPrice;
    final priceChange = prediction.predictedPrice - prediction.currentPrice;
    final priceChangePercent = (priceChange / prediction.currentPrice) * 100;
    final primaryColor = isPositive ? neonCyan : neonPink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Panel
        _buildPricePanel(prediction, primaryColor, isPositive, priceChangePercent),
        const SizedBox(height: 20),

        // Sentiment Gauge
        _buildSentimentGauge(prediction),
        const SizedBox(height: 20),

        // News Feed Panel
        _buildNewsFeedPanel(prediction),
        const SizedBox(height: 20),

        // Historical Chart
        _buildHistoricalChart(prediction, primaryColor),
      ],
    );
  }

  Widget _buildPricePanel(StockPredictionData prediction, Color primaryColor, bool isPositive, double priceChangePercent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prediction.ticker,
                style: const TextStyle(
                  color: neonCyan,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: Text(
                  prediction.riskIndication,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPricePill('CURRENT', prediction.currentPrice, Colors.white70),
              _buildPricePill('PREDICTED (AI)', prediction.predictedPrice, primaryColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${isPositive ? '+' : ''}${(prediction.predictedPrice - prediction.currentPrice).toStringAsFixed(2)})',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricePill(String label, double price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: r'$').format(price),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentGauge(StockPredictionData prediction) {
    final sentimentPercent = prediction.sentimentScore * 100;
    final sentimentLabel = prediction.sentimentScore > 0.7
        ? 'HIGHLY BULLISH'
        : prediction.sentimentScore > 0.5
            ? 'BULLISH'
            : prediction.sentimentScore > 0.3
                ? 'NEUTRAL'
                : 'BEARISH';
    final sentimentColor = prediction.sentimentScore > 0.7
        ? neonCyan
        : prediction.sentimentScore > 0.3
            ? Colors.white54
            : neonPink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sentimentColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// SENTIMENT ANALYSIS (FinBERT)',
            style: TextStyle(color: neonCyan, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sentimentLabel,
                style: TextStyle(
                  color: sentimentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${sentimentPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: sentimentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: prediction.sentimentScore,
              minHeight: 12,
              backgroundColor: neonPink.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(sentimentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsFeedPanel(StockPredictionData prediction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neonCyan.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// NEWS FEED',
            style: TextStyle(color: neonCyan, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...prediction.newsFeed.map((news) => _buildNewsItem(news)),
        ],
      ),
    );
  }

  Widget _buildNewsItem(Map<String, String> news) {
    final sentiment = news['sentiment'] ?? 'Neutral';
    final sentimentColor = sentiment == 'Positive'
        ? neonCyan
        : sentiment == 'Negative'
            ? neonPink
            : Colors.white54;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              news['headline'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sentimentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sentimentColor, width: 0.5),
            ),
            child: Text(
              sentiment,
              style: TextStyle(
                color: sentimentColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalChart(StockPredictionData prediction, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// 30-DAY HISTORICAL TREND',
            style: TextStyle(color: neonCyan, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: LineChartPainter(prediction.historicalChartData, primaryColor),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for Line Chart
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal;
    if (range == 0) return;

    final double stepX = size.width / (data.length - 1);

    // Path setup
    final path = Path();
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Fill area setup
    final fillPath = Path();
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Start point
    double y = size.height - ((data[0] - minVal) / range * size.height).clamp(0, size.height);
    path.moveTo(0, y);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, y);

    // Draw line segments
    for (int i = 1; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - ((data[i] - minVal) / range * size.height).clamp(0, size.height);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}