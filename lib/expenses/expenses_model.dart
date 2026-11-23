import '../base_model.dart';
import 'expenses_db_worker.dart';

/// Manages the list of expenses and the currently edited expense.
///
/// Inherits loading, saving, deleting, and screen management
/// functionality from [BaseModel], backed by [ExpensesDBWorker.db].
class ExpensesModel extends BaseModel<Expense> {
  /// Creates the model using the shared expenses database worker.
  ExpensesModel() : super(ExpensesDBWorker.db);
}

/// Represents a single expense recorded by the user.
class Expense extends Entry with DateMixin {
  /// Short label displayed in the expense list.
  String title;

  /// Monetary amount, displayed with two decimal places in the list.
  double amount;

  /// Category used to group the expense and choose its list icon.
  String category;

  /// Payment method, such as cash, debit card, or credit card.
  String paymentMethod;

  /// Optional additional information entered by the user.
  String? description;

  /// Creates a new expense with the provided information.
  ///
  /// Uses [Entry.noId] until persisted and today's date when [expenseDate]
  /// is omitted. The entry form requires a title and a positive finite amount.
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

  /// Returns the expense date in U.S. English, or null if no date is set.
  String? get formattedExpenseDate => formattedDate;

  /// Creates a separate copy, retaining the database ID.
  ///
  /// If the date is null, the constructor defaults the copy's date to now.
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
