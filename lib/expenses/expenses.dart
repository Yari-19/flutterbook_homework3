import 'package:flutter/material.dart';

/// Displays the main interface for managing expenses.
class Expenses extends StatelessWidget {
  const Expenses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('No expenses yet', style: TextStyle(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Expense coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
