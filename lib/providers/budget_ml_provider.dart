// lib/providers/budget_ml_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_stats_provider.dart';

/// Result of budget deviation ML classification
class BudgetDeviationResult {
  final String classification; // e.g., 'CRITICAL', 'HIGH', 'LOW', 'STABLE'
  final String message;
  final double deviationPercent;
  final bool isAnomalous;

  const BudgetDeviationResult({
    required this.classification,
    required this.message,
    required this.deviationPercent,
    required this.isAnomalous,
  });
}

/// Analyzes budget deviation using personalized user statistics
/// Replaces hardcoded averages with user-specific data
final budgetDeviationProvider = FutureProvider.family<BudgetDeviationResult, (String, double)>((ref, params) async {
  final (category, amount) = params;

  // Fetch user's personalized category average
  final statsAsync = await ref.watch(userStatsProvider.future);
  final avg = statsAsync.monthlyAverages[category] ?? 100.0;

  // Calculate deviation ratio
  final ratio = avg == 0 ? 0.0 : amount / avg;
  final deviationPercent = ((ratio - 1) * 100).abs();

  // ML Classification Logic
  late String classification;
  late String message;
  late bool isAnomalous;

  if (ratio >= 1.5) {
    classification = 'CRITICAL';
    message = 'Deviation: CRITICAL (${deviationPercent.toStringAsFixed(0)}% above average $category)';
    isAnomalous = true;
  } else if (ratio >= 1.2) {
    classification = 'HIGH';
    message = 'Deviation: HIGH (Significant spike in $category)';
    isAnomalous = true;
  } else if (ratio <= 0.5) {
    classification = 'LOW';
    message = 'Deviation: LOW (Great savings on $category!)';
    isAnomalous = false;
  } else {
    classification = 'STABLE';
    message = 'Deviation: STABLE (Normal pattern detected)';
    isAnomalous = false;
  }

  return BudgetDeviationResult(
    classification: classification,
    message: message,
    deviationPercent: deviationPercent,
    isAnomalous: isAnomalous,
  );
});
