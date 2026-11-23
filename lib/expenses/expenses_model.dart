import '../base_model.dart';
import 'expenses_db_worker.dart';

/// Manages the list of expenses and the currently edited expense.
///
/// Inherits loading, saving, deleting, and screen management
/// functionality from BaseModel.
class ExpensesModel extends BaseModel<Expense> {
  ExpensesModel() : super(ExpensesDBWorker.db);
}

/// Represents a single expense recorded by the user.
class Expense extends Entry with DateMixin {
  String title;
  double amount;
  String category;
  String paymentMethod;
  String? description;

  /// Creates a new expense with the provided information.
  Expense({
    super.id = Entry.noId,
    this.title = '',
    this.amount = 0.0,
    this.category = 'Other',
    this.paymentMethod = 'Cash',
    this.description,
    DateTime? expenseDate,
  }) {
    date = expenseDate ?? DateTime.now();
  }

  /// Returns the date when the expense occurred.
  DateTime? get expenseDate => date;

  /// Updates the date when the expense occurred.
  set expenseDate(DateTime? value) => date = value;

  /// Returns the expense date in Unix milliseconds.
  int? get expenseDateInUnix => dateInUnix;

  /// Sets the expense date using Unix milliseconds.
  set expenseDateInUnix(int? value) => dateInUnix = value;

  /// Returns the expense date as a formatted string.
  String? get formattedExpenseDate => formattedDate;

  /// Creates a separate copy of the expense.
  Expense clone() => Expense(
    id: id,
    title: title,
    amount: amount,
    category: category,
    paymentMethod: paymentMethod,
    description: description,
    expenseDate: expenseDate,
  );

  /// Returns a readable representation of the expense.
  @override
  String toString() =>
      '{id=$id, title=$title, amount=$amount, '
      'category=$category, date=$expenseDate, '
      'paymentMethod=$paymentMethod, '
      'description=$description}';
}
