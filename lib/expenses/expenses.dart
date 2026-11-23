import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expenses_model.dart';
import 'expenses_list.dart';
import 'expenses_entry.dart';

/// Main interface for managing expenses.
class Expenses extends StatelessWidget {
  const Expenses({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpensesModel>();

    return IndexedStack(
      index: model.screen.index,
      children: const <Widget>[ExpensesList(), ExpensesEntry()],
    );
  }
}
