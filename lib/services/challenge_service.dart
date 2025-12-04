// lib/services/challenge_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Complete list of 15+ challenges
  static const List<Map<String, dynamic>> _allChallenges = [
    // Saving Challenges (Easy - 10 points)
    {
      'id': 'save_500',
      'title': 'Skip Restaurant Week',
      'description': 'Save ₹500 this week by skipping one restaurant meal',
      'category': 'Saving',
      'points': 10,
      'difficulty': 'easy',
      'icon': '🍽️',
    },
    {
      'id': 'no_coffee',
      'title': 'No Coffee Shop Challenge',
      'description': 'Make your own coffee for 3 days instead of buying',
      'category': 'Saving',
      'points': 10,
      'difficulty': 'easy',
      'icon': '☕',
    },
    {
      'id': 'save_10_percent',
      'title': 'Save 10% This Week',
      'description': 'Put aside 10% of your weekly income into savings',
      'category': 'Saving',
      'points': 15,
      'difficulty': 'medium',
      'icon': '💰',
    },
    {
      'id': 'cash_only',
      'title': 'Cash-Only Days',
      'description': 'Use only cash for 2 days to become aware of spending',
      'category': 'Saving',
      'points': 10,
      'difficulty': 'easy',
      'icon': '💵',
    },
    {
      'id': 'no_shopping',
      'title': 'No Shopping Week',
      'description': 'Avoid all non-essential purchases for 7 days',
      'category': 'Saving',
      'points': 25,
      'difficulty': 'hard',
      'icon': '🛍️',
    },

    // Investment Challenges (Medium - 25 points)
    {
      'id': 'research_stocks',
      'title': 'Research 3 New Stocks',
      'description': 'Add 3 new stocks to your watchlist after research',
      'category': 'Investment',
      'points': 25,
      'difficulty': 'medium',
      'icon': '📈',
    },
    {
      'id': 'read_news',
      'title': 'Market News Reader',
      'description': 'Read 5 stock market news articles this week',
      'category': 'Investment',
      'points': 15,
      'difficulty': 'easy',
      'icon': '📰',
    },
    {
      'id': 'sentiment_decision',
      'title': 'Data-Driven Investment',
      'description': 'Make one investment decision based on sentiment analysis',
      'category': 'Investment',
      'points': 25,
      'difficulty': 'medium',
      'icon': '🎯',
    },
    {
      'id': 'track_predictions',
      'title': 'Prediction Accuracy Tracker',
      'description': 'Track your prediction accuracy for 3 consecutive days',
      'category': 'Investment',
      'points': 20,
      'difficulty': 'medium',
      'icon': '🔍',
    },

    // Expense Tracking (Medium - 15 points)
    {
      'id': 'log_7_days',
      'title': 'Perfect Week Logger',
      'description': 'Log every single transaction for 7 days straight',
      'category': 'Tracking',
      'points': 25,
      'difficulty': 'medium',
      'icon': '✅',
    },
    {
      'id': 'reduce_food',
      'title': 'Food Budget Cut',
      'description': 'Reduce food expenses by 15% this week',
      'category': 'Tracking',
      'points': 20,
      'difficulty': 'medium',
      'icon': '🍔',
    },
    {
      'id': 'grocery_budget',
      'title': 'Grocery Budget Master',
      'description': 'Complete grocery shopping within ₹2000 budget',
      'category': 'Tracking',
      'points': 15,
      'difficulty': 'easy',
      'icon': '🛒',
    },
    {
      'id': 'no_spend_days',
      'title': 'Zero Spend Challenge',
      'description': 'Have 3 no-spend days this week',
      'category': 'Tracking',
      'points': 25,
      'difficulty': 'hard',
      'icon': '🚫',
    },

    // Financial Literacy (Hard - 50 points)
    {
      'id': 'learn_strategy',
      'title': 'Investment Strategy Scholar',
      'description': 'Learn about one new investment strategy in detail',
      'category': 'Learning',
      'points': 30,
      'difficulty': 'medium',
      'icon': '📚',
    },
    {
      'id': 'savings_rate',
      'title': 'Calculate Savings Rate',
      'description': 'Calculate your monthly savings rate accurately',
      'category': 'Learning',
      'points': 20,
      'difficulty': 'easy',
      'icon': '🧮',
    },
    {
      'id': 'review_expenses',
      'title': 'Monthly Expense Audit',
      'description': 'Review and categorize all expenses from last month',
      'category': 'Learning',
      'points': 30,
      'difficulty': 'medium',
      'icon': '📊',
    },
  ];

  /// Get daily challenges for a user (3-4 challenges per day)
  Future<List<Challenge>> getDailyChallenges(String userId) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';

      // Check if challenges already exist for today
      final existingChallenges = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .where('dateKey', isEqualTo: dateKey)
          .get();

      if (existingChallenges.docs.isNotEmpty) {
        // Return existing challenges
        return existingChallenges.docs
            .map((doc) => Challenge.fromMap(doc.data()..['id'] = doc.id))
            .toList();
      }

      // Generate new challenges for today
      final newChallenges = _generateDailyChallenges(dateKey);

      // Save to Firestore
      for (var challenge in newChallenges) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('daily_challenges')
            .add(challenge.toMap());
      }

      // Fetch the newly created challenges to get their IDs
      final refreshedChallenges = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .where('dateKey', isEqualTo: dateKey)
          .get();

      return refreshedChallenges.docs
          .map((doc) => Challenge.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting daily challenges: $e');
      // Return default challenges if Firestore fails
      return _generateDailyChallenges(DateTime.now().toString());
    }
  }

  /// Generate 4 random challenges for the day
  List<Challenge> _generateDailyChallenges(String dateKey) {
    final random = Random(DateTime.now().day); // Seed with day for consistency
    final shuffled = List<Map<String, dynamic>>.from(_allChallenges)..shuffle(random);
    final selected = shuffled.take(4).toList();

    return selected.map((data) {
      return Challenge(
        id: '${data['id']}_$dateKey',
        title: data['title'],
        description: data['description'],
        category: data['category'],
        points: data['points'],
        isCompleted: false,
        dateKey: dateKey,
        icon: data['icon'],
        difficulty: data['difficulty'],
      );
    }).toList();
  }

  /// Accept a challenge
  Future<void> acceptChallenge(String userId, String challengeId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .doc(challengeId);

      // Check if document exists
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        debugPrint('Challenge document does not exist. Creating it first.');
        // If document doesn't exist, we can't update it
        throw Exception('Challenge not found');
      }

      // Document exists, update it
      await docRef.update({
        'isAccepted': true,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Challenge accepted successfully');
    } catch (e) {
      debugPrint('Error accepting challenge: $e');
      rethrow;
    }
  }

  /// Complete a challenge and award points
  Future<void> completeChallenge(String userId, String challengeId, int points) async {
    try {
      // Update challenge status
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .doc(challengeId)
          .update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Award brownie points
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'browniePoints': FieldValue.increment(points),
        'totalChallengesCompleted': FieldValue.increment(1),
      }, SetOptions(merge: true));

      debugPrint('✅ Challenge completed! Awarded $points points');
    } catch (e) {
      debugPrint('Error completing challenge: $e');
      rethrow;
    }
  }

  /// Get user's brownie points and rank
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      final data = doc.data() ?? {};
      final points = data['browniePoints'] ?? 0;
      final completed = data['totalChallengesCompleted'] ?? 0;

      return {
        'browniePoints': points,
        'totalChallengesCompleted': completed,
        'rank': _calculateRank(points),
        'nextRank': _getNextRank(points),
        'pointsToNextRank': _getPointsToNextRank(points),
      };
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return {
        'browniePoints': 0,
        'totalChallengesCompleted': 0,
        'rank': 'Beginner',
        'nextRank': 'Novice',
        'pointsToNextRank': 50,
      };
    }
  }

  /// Calculate rank based on points
  String _calculateRank(int points) {
    if (points >= 800) return 'Financial Guru 🌟';
    if (points >= 500) return 'Ultra Legend 🔥';
    if (points >= 400) return 'Legend 👑';
    if (points >= 300) return 'Master 💎';
    if (points >= 200) return 'Expert 🎯';
    if (points >= 100) return 'Apprentice ⚡';
    if (points >= 50) return 'Novice 🔰';
    return 'Beginner 🌱';
  }

  String _getNextRank(int points) {
    if (points >= 800) return 'Max Rank!';
    if (points >= 500) return 'Financial Guru 🌟';
    if (points >= 400) return 'Ultra Legend 🔥';
    if (points >= 300) return 'Legend 👑';
    if (points >= 200) return 'Master 💎';
    if (points >= 100) return 'Expert 🎯';
    if (points >= 50) return 'Apprentice ⚡';
    return 'Novice 🔰';
  }

  int _getPointsToNextRank(int points) {
    if (points >= 800) return 0;
    if (points >= 500) return 800 - points;
    if (points >= 400) return 500 - points;
    if (points >= 300) return 400 - points;
    if (points >= 200) return 300 - points;
    if (points >= 100) return 200 - points;
    if (points >= 50) return 100 - points;
    return 50 - points;
  }

  /// Get challenge history
  Stream<List<Challenge>> getChallengeHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_challenges')
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }
}