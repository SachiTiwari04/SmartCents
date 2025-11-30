// lib/services/stock_api_service.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_prediction_data.dart';
import '../models/prediction_model.dart';
import '../config/env.dart';
import 'cache_service.dart';
import 'sentiment_analyzer.dart';
import 'firestore_service.dart';

class StockApiService {
  /// Fetches hybrid stock prediction combining real API data and sentiment analysis
  /// 
  /// The hybrid approach:
  /// - Fetches REAL stock price from Alpha Vantage
  /// - Fetches REAL news from NewsAPI
  /// - Calculates sentiment from news headlines using sophisticated analyzer
  /// - Fetches REAL historical data
  /// - Saves predictions to Firebase
  /// - Falls back to mock data if API fails
  Future<StockPredictionData> fetchHybridPrediction(
    String ticker, {
    String? userId,
    FirestoreService? firestoreService,
  }) async {
    Env.log('Fetching prediction for $ticker');
    
    try {
      // Check cache first to avoid API rate limits
      final cached = await CacheService.get(ticker);
      if (cached != null) {
        Env.log('Using cached data for $ticker');
        return StockPredictionData.fromMap(cached);
      }

      // Decide whether to use real API or mock data
      if (!Env.useRealApi) {
        Env.log('Real API disabled, using mock data');
        return await _generateMockPrediction(ticker);
      }

      Env.log('Fetching REAL data from APIs...');
      
      // Fetch real stock price
      final currentPrice = await _fetchRealStockPrice(ticker);
      
      // Fetch real news and calculate sentiment
      final newsData = await _fetchNewsAndSentiment(ticker);
      
      // Calculate prediction based on real sentiment
      final predictedPrice = _calculatePrediction(
        currentPrice, 
        newsData['sentimentScore'],
      );
      
      // Determine risk indication
      final riskIndication = _getRiskIndication(newsData['sentimentScore']);
      
      // Try to fetch real historical data, fall back to mock if it fails
      List<double> historicalChartData;
      try {
        historicalChartData = await _fetchRealHistoricalData(ticker);
      } catch (e) {
        Env.log('Using mock historical data: $e');
        historicalChartData = _generateHistoricalData(currentPrice, 30);
      }
      
      final prediction = StockPredictionData(
        ticker: ticker,
        currentPrice: currentPrice,
        predictedPrice: predictedPrice,
        sentimentScore: newsData['sentimentScore'],
        riskIndication: riskIndication,
        newsFeed: newsData['newsFeed'],
        historicalChartData: historicalChartData,
      );

      // Cache the result
      await CacheService.save(ticker, prediction.toMap());
      
      // Save to Firebase if user is logged in
      if (userId != null && firestoreService != null) {
        await savePredictionToFirestore(prediction, userId, firestoreService);
      }
      
      Env.log('✅ Real data fetched and cached for $ticker');
      return prediction;
      
    } catch (e) {
      Env.log('⚠️ Error fetching real data: $e');
      Env.log('Falling back to mock data');
      return await _generateMockPrediction(ticker);
    }
  }

  /// Fetches real stock price from Alpha Vantage API
  Future<double> _fetchRealStockPrice(String ticker) async {
    try {
      final url = Uri.parse(
        '${Env.alphaVantageBase}?function=GLOBAL_QUOTE&symbol=$ticker&apikey=${Env.alphaVantageKey}'
      );
      
      Env.log('Fetching price from Alpha Vantage...');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      
      // Check for API errors
      if (data.containsKey('Error Message')) {
        throw Exception(data['Error Message']);
      }
      
      if (data.containsKey('Note')) {
        throw Exception('API rate limit reached');
      }
      
      // Extract price from response
      final quote = data['Global Quote'];
      if (quote == null || quote.isEmpty) {
        throw Exception('No quote data available for $ticker');
      }
      
      final priceStr = quote['05. price'];
      if (priceStr == null) {
        throw Exception('Price not found in response');
      }
      
      final price = double.parse(priceStr);
      Env.log('Real price for $ticker: \$$price');
      return price;
      
    } catch (e) {
      Env.log('Stock price fetch error: $e');
      rethrow;
    }
  }

