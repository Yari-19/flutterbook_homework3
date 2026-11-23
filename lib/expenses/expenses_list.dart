import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'expenses_model.dart';

/// Displays the expenses stored in the database.
///
/// Watches [ExpensesModel] for updates. Tap an expense to edit it, use Add
/// to create one, or slide a row to reveal the confirmed delete action.
class ExpensesList extends StatelessWidget {
  /// Creates the list; requires an ancestor provider of [ExpensesModel].
  const ExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpensesModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.startEditingEntry(Expense()),
        child: const Icon(Icons.add),
      ),
      body: model.entryList.isEmpty
          ? const Center(child: Text('No expenses yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: model.entryList.length,
              itemBuilder: (context, index) {
                final Expense expense = model.entryList[index];
                return Slidable(
                  key: ValueKey(expense.id),

                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteExpense(context, expense),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),

                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(_categoryIcon(expense.category)),
                      ),
                      title: Text(expense.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(expense.category),
                          Text(expense.formattedExpenseDate ?? 'No date'),
                          Text(expense.paymentMethod),
                        ],
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => model.startEditingEntry(expense),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Returns the category icon, defaulting to a money icon for other categories.
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Transportation':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.attach_money;
    }
  }

  /// Deletes [expense] through the model only after the user confirms.
  Future<void> _deleteExpense(BuildContext context, Expense expense) async {
    final model = context.read<ExpensesModel>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await model.deleteEntry(expense);

      if (!context.mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Expense deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
