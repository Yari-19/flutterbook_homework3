import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tasks_entry.dart';
import 'tasks_list.dart';
import 'tasks_model.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: context.watch<TasksModel>().screen.index,
      children: const <Widget>[TasksList(), TasksEntry()],
    );
  }
}
