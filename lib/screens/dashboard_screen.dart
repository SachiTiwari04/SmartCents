// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/providers/auth_provider.dart';
import 'package:smartcents/providers/stock_provider.dart';
import 'package:smartcents/widgets/transaction_list.dart';
import 'package:smartcents/providers/transactions_provider.dart';
import 'package:smartcents/theme/app_theme.dart';
import 'package:smartcents/screens/profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final watchlistStocksAsync = ref.watch(watchlistStocksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsync.when(
              data: (user) => Text(
                'Welcome back, ${user?.displayName ?? 'User'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              loading: () => const CircularProgressIndicator(color: AppTheme.primaryCyan),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORTFOLIO OVERVIEW',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    transactionsAsync.when(
                      data: (transactions) {
                        double totalIncome = 0;
                        double totalExpense = 0;
                        for (final tx in transactions) {
                          if (tx.type == 'income') {
                            totalIncome += tx.amount;
                          } else {
                            totalExpense += tx.amount;
                          }
                        }
                        final balance = totalIncome - totalExpense;
                        return Column(
                          children: [
                            _buildPortfolioRow('Total Income', '₹${totalIncome.toStringAsFixed(0)}', AppTheme.successGreen),
                            const SizedBox(height: 12),
                            _buildPortfolioRow('Total Expense', '₹${totalExpense.toStringAsFixed(0)}', AppTheme.warningOrange),
                            const SizedBox(height: 12),
                            _buildPortfolioRow('Balance', '₹${balance.toStringAsFixed(0)}', AppTheme.primaryCyan),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(color: AppTheme.primaryCyan),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECENT ACTIVITY',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    transactionsAsync.when(
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No transactions yet'),
                            ),
                          );
                        }
                        return TransactionList(
                          transactions: transactions.take(5).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                      ),
                      error: (error, _) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WATCHLIST',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    watchlistStocksAsync.when(
                      data: (stocks) {
                        if (stocks.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No stocks in watchlist'),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
                            return ListTile(
                              title: Text(stock.symbol),
                              subtitle: Text(stock.name),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$ ${stock.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryCyan,
                                    ),
                                  ),
                                  Text(
                                    '${stock.changePercent >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: stock.changePercent >= 0
                                          ? AppTheme.successGreen
                                          : AppTheme.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                      ),
                      error: (error, _) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}