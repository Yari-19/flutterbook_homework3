import 'package:flutterbook/base_model.dart';
import 'tasks_model.dart';

/// SQLite-backed persistence for [Task] entries.
///
/// Supplies the schema and the conversion logic required by
/// [SqliteDBWorker]; all CRUD operations are inherited unchanged.
/// Access the singleton instance via [TasksDBWorker.db].
class TasksDBWorker extends SqliteDBWorker<Task> {
  static final TasksDBWorker db = TasksDBWorker._();
  TasksDBWorker._();

  @override
  String get dbName => 'tasks.db';

  @override
  String get tableName => 'tasks';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY,
      description TEXT,
      dueDate INTEGER,
      completed INTEGER
    )''';

  @override
  Map<String, dynamic> toMap(Task task) => {
    'id': task.id,
    'description': task.description,
    'dueDate': task.dueDateInUnix,
    'completed': task.completed ? 1 : 0,
  };

  @override
  Task fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    description: map['description'],
    completed: map['completed'] != 0,
  )..dueDateInUnix = map['dueDate'];
}