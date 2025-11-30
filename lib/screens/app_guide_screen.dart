// lib/screens/app_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:smartcents/theme/app_theme.dart';

class AppGuideScreen extends StatefulWidget {
  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<GuideSection> _sections = [
    GuideSection(
      title: 'DASHBOARD',
      emoji: '📊',
      description: 'Your financial overview at a glance',
      features: [
        'View portfolio overview with total income, expenses, and balance',
        'Track your total balance and financial health',
        'See recent transactions at a glance',
        'Monitor your watchlist of stocks',
      ],
    ),
    GuideSection(
      title: 'TRANSACTIONS',
      emoji: '💳',
      description: 'Manage your income and expenses',
      features: [
        'Add income or expense transactions quickly',
        'Categorize your spending (Food, Transport, etc.)',
        'View complete transaction history',
        'Analyze weekly spending patterns',
        'Compare this week vs last week spending',
      ],
    ),
    GuideSection(
      title: 'CHALLENGES',
      emoji: '🎯',
      description: 'Gamified financial goals',
      features: [
        'Complete daily finance challenges',
        'Earn brownie points for each challenge',
        'Unlock achievement badges and ranks',
        'Level up your rank from Beginner to Financial Guru',
        'Track your progress and challenge history',
      ],
    ),
    GuideSection(
      title: 'MARKET',
      emoji: '📈',
      description: 'AI-powered stock insights',
      features: [
        'Search for any stock ticker (e.g., GOOG, AAPL)',
        'View AI predictions for stock prices',
        'Analyze sentiment analysis (FinBERT)',
        'Read relevant news feeds',
        'Track 30-day historical trends',
        'Monitor your prediction accuracy',
      ],
    ),
    GuideSection(
      title: 'PROFILE SETTINGS',
      emoji: '⚙️',
      description: 'Personalize your experience',
      features: [
        'Update your display name and profile picture',
        'Manage notification preferences',
        'Change currency and language settings',
        'View your account information',
        'Access app guide and support',
        'Logout securely',
      ],
    ),
    GuideSection(
      title: 'BROWNIE POINTS & RANKS',
      emoji: '👑',
      description: 'Gamification system',
      features: [
        'Easy challenges: 10 points',
        'Medium challenges: 25 points',
        'Hard challenges: 50 points',
        'Ranks: Beginner → Novice → Apprentice → Expert → Master → Legend → Ultra Legend → Financial Guru',
        'Unlock new ranks as you earn more points',
      ],
    ),
  ];

  List<GuideSection> get _filteredSections {
    if (_searchQuery.isEmpty) {
      return _sections;
    }
    return _sections
        .where((section) =>
            section.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            section.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            section.features.any((feature) => feature.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Guide'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search features...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Guide Sections
          Expanded(
            child: _filteredSections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "$_searchQuery"',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredSections.length,
                    itemBuilder: (context, index) {
                      return GuideSectionCard(section: _filteredSections[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GuideSection {
  final String title;
  final String emoji;
  final String description;
  final List<String> features;

  GuideSection({
    required this.title,
    required this.emoji,
    required this.description,
    required this.features,
  });
}

class GuideSectionCard extends StatefulWidget {
  final GuideSection section;

  const GuideSectionCard({
    super.key,
    required this.section,
  });

  @override
  State<GuideSectionCard> createState() => _GuideSectionCardState();
}

class _GuideSectionCardState extends State<GuideSectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    widget.section.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.section.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primaryCyan,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppTheme.primaryCyan),
                  const SizedBox(height: 12),
                  ...widget.section.features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