  /// Fetches real historical data from Alpha Vantage (30 days)
  Future<List<double>> _fetchRealHistoricalData(String ticker) async {
    try {
      final url = Uri.parse(
        '${Env.alphaVantageBase}?function=TIME_SERIES_DAILY&symbol=$ticker&apikey=${Env.alphaVantageKey}'
      );
      
      Env.log('Fetching historical data from Alpha Vantage...');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      
      // Check for API errors
      if (data.containsKey('Error Message')) {
        throw Exception(data['Error Message']);
      }
      
      if (data.containsKey('Note')) {
        throw Exception('API rate limit reached');
      }
      
      // Extract time series data
      final timeSeries = data['Time Series (Daily)'];
      if (timeSeries == null) {
        throw Exception('No historical data available');
      }
      
      // Get last 30 days of closing prices
      final prices = <double>[];
      final sortedDates = (timeSeries.keys.toList()..sort()).reversed.take(30);
      
      for (var date in sortedDates) {
        final closePrice = timeSeries[date]['4. close'];
        if (closePrice != null) {
          prices.add(double.parse(closePrice));
        }
      }
      
      // Reverse to show oldest to newest
      final reversedPrices = prices.reversed.toList();
      
      Env.log('Fetched ${reversedPrices.length} historical data points');
      return reversedPrices;
      
    } catch (e) {
      Env.log('Historical data fetch error: $e');
      rethrow;
    }
  }

  /// Fetches real news and calculates sentiment using sophisticated analyzer
  Future<Map<String, dynamic>> _fetchNewsAndSentiment(String ticker) async {
    try {
      // Calculate date range (last 7 days)
      final toDate = DateTime.now();
      final fromDate = toDate.subtract(const Duration(days: 7));
      final fromStr = fromDate.toIso8601String().split('T')[0];
      final toStr = toDate.toIso8601String().split('T')[0];
      
      final url = Uri.parse(
        '${Env.newsApiBase}?q=$ticker&from=$fromStr&to=$toStr&sortBy=publishedAt&language=en&apiKey=${Env.newsApiKey}'
      );
      
      Env.log('Fetching news from NewsAPI...');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('News API returned status ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      
      if (data['status'] != 'ok') {
        throw Exception(data['message'] ?? 'News API error');
      }
      
      final articles = data['articles'] as List? ?? [];
      
      if (articles.isEmpty) {
        Env.log('No news found, using neutral sentiment');
        return {
          'sentimentScore': 0.5,
          'newsFeed': _generateNeutralNewsFeed(ticker),
        };
      }
      
      // Analyze sentiment from headlines using sophisticated analyzer
      final headlines = <String>[];
      final newsFeed = <Map<String, String>>[];

      for (var article in articles.take(10)) {
        final headline = article['title'] ?? '';
        if (headline.isNotEmpty) {
          headlines.add(headline);
        }
      }

      // Use aggregate sentiment analysis
      final aggregateSentiment = SentimentAnalyzer.analyzeMultiple(headlines);
      final avgSentiment = aggregateSentiment['score'];

      // Build news feed with individual sentiments
      for (var headline in headlines) {
        final sentiment = SentimentAnalyzer.analyze(headline);
        newsFeed.add({
          'headline': headline,
          'sentiment': sentiment['label'],
        });
      }
      
      Env.log('Analyzed ${headlines.length} headlines, avg sentiment: ${(avgSentiment * 100).toStringAsFixed(0)}% (${aggregateSentiment['confidence']} confidence)');
      
      return {
        'sentimentScore': avgSentiment,
        'newsFeed': newsFeed.isEmpty ? _generateNeutralNewsFeed(ticker) : newsFeed,
      };
      
    } catch (e) {
      Env.log('News fetch error: $e');
      rethrow;
    }
  }

  /// Calculate predicted price based on current price and sentiment
  double _calculatePrediction(double currentPrice, double sentimentScore) {
    if (sentimentScore > 0.7) {
      // BULLISH: increase by 2-8%
      return currentPrice * (1.02 + (sentimentScore - 0.7) * 0.2);
    } else if (sentimentScore < 0.3) {
      // BEARISH: decrease by 2-8%
      return currentPrice * (0.98 - (0.3 - sentimentScore) * 0.2);
    } else {
      // NEUTRAL: slight fluctuation ±2%
      return currentPrice * (0.98 + (sentimentScore - 0.3) * 0.1);
    }
  }

  /// Get risk indication from sentiment score
  String _getRiskIndication(double sentimentScore) {
    if (sentimentScore > 0.7) return 'BULLISH';
    if (sentimentScore < 0.3) return 'BEARISH';
    return 'NEUTRAL';
  }

  /// Save prediction to Firebase for tracking
  Future<void> savePredictionToFirestore(
    StockPredictionData prediction,
    String userId,
    FirestoreService firestoreService,
  ) async {
    try {
      final predictionHistory = PredictionHistory(
        id: '', // Firestore will generate this
        userId: userId,
        ticker: prediction.ticker,
        currentPrice: prediction.currentPrice,
        predictedPrice: prediction.predictedPrice,
        sentimentScore: prediction.sentimentScore,
        riskIndication: prediction.riskIndication,
        timestamp: DateTime.now(),
        isRealData: Env.useRealApi,
      );
      
      await firestoreService.savePrediction(userId, predictionHistory);
      Env.log('Prediction saved to Firebase');
    } catch (e) {
      Env.log('Error saving prediction: $e');
      // Don't throw - we don't want to break the app if saving fails
    }
  }

  // ========== MOCK DATA FALLBACK ==========

  /// Generates mock prediction (fallback when API fails)
  Future<StockPredictionData> _generateMockPrediction(String ticker) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    final currentPrice = 100.0 + random.nextDouble() * 100;
    final sentimentScore = random.nextDouble();
    
    late double predictedPrice;
    late String riskIndication;
    late List<Map<String, String>> newsFeed;
    
    if (sentimentScore > 0.7) {
      predictedPrice = currentPrice * (1.0 + (sentimentScore - 0.7) * 0.3);
      riskIndication = 'BULLISH';
      newsFeed = _generateBullishNewsFeed(ticker);
    } else if (sentimentScore < 0.3) {
      predictedPrice = currentPrice * (1.0 - (0.3 - sentimentScore) * 0.3);
      riskIndication = 'BEARISH';
      newsFeed = _generateBearishNewsFeed(ticker);
    } else {
      predictedPrice = currentPrice * (0.98 + random.nextDouble() * 0.04);
      riskIndication = 'NEUTRAL';
      newsFeed = _generateNeutralNewsFeed(ticker);
    }
    
    final historicalChartData = _generateHistoricalData(currentPrice, 30);
    
    return StockPredictionData(
      ticker: ticker,
      currentPrice: currentPrice,
      predictedPrice: predictedPrice,
      sentimentScore: sentimentScore,
      riskIndication: riskIndication,
      newsFeed: newsFeed,
      historicalChartData: historicalChartData,
    );
  }

