import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../expenses/expenses_entry.dart';
import '../expenses/expenses_list.dart';
import '../expenses/expenses_model.dart';

/// A stateless widget that displays the note-taking interface.
///
/// The widget switches between [ExpensesList] and [ExpensesEntry] using an
/// [IndexedStack]. The currently displayed screen is determined by the
/// [ExpensesModel] provided by an ancestor [ChangeNotifierProvider].
class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpensesModel>();
    return IndexedStack(
      index: model.screen.index,
      children: const <Widget>[ExpensesList(), ExpensesEntry()],
    );
  }
}
