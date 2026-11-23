import '../base_model.dart';
import 'expenses_model.dart';

/// SQLite-backed persistence for [Expense] entries.
///
/// Provides the table schema and conversion methods.
/// CRUD operations are inherited from [SqliteDBWorker].
class ExpensesDBWorker extends SqliteDBWorker<Expense> {
  /// Shared worker for the expenses database.
  static final ExpensesDBWorker db = ExpensesDBWorker._();

  ExpensesDBWorker._();

  @override
  String get dbName => 'expenses.db';

  @override
  String get tableName => 'expenses';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS expenses (
      id INTEGER PRIMARY KEY,
      title TEXT,
      amount REAL,
      category TEXT,
      expenseDate INTEGER,
      paymentMethod TEXT,
      description TEXT
    )''';

  /// Converts an Expense object into a database row.
  @override
  Map<String, dynamic> toMap(Expense expense) => {
    'id': expense.id,
    'title': expense.title,
    'amount': expense.amount,
    'category': expense.category,
    'expenseDate': expense.expenseDateInUnix,
    'paymentMethod': expense.paymentMethod,
    'description': expense.description,
  };

  /// Converts a database row into an Expense object.
  @override
  Expense fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as int,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    category: map['category'] as String,
    paymentMethod: map['paymentMethod'] as String,
    description: map['description'] as String?,
  )..expenseDateInUnix = map['expenseDate'] as int?;
}