  List<Map<String, String>> _generateBullishNewsFeed(String ticker) {
    return [
      {'headline': '$ticker Reports Strong Q4 Earnings Beat', 'sentiment': 'Positive'},
      {'headline': 'Analyst Upgrades $ticker to Buy Rating', 'sentiment': 'Positive'},
      {'headline': '$ticker Secures Major Partnership Deal', 'sentiment': 'Positive'},
      {'headline': 'Market Sentiment Turns Positive on $ticker', 'sentiment': 'Positive'},
      {'headline': 'Institutional Investors Increase $ticker Holdings', 'sentiment': 'Positive'},
    ];
  }

  List<Map<String, String>> _generateBearishNewsFeed(String ticker) {
    return [
      {'headline': '$ticker Faces Regulatory Headwinds', 'sentiment': 'Negative'},
      {'headline': 'Analyst Downgrades $ticker on Weak Guidance', 'sentiment': 'Negative'},
      {'headline': '$ticker Supply Chain Disruptions Continue', 'sentiment': 'Negative'},
      {'headline': 'Market Sentiment Turns Negative on $ticker', 'sentiment': 'Negative'},
      {'headline': 'Institutional Investors Exit $ticker Positions', 'sentiment': 'Negative'},
    ];
  }

  List<Map<String, String>> _generateNeutralNewsFeed(String ticker) {
    return [
      {'headline': '$ticker Maintains Steady Market Position', 'sentiment': 'Neutral'},
      {'headline': 'Analyst Maintains Hold Rating on $ticker', 'sentiment': 'Neutral'},
      {'headline': '$ticker Announces Quarterly Results', 'sentiment': 'Neutral'},
      {'headline': 'Market Consolidation Observed in $ticker', 'sentiment': 'Neutral'},
      {'headline': 'Trading Volume Remains Stable for $ticker', 'sentiment': 'Neutral'},
    ];
  }

  List<double> _generateHistoricalData(double basePrice, int days) {
    final random = Random();
    final data = <double>[];
    double price = basePrice * 0.95;
    
    for (int i = 0; i < days; i++) {
      price = price * (0.99 + random.nextDouble() * 0.02);
      data.add(price);
    }
    
    return data;
  }
}