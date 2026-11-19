import 'package:flutterbook/base_model.dart';
import 'notes_model.dart';

/// SQLite-backed persistence for [Note] entries.
///
/// Supplies the schema and the conversion logic required by
/// [SqliteDBWorker]; all CRUD operations are inherited unchanged.
/// Access the singleton instance via [NotesDBWorker.db].
class NotesDBWorker extends SqliteDBWorker<Note> {
  static final NotesDBWorker db = NotesDBWorker._();

  NotesDBWorker._();

  @override
  String get dbName => 'notes.db';

  @override
  String get tableName => 'notes';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS notes (
      id INTEGER PRIMARY KEY,
      title TEXT,
      content TEXT,
      color TEXT
    )''';

  @override
  Map<String, dynamic> toMap(Note note) => {
    'id': note.id,
    'title': note.title,
    'content': note.content,
    'color': note.colorName,
  };

  @override
  Note fromMap(Map<String, dynamic> map) => Note(
    id: map['id'],
    title: map['title'],
    content: map['content'],
  )..colorName = map['color'];
}