// lib/widgets/weekly_analysis_card.dart
import 'package:flutter/material.dart';
import 'package:smartcents/theme/app_theme.dart';

class WeeklyAnalysisCard extends StatelessWidget {
  final double thisWeekTotal;
  final double lastWeekTotal;

  const WeeklyAnalysisCard({
    super.key,
    required this.thisWeekTotal,
    required this.lastWeekTotal,
  });

  @override
  Widget build(BuildContext context) {
    final difference = thisWeekTotal - lastWeekTotal;
    final percentChange = lastWeekTotal > 0 ? (difference / lastWeekTotal) * 100 : 0;
    final isLess = difference < 0;
    final statusColor = isLess ? AppTheme.successGreen : AppTheme.warningOrange;
    
    String message;
    if (isLess) {
      message = 'Great job! You spent ₹${difference.abs().toStringAsFixed(0)} less this week!';
    } else if (difference > 0) {
      message = 'Heads up! You spent ₹${difference.toStringAsFixed(0)} more this week.';
    } else {
      message = 'Your spending is consistent this week.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryCyan,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY ANALYSIS',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${thisWeekTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.primaryCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Week',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${lastWeekTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Difference',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isLess ? '-' : '+'}₹${difference.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${percentChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isLess ? Icons.trending_down : Icons.trending_up,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
