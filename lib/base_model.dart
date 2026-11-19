// Provides a generic model class for managing the current screen,
// a list of entities, and an entity being edited. It includes methods for
// updating the screen, managing entity lists, and handling entity edits.
// The library extends [Provider] to notify listeners of state changes,
// ensuring UI components are updated accordingly.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

/// Identifies the currently displayed screen in an `IndexedStack`.
enum Screen {
  /// The list view.
  list,

  /// The entry editing view.
  entry,
}

/// A base model class that manages the current screen,
/// a list of items, and the item being edited.
abstract class BaseModel<T extends Entry> extends ChangeNotifier {
  /// Current screen being displayed.
  Screen _screen = Screen.list;

  /// A database storing all items managed by this model.
  final EntryDBWorker<T> database;

  /// A list of items that this model manages.
  final List<T> entryList = [];

  /// The item currently being edited, or `null` if no item is
  /// under editing.
  T? entryBeingEdited;

  BaseModel(this.database);

  /// Returns the current screen being displayed.
  Screen get screen => _screen;

  /// Starts editing the specified item by showing the editing screen.
  void startEditingEntry(T entry) {
    entryBeingEdited = entry;
    _screen = Screen.entry;
    notifyListeners();
  }

  /// Stops editing the current item and navigates back to the list screen.
  /// If [save] is true, the changes are saved to the database by either
  /// creating a new item or updating an existing one. The item list is
  /// reloaded after saving.
  Future<int?> stopEditingEntry({bool save = false, bool notify = true}) async {
    assert(entryBeingEdited != null);
    int? id;
    if (save) {
      final item = entryBeingEdited!;
      if (item.isNew) {
        id = await database.create(item);
      } else {
        await database.update(item);
        id = item.id;
      }
    }
    entryBeingEdited = null;
    await loadData(); // nullify edits if any
    _screen = Screen.list;
    if (notify) {
      notifyListeners();
    }
    return id;
  }

  /// Removes given item from the database and refreshes the item list
  /// to reflect the change.
  Future<void> deleteEntry(T entry) async {
    await database.delete(entry.id);
    await loadData();
    notifyListeners();
  }

  /// Loads data from the database into the item list and optionally
  /// notifies the listeners.
  Future<void> loadData({bool notify = false}) async {
    entryList
      ..clear()
      ..addAll(await database.getAll());
    if (notify) {
      notifyListeners();
    }
  }
}

/// A base class representing different kinds of items to be managed.
abstract class Entry {
  /// Default ID value for items without an assigned ID.
  static const int noId = -1;

  /// Unique identifier for the entity, representing the primary key
  /// in the database.
  int id;

  Entry({this.id = noId});

  /// Is this item new that isn't stored in the database?
  bool get isNew => id == noId;
}

/// Provides common property for date-based fields
mixin DateMixin {
  DateTime? date;

  bool get hasDate => date != null;

  /// Returns the date formatted as "MMMM d, yyyy"
  /// using the U.S. English locale.
  int? get dateInUnix => date?.millisecondsSinceEpoch;

  /// Sets the date in Unix epoch time in milliseconds.
  set dateInUnix(int? millis) {
    date = millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Return the date in a localized string in the format (en_US)
  /// 'MMMM d, yyyy'.
  String? get formattedDate => date == null ? null : formatDate(date!);

  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd('en_US').format(date.toLocal());
  }
}

/// Required database interface.
abstract interface class EntryDBWorker<T extends Entry> {
  /// Create and add the given entry in this database.
  Future<int> create(T entry);

  /// Update the given entry of this database.
  Future<void> update(T entry);

  /// Delete the specified entry.
  Future<void> delete(int id);

  /// Return the specified entry, or null.
  Future<T?> get(int id);

  /// Return all the entries of this database.
  Future<List<T>> getAll();
}

/// A reusable SQLite implementation of [EntryDBWorker].
/// Subclasses need only supply the table schema and the
/// conversion between [T] objects and database rows.
abstract class SqliteDBWorker<T extends Entry> implements EntryDBWorker<T> {
  Database? _db;

  /// The name of the SQLite database file.
  String get dbName;

  /// The name of the table that stores entries of type [T].
  String get tableName;

  /// The SQL statement used to create the table, e.g.
  /// `'CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, ...)'`.
  String get createTableSql;

  /// Converts an entry into a map of column names and values.
  Map<String, dynamic> toMap(T entry);

  /// Converts a map of column names and values into an entry.
  T fromMap(Map<String, dynamic> map);

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return openDatabase(
      dbName,
      version: 1,
      onCreate: (db, version) async => db.execute(createTableSql),
    );
  }

  @override
  Future<int> create(T entry) async {
    final db = await database;
    final map = toMap(entry)..remove('id'); // let SQLite assign the id
    return db.insert(tableName, map);
  }

  @override
  Future<void> update(T entry) async {
    final db = await database;
    await db.update(
      tableName,
      toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<T?> get(int id) async {
    final db = await database;
    final rows = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : fromMap(rows.first);
  }

  @override
  Future<List<T>> getAll() async {
    final db = await database;
    final rows = await db.query(tableName);
    return rows.map(fromMap).toList();
  }
}
