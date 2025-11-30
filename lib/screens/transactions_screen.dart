// lib/screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/widgets/transaction_list.dart';
import 'package:smartcents/providers/transactions_provider.dart';
import 'package:smartcents/widgets/add_transaction_dialog.dart';
import 'package:smartcents/theme/app_theme.dart';
import 'package:smartcents/widgets/weekly_analysis_card.dart';
import 'package:smartcents/widgets/quick_add_transaction.dart';
import 'package:smartcents/models/transaction_model.dart';
import 'package:smartcents/screens/profile_screen.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
      body: transactionsAsync.when(
        data: (transactions) {
          // Calculate weekly analysis
          final now = DateTime.now();
          final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
          final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
          final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

          double thisWeekTotal = 0;
          double lastWeekTotal = 0;

          for (final tx in transactions) {
            if (tx.type == 'expense') {
              if (tx.date.isAfter(thisWeekStart) && tx.date.isBefore(now.add(const Duration(days: 1)))) {
                thisWeekTotal += tx.amount;
              } else if (tx.date.isAfter(lastWeekStart) && tx.date.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
                lastWeekTotal += tx.amount;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Add Transaction
                QuickAddTransaction(
                  onAdd: (title, amount, category, type) {
                    final transaction = Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      amount: amount,
                      type: type,
                      category: category,
                      date: DateTime.now(),
                    );
                    ref.read(addTransactionProvider)(transaction);
                  },
                ),
                const SizedBox(height: 16),

                // Weekly Analysis
                WeeklyAnalysisCard(
                  thisWeekTotal: thisWeekTotal,
                  lastWeekTotal: lastWeekTotal,
                ),
                const SizedBox(height: 16),

                // Transactions List
                if (transactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first transaction to get started',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRANSACTION HISTORY',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TransactionList(transactions: transactions),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryCyan),
        ),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}