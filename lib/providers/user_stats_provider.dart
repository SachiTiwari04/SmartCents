// lib/providers/user_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User statistics model for personalized budget analysis
class UserStats {
  final Map<String, double> monthlyAverages;
  final int totalTransactions;
  final int rewardPoints;
  final bool firstInvestor;

  const UserStats({
    required this.monthlyAverages,
    required this.totalTransactions,
    required this.rewardPoints,
    required this.firstInvestor,
  });
}

/// Provides personalized user statistics including monthly category averages
/// This replaces hardcoded averages with user-specific data
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  // In a real app, this would fetch from Firestore
  // For now, return mock data that can be personalized
  await Future.delayed(const Duration(milliseconds: 300));

  return const UserStats(
    monthlyAverages: {
      'Groceries': 300.0,
      'Rent': 5000.0,
      'Utilities': 200.0,
      'Entertainment': 150.0,
      'Dining': 250.0,
      'Transport': 100.0,
      'Investment': 1000.0,
    },
    totalTransactions: 0,
    rewardPoints: 0,
    firstInvestor: false,
  );
});

/// Provides a specific category's average for budget deviation analysis
final categoryAverageProvider = FutureProvider.family<double, String>((ref, category) async {
  final stats = await ref.watch(userStatsProvider.future);
  return stats.monthlyAverages[category] ?? 100.0;
});