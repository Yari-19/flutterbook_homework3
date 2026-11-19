import 'package:flutterbook/base_model.dart';
import 'appointments_model.dart';

/// SQLite-backed persistence for [Appointment] entries.
///
/// Supplies the schema and the conversion logic required by
/// [SqliteDBWorker]; all CRUD operations are inherited unchanged.
/// Access the singleton instance via [AppointmentsDBWorker.db].
class AppointmentsDBWorker extends SqliteDBWorker<Appointment> {
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  AppointmentsDBWorker._();

  @override
  String get dbName => 'appointments.db';

  @override
  String get tableName => 'appointments';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS appointments (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      date INTEGER,
      time INTEGER
    )''';

  @override
  Map<String, dynamic> toMap(Appointment app) => {
    'id': app.id,
    'title': app.title,
    'description': app.description,
    'date': app.dateInUnix ?? -1,
    'time': app.timeInUnix ?? -1,
  };

  @override
  Appointment fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'],
    title: map['title'],
    description: map['description'],
  )
    ..dateInUnix = map['date'] >= 0 ? map['date'] : null
    ..timeInUnix = map['time'] >= 0 ? map['time'] : null;
}