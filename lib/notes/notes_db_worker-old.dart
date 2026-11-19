// Provides an abstract interface and concrete implementations
// for managing note data storage in a persistent or in-memory database.
//
// - [NotesDBWorker]: An abstract class defining methods for creating,
//   updating, deleting, and retrieving notes.
// - [_MemoryNotesDBWorker]: A concrete implementation of [NotesDBWorker]
//   that stores notes in memory, suitable for testing or temporary use.
// - [_SqfliteNotesDBWorker]: A concrete implementation of [NotesDBWorker]
//   that uses SQLite to store notes persistently in a local database.
//
import 'package:flutter/material.dart';
import 'package:flutterbook/base_model.dart';
import 'package:sqflite/sqflite.dart';
import 'notes_model.dart';

// ignore_for_file: avoid_print, constant_identifier_names

/// Abstract class for handling note data storage and retrieval operations.
/// This class defines methods for creating, updating, deleting,
/// and retrieving notes. The actual implementation of these methods
/// is provided by subclasses, such as [_MemoryNotesDBWorker]
/// and [_SqfliteNotesDBWorker].
///
abstract class NotesDBWorker implements EntryDBWorker<Note> {

  /// Flag to determine whether to use a database or an in-memory
  /// implementation for testing.
  static const bool _useDatabase = true;

  /// Singleton instance of the appropriate [NotesDBWorker] implementation.
  static final NotesDBWorker db = _useDatabase ? _SqfliteNotesDBWorker._()
      : _MemoryNotesDBWorker._();

  /// Create and add the given note in this database.
  @override
  Future<int> create(Note note);

  /// Update the given note of this database.
  @override
  Future<void> update(Note note);

  /// Delete the specified note.
  @override
  Future<void> delete(int id);

  /// Return the specified note, or null.
  @override
  Future<Note?> get(int id);

  /// Return all the notes of this database.
  @override
  Future<List<Note>> getAll();
}

/// In-memory implementation of [NotesDBWorker] for testing
/// and temporary use.
/// This worker stores notes in memory and supports basic operations like
/// creating, updating, deleting, and fetching notes. It is mainly used in
/// testing scenarios where no permanent database is required.
///
class _MemoryNotesDBWorker implements NotesDBWorker {

  /// Flag indicating if this in-memory worker is being used for testing.
  static const _beingTested = true;

  /// List to store notes in memory.
  final _notes = [];

  /// Counter for generating unique IDs for notes.
  var _nextId = 1;

  /// Private constructor to initialize the in-memory worker.
  _MemoryNotesDBWorker._() {
    if (_beingTested && _notes.isEmpty) {
      var note = Note()
        ..title = 'Exercise: P2.3 Persistence'
        ..content = 'Code database.'
        ..color = Colors.blue;
      create(note);
    }
  }

  @override
  Future<int> create(Note note) async {
    note = note.clone();
    note.id = _nextId++;
    _notes.add(note);
    print('Added: $note');
    return note.id;
  }

  @override
  Future<void> update(Note note) async {
    var old = await get(note.id);
    if (old != null) {
      old
        ..title = note.title
        ..content = note.content
        ..color = note.color;
      print("Updated: $note");
    }
  }

  @override
  Future<void> delete(int id) async {
    _notes.removeWhere((note) => note.id == id);
    print('Deleted: $id');
  }

  @override
  Future<Note?> get(int id) async =>
      _notes.firstWhere((note) => note.id == id, orElse: () => null)?.clone();

  @override
  Future<List<Note>> getAll() async =>
      _notes.map((n) => n.clone() as Note).toList();
}

/// SQLite implementation of [NotesDBWorker] for persistent note storage.
/// This worker uses SQLite to store notes in a local database.
/// It supports creating, updating, deleting, and fetching notes.
/// The database is persisted across application
/// sessions, unlike the in-memory implementation.
///
class _SqfliteNotesDBWorker implements NotesDBWorker {

  /// The name of the SQLite database file.
  // ignore:
  static const String DB_NAME = 'notes.db';

  /// The name of the table where notes are stored.
  static const String TBL_NAME = 'notes';

  /// The column name for the note ID in the database.
  static const String KEY_ID = '_id';

  /// The column name for the note title in the database.
  static const String KEY_TITLE = 'title';

  /// The column name for the note content in the database.
  static const String KEY_CONTENT = 'content';

  /// The column name for the note color in the database.
  static const String KEY_COLOR = 'color';

  Database? _db;

  _SqfliteNotesDBWorker._();

  /// Getter for the database instance.
  Future<Database> get database async => _db ??= await _init();

  /// Initializes the SQLite database and creates the notes table
  /// if it doesn't exist.
  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE IF NOT EXISTS $TBL_NAME ('
                  '$KEY_ID INTEGER PRIMARY KEY,'
                  '$KEY_TITLE TEXT,'
                  '$KEY_CONTENT TEXT,'
                  '$KEY_COLOR TEXT'
                  ')'
          );
        }
    );
  }

  @override
  Future<int> create(Note note) async {
    Database db = await database;
    int id = await db.rawInsert(
        'INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_CONTENT, $KEY_COLOR) '
            'VALUES (?, ?, ?)',
        [note.title, note.content, note.colorName]
    );
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
  }

  @override
  Future<Note?> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
    return values.isEmpty ? null : _noteFromMap(values.first);
  }

  @override
  Future<List<Note>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _noteFromMap(m)).toList() : [];
  }

  @override
  Future<void> update(Note note) async {
    Database db = await database;
    await db.update(TBL_NAME, _noteToMap(note),
        where: '$KEY_ID = ?', whereArgs: [note.id]);
  }

  /// Converts a map from the database into a [Note] object.
  /// This method takes a map of column names and values,
  /// and converts it into a [Note] object that can be used within
  /// the application.
  Note _noteFromMap(Map map) => Note(id: map[KEY_ID],
      title: map[KEY_TITLE], content: map[KEY_CONTENT])
    ..colorName = map[KEY_COLOR];

  /// Converts a [Note] object into a map of column names and values
  /// for database storage.
  /// This method creates a map that represents the fields of a [Note]
  /// object in the format required by the SQLite database.
  Map<String, dynamic> _noteToMap(Note note) => <String, dynamic>{}
      ..[KEY_ID] = note.id
      ..[KEY_TITLE] = note.title
      ..[KEY_CONTENT] = note.content
      ..[KEY_COLOR] = note.colorName;
}
