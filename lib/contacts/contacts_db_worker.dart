import 'package:flutterbook/base_model.dart';
import 'contacts_model.dart';

/// SQLite-backed persistence for [Contact] entries.
///
/// Supplies the schema and the conversion logic required by
/// [SqliteDBWorker]; all CRUD operations are inherited unchanged.
/// Access the singleton instance via [ContactsDBWorker.db].
class ContactsDBWorker extends SqliteDBWorker<Contact> {
  static final ContactsDBWorker db = ContactsDBWorker._();

  ContactsDBWorker._();

  @override
  String get dbName => 'contacts.db';

  @override
  String get tableName => 'contacts';

  @override
  String get createTableSql => '''
    CREATE TABLE IF NOT EXISTS contacts (
      id INTEGER PRIMARY KEY,
      name TEXT,
      phone TEXT,
      email TEXT,
      birthday INTEGER
    )''';

  @override
  Map<String, dynamic> toMap(Contact contact) => {
    'id': contact.id,
    'name': contact.name,
    'phone': contact.phone,
    'email': contact.email,
    'birthday': contact.birthdayInUnix ?? -1,
  };

  @override
  Contact fromMap(Map<String, dynamic> map) => Contact(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
  )..birthdayInUnix = map['birthday'] < 0 ? null : map['birthday'];
}