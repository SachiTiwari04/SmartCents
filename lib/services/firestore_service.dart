import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';

import '../models/challenge_model.dart' as models;
import '../models/transaction_model.dart' as models;
import '../models/prediction_model.dart';

class FirestoreService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence
    _firestore.settings = const firestore.Settings(
      persistenceEnabled: true,
    );
  }

  // Collection paths
  String _getTransactionsPath(String userId) => 'users/$userId/transactions';
  String _getChallengesPath(String userId) => 'users/$userId/challenges';
  String _getPredictionsPath(String userId) => 'users/$userId/predictions';

  // ==================== TRANSACTIONS ====================

  Stream<List<models.Transaction>> getTransactions(String userId) {
    return _firestore
        .collection(_getTransactionsPath(userId))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Transaction.fromMap(doc.data()..['id'] = doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error fetching transactions: $error');
          return <models.Transaction>[];
        });
  }

  Future<void> addTransaction(String userId, models.Transaction transaction) async {
    try {
      await _firestore
          .collection(_getTransactionsPath(userId))
          .add(transaction.toMap());
      debugPrint('✅ Transaction added successfully');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error adding transaction: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        debugPrint('💡 Tip: Enable Cloud Firestore API in Firebase Console');
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(
      String userId, String transactionId, models.Transaction transaction) async {
    try {
      await _firestore
          .collection(_getTransactionsPath(userId))
          .doc(transactionId)
          .update(transaction.toMap());
      debugPrint('✅ Transaction updated successfully');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error updating transaction: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _firestore
          .collection(_getTransactionsPath(userId))
          .doc(transactionId)
          .delete();
      debugPrint('✅ Transaction deleted successfully');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error deleting transaction: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error deleting transaction: $e');
      rethrow;
    }
  }

  // ==================== CHALLENGES ====================

  Stream<List<models.Challenge>> getChallenges(String userId) {
    return _firestore
        .collection(_getChallengesPath(userId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Challenge.fromMap(doc.data()..['id'] = doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error fetching challenges: $error');
          return <models.Challenge>[];
        });
  }

  Future<void> updateChallenge(
      String userId, String challengeId, models.Challenge challenge) async {
    try {
      await _firestore
          .collection(_getChallengesPath(userId))
          .doc(challengeId)
          .update(challenge.toMap());
      debugPrint('✅ Challenge updated successfully');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error updating challenge: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating challenge: $e');
      rethrow;
    }
  }

  // ==================== USER DATA ====================

  Future<void> updateUserRewardPoints(String userId, int points) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'rewardPoints': firestore.FieldValue.increment(points),
      });
      debugPrint('✅ Reward points updated successfully');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error updating reward points: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating reward points: $e');
      rethrow;
    }
  }

  // ==================== PREDICTION HISTORY ====================

  /// Save a stock prediction to Firestore
  Future<void> savePrediction(String userId, PredictionHistory prediction) async {
    try {
      await _firestore
          .collection(_getPredictionsPath(userId))
          .add(prediction.toMap());
      debugPrint('✅ Prediction saved to Firestore');
    } on firestore.FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error saving prediction: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        debugPrint('💡 Tip: Enable Cloud Firestore API in Firebase Console');
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error saving prediction: $e');
      rethrow;
    }
  }

  /// Get all predictions for a user (stream)
  Stream<List<PredictionHistory>> getPredictions(String userId) {
    return _firestore
        .collection(_getPredictionsPath(userId))
        .orderBy('timestamp', descending: true)
        .limit(50) // Get last 50 predictions
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PredictionHistory.fromMap(doc.data()..['id'] = doc.id))
            .toList())
        .handleError((error) {
          debugPrint('⚠️ Error fetching predictions: $error');
          return <PredictionHistory>[];
        });
  }

  /// Get predictions for a specific ticker
  Future<List<PredictionHistory>> getPredictionsForTicker(
      String userId, String ticker) async {
    try {
      final snapshot = await _firestore
          .collection(_getPredictionsPath(userId))
          .where('ticker', isEqualTo: ticker)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      
      return snapshot.docs
          .map((doc) => PredictionHistory.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching predictions for ticker: $e');
      return [];
    }
  }

  /// Get prediction statistics for a user
  Future<Map<String, dynamic>> getPredictionStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_getPredictionsPath(userId))
          .get();
      
      if (snapshot.docs.isEmpty) {
        return {
          'totalPredictions': 0,
          'bullishCount': 0,
          'bearishCount': 0,
          'neutralCount': 0,
        };
      }

      int bullish = 0;
      int bearish = 0;
      int neutral = 0;

    for (var doc in snapshot.docs) {
  final data = doc.data();
  final risk = data['riskIndication'] ?? 'NEUTRAL';
  if (risk == 'BULLISH') {
    bullish++;
  } else if (risk == 'BEARISH') {
    bearish++;
  } else {
    neutral++;
  }
}

      return {
        'totalPredictions': snapshot.docs.length,
        'bullishCount': bullish,
        'bearishCount': bearish,
        'neutralCount': neutral,
      };
    } catch (e) {
      debugPrint('Error fetching prediction stats: $e');
      return {
        'totalPredictions': 0,
        'bullishCount': 0,
        'bearishCount': 0,
        'neutralCount': 0,
      };
    }
  }
}