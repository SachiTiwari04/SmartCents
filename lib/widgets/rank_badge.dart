// lib/widgets/rank_badge.dart
import 'package:flutter/material.dart';
import 'package:smartcents/theme/app_theme.dart';

class RankBadge {
  final String name;
  final String emoji;
  final int minPoints;
  final int maxPoints;

  const RankBadge({
    required this.name,
    required this.emoji,
    required this.minPoints,
    required this.maxPoints,
  });
}

final List<RankBadge> rankBadges = [
  const RankBadge(
    name: 'Beginner',
    emoji: '🌱',
    minPoints: 0,
    maxPoints: 50,
  ),
  const RankBadge(
    name: 'Novice',
    emoji: '🔰',
    minPoints: 51,
    maxPoints: 100,
  ),
  const RankBadge(
    name: 'Apprentice',
    emoji: '⚡',
    minPoints: 101,
    maxPoints: 200,
  ),
  const RankBadge(
    name: 'Expert',
    emoji: '🎯',
    minPoints: 201,
    maxPoints: 300,
  ),
  const RankBadge(
    name: 'Master',
    emoji: '💎',
    minPoints: 301,
    maxPoints: 400,
  ),
  const RankBadge(
    name: 'Legend',
    emoji: '👑',
    minPoints: 401,
    maxPoints: 500,
  ),
  const RankBadge(
    name: 'Ultra Legend',
    emoji: '🔥',
    minPoints: 501,
    maxPoints: 800,
  ),
  const RankBadge(
    name: 'Financial Guru',
    emoji: '🌟',
    minPoints: 801,
    maxPoints: 999999,
  ),
];

RankBadge getRankBadge(int points) {
  for (final badge in rankBadges) {
    if (points >= badge.minPoints && points <= badge.maxPoints) {
      return badge;
    }
  }
  return rankBadges.first;
}

class RankBadgeWidget extends StatelessWidget {
  final int points;
  final bool showLabel;

  const RankBadgeWidget({
    super.key,
    required this.points,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final badge = getRankBadge(points);
    final nextBadgeIndex = rankBadges.indexWhere((b) => b.minPoints > points);
    final nextBadge = nextBadgeIndex != -1 ? rankBadges[nextBadgeIndex] : rankBadges.last;
    final pointsToNextRank = nextBadge.minPoints - points;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryCyan,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                badge.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              if (showLabel)
                Text(
                  badge.name,
                  style: const TextStyle(
                    color: AppTheme.primaryCyan,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '$points points',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next: ${nextBadge.name} ${nextBadge.emoji}',
                    style: const TextStyle(
                      color: AppTheme.textCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pointsToNextRank pts',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (points - badge.minPoints) / (badge.maxPoints - badge.minPoints),
                  minHeight: 8,
                  backgroundColor: AppTheme.primaryCyan.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
