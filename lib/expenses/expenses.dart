import 'package:flutter/material.dart';

import 'expenses_list.dart';

/// Displays the main interface for managing expenses.
class Expenses extends StatelessWidget {
  const Expenses({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpensesList();
  }
}
