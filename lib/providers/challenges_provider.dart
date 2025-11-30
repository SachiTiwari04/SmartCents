// lib/providers/challenges_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';

// Provider for ChallengeService
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService();
});

// Provider for daily challenges
final dailyChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  
  final service = ref.watch(challengeServiceProvider);
  return service.getDailyChallenges(user.uid);
});

// Provider for user stats (brownie points and rank)
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return {
      'browniePoints': 0,
      'totalChallengesCompleted': 0,
      'rank': 'Beginner 🌱',
      'nextRank': 'Novice 🔰',
      'pointsToNextRank': 50,
    };
  }
  
  final service = ref.watch(challengeServiceProvider);
  return service.getUserStats(user.uid);
});

// Provider for challenge history
final challengeHistoryProvider = StreamProvider<List<Challenge>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(challengeServiceProvider);
  return service.getChallengeHistory(user.uid);
});