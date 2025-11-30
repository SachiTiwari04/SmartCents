// lib/providers/transactions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartcents/models/transaction_model.dart';
import 'package:smartcents/providers/firestore_provider.dart';

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Transaction.fromMap({...doc.data(), 'id': doc.id});
    }).toList();
  });
});

// Provider to add a transaction
final addTransactionProvider = Provider<Future<void> Function(Transaction)>((ref) {
  return (Transaction transaction) async {
    final firestore = ref.read(firestoreProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  };
});

// Provider to delete a transaction
final deleteTransactionProvider = Provider<Future<void> Function(String)>((ref) {
  return (String transactionId) async {
    final firestore = ref.read(firestoreProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  };
});

// Provider to update a transaction
final updateTransactionProvider = Provider<Future<void> Function(Transaction)>((ref) {
  return (Transaction transaction) async {
    final firestore = ref.read(firestoreProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  };
});

// Provider for transaction statistics
final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      return TransactionStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        transactionCount: transactions.length,
      );
    },
    loading: () => TransactionStats.empty(),
    error: (_, __) => TransactionStats.empty(),
  );
});

class TransactionStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;

  TransactionStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  factory TransactionStats.empty() {
    return TransactionStats(
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      transactionCount: 0,
    );
  }
}