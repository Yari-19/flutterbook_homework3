import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'appointments/appointments.dart';
import 'appointments/appointments_model.dart';
import 'contacts/contacts.dart';
import 'contacts/contacts_model.dart';
import 'notes/notes.dart';
import 'notes/notes_model.dart';
import 'tasks/tasks.dart';
import 'tasks/tasks_model.dart';
import 'expenses/expenses.dart';
import 'expenses/expenses_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setAvatarDirectory(); // for contacts
  if (Platform.isWindows) {
    // for sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const FlutterBook());
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FlutterBook'),
            bottom: TabBar(
              tabs: [
                for (final tab in _tabs)
                  Tab(icon: Icon(tab.icon), text: tab.title),
              ],
            ),
          ),
          body: TabBarView(children: [for (final tab in _tabs) tab.view]),
        ),
      ),
    );
  }
}

typedef _TabInfo = ({String title, IconData icon, Widget view});

final _tabs = <_TabInfo>[
  (
    title: 'Appointments',
    icon: Icons.date_range,
    view: ChangeNotifierProvider(
      create: (_) => AppointmentsModel()..loadData(notify: true),
      child: const Appointments(),
    ),
  ),
  (
    title: 'Contacts',
    icon: Icons.contacts,
    view: ChangeNotifierProvider(
      create: (_) => ContactsModel()..loadData(notify: true),
      child: const Contacts(),
    ),
  ),
  (
    title: 'Notes',
    icon: Icons.note,
    view: ChangeNotifierProvider(
      create: (_) => NotesModel()..loadData(notify: true),
      child: const Notes(),
    ),
  ),
  (
    title: 'Tasks',
    icon: Icons.assignment_turned_in,
    view: ChangeNotifierProvider(
      create: (_) => TasksModel()..loadData(notify: true),
      child: const Tasks(),
    ),
  ),

  (
    title: 'Expenses',
    icon: Icons.attach_money,
    view: ChangeNotifierProvider(
      create: (_) => ExpensesModel()..loadData(notify: true),
      child: const Expenses(),
    ),
  ),
];
