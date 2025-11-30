// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/providers/auth_provider.dart';
import 'package:smartcents/screens/dashboard_screen.dart';
import 'package:smartcents/screens/challenges_screen.dart';
import 'package:smartcents/screens/transactions_screen.dart';
import 'package:smartcents/screens/market_screen.dart';
import 'package:smartcents/theme/app_theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    ChallengesScreen(),
    MarketScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateChangesProvider);

    return Scaffold(
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            // This shouldn't happen as MainScreen is only shown when authenticated
            return const Center(child: Text('Please log in'));
          }
          return IndexedStack(
            index: _selectedIndex,
            children: _screens,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryCyan),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Market',
          ),
        ],
      ),
    );
  }
}