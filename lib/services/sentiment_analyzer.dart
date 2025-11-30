// lib/services/sentiment_analyzer.dart

class SentimentAnalyzer {
  // Strong positive indicators (weight: 3)
  static const Map<String, int> _strongPositive = {
    'surge': 3,
    'soar': 3,
    'skyrocket': 3,
    'breakthrough': 3,
    'outperform': 3,
    'stellar': 3,
    'record': 3,
    'boom': 3,
  };

  // Moderate positive indicators (weight: 2)
  static const Map<String, int> _moderatePositive = {
    'gain': 2,
    'profit': 2,
    'growth': 2,
    'success': 2,
    'rise': 2,
    'up': 2,
    'positive': 2,
    'strong': 2,
    'beat': 2,
    'upgrade': 2,
    'bullish': 2,
    'rally': 2,
    'jump': 2,
    'expand': 2,
    'boost': 2,
    'improve': 2,
    'optimistic': 2,
  };

  // Weak positive indicators (weight: 1)
  static const Map<String, int> _weakPositive = {
    'stable': 1,
    'steady': 1,
    'maintain': 1,
    'hold': 1,
    'continue': 1,
  };

  // Strong negative indicators (weight: -3)
  static const Map<String, int> _strongNegative = {
    'crash': -3,
    'plunge': -3,
    'collapse': -3,
    'disaster': -3,
    'crisis': -3,
    'bankrupt': -3,
    'catastrophe': -3,
  };

  // Moderate negative indicators (weight: -2)
  static const Map<String, int> _moderateNegative = {
    'fall': -2,
    'loss': -2,
    'decline': -2,
    'drop': -2,
    'weak': -2,
    'down': -2,
    'negative': -2,
    'concern': -2,
    'miss': -2,
    'underperform': -2,
    'downgrade': -2,
    'bearish': -2,
    'sink': -2,
    'cut': -2,
    'reduce': -2,
    'warning': -2,
    'struggle': -2,
  };

  // Weak negative indicators (weight: -1)
  static const Map<String, int> _weakNegative = {
    'risk': -1,
    'uncertain': -1,
    'caution': -1,
    'challenge': -1,
    'pressure': -1,
  };

  /// Analyzes sentiment with weighted scoring
  static Map<String, dynamic> analyze(String text) {
    final lowerText = text.toLowerCase();
    int totalScore = 0;
    int wordCount = 0;

    // Check all word categories
    final allWords = {
      ..._strongPositive,
      ..._moderatePositive,
      ..._weakPositive,
      ..._strongNegative,
      ..._moderateNegative,
      ..._weakNegative,
    };

    for (var entry in allWords.entries) {
      if (lowerText.contains(entry.key)) {
        totalScore += entry.value;
        wordCount++;
      }
    }

    // Calculate normalized score (0.0 to 1.0)
    double normalizedScore;
    String label;
    String confidence;

    if (wordCount == 0) {
      // Neutral - no sentiment words found
      normalizedScore = 0.5;
      label = 'Neutral';
      confidence = 'Low';
    } else {
      // Map score range to 0.0 - 1.0
      // Assuming max possible score is ±9 (3 strong words)
      const maxScore = 9.0;
      normalizedScore = ((totalScore / maxScore) + 1.0) / 2.0;
      normalizedScore = normalizedScore.clamp(0.0, 1.0);

      // Determine label
      if (normalizedScore >= 0.7) {
        label = 'Positive';
        confidence = normalizedScore >= 0.85 ? 'High' : 'Medium';
      } else if (normalizedScore <= 0.3) {
        label = 'Negative';
        confidence = normalizedScore <= 0.15 ? 'High' : 'Medium';
      } else {
        label = 'Neutral';
        confidence = 'Medium';
      }
    }

    return {
      'score': normalizedScore,
      'label': label,
      'confidence': confidence,
      'wordCount': wordCount,
      'rawScore': totalScore,
    };
  }

  /// Analyzes multiple headlines and returns aggregate sentiment
  static Map<String, dynamic> analyzeMultiple(List<String> headlines) {
    if (headlines.isEmpty) {
      return {
        'score': 0.5,
        'label': 'Neutral',
        'confidence': 'Low',
      };
    }

    double totalScore = 0;
    int totalWordCount = 0;
    // ignore: prefer_collection_literals
    final sentiments = <Map<String, dynamic>>[];

    for (var headline in headlines) {
      final sentiment = analyze(headline);
      sentiments.add(sentiment);
      totalScore += sentiment['score'] as double;
      totalWordCount += sentiment['wordCount'] as int;
    }

    final avgScore = totalScore / headlines.length;
    final avgWordCount = totalWordCount / headlines.length;

    String label;
    String confidence;

    if (avgScore >= 0.7) {
      label = 'Positive';
    } else if (avgScore <= 0.3) {
      label = 'Negative';
    } else {
      label = 'Neutral';
    }

    // Confidence based on number of sentiment words found
    if (avgWordCount >= 2) {
      confidence = 'High';
    } else if (avgWordCount >= 1) {
      confidence = 'Medium';
    } else {
      confidence = 'Low';
    }

    return {
      'score': avgScore,
      'label': label,
      'confidence': confidence,
      'headlinesAnalyzed': headlines.length,
      'avgWordCount': avgWordCount,
    };
  }
}