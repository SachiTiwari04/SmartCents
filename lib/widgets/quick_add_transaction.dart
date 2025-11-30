// lib/widgets/quick_add_transaction.dart
import 'package:flutter/material.dart';
import 'package:smartcents/theme/app_theme.dart';

class QuickAddTransaction extends StatefulWidget {
  final Function(String title, double amount, String category, String type) onAdd;
  final bool expanded;

  const QuickAddTransaction({
    super.key,
    required this.onAdd,
    this.expanded = false,
  });

  @override
  State<QuickAddTransaction> createState() => _QuickAddTransactionState();
}

class _QuickAddTransactionState extends State<QuickAddTransaction> {
  late bool _isExpanded;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  String _selectedCategory = 'Food';
  String _selectedType = 'expense';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Utilities',
    'Shopping',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded;
    _titleController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    widget.onAdd(
      _titleController.text,
      amount,
      _selectedCategory,
      _selectedType,
    );

    _titleController.clear();
    _amountController.clear();
    _selectedCategory = 'Food';
    _selectedType = 'expense';
    setState(() => _isExpanded = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
            color: AppTheme.primaryCyan.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUICK ADD',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.primaryCyan,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            // Type selector
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton('Income', 'income'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton('Expense', 'expense'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Transaction title',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            // Amount field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 12),
            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryCyan,
                  width: 1.5,
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppTheme.cardBg,
                style: const TextStyle(color: AppTheme.primaryCyan),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, String type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCyan : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryCyan,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.darkBg : AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
