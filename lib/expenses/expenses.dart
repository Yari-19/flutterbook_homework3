import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expenses_entry.dart';
import 'expenses_list.dart';
import 'expenses_model.dart';

/// Main interface for managing expenses.
///
/// Watches [ExpensesModel] to switch between [ExpensesList] and [ExpensesEntry].
class Expenses extends StatelessWidget {
  /// Creates the Expenses tab; requires an ancestor provider of [ExpensesModel].
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
