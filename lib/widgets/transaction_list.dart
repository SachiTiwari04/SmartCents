// lib/widgets/transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartcents/models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: Icon(
            transaction.type == 'Income'
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: transaction.type == 'Income' ? Colors.green : Colors.red,
          ),
          title: Text(transaction.category),
          subtitle: Text(
            DateFormat('MMM dd, yyyy').format(transaction.date),
          ),
          trailing: Text(
            '${transaction.type == 'Income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transaction.type == 'Income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}