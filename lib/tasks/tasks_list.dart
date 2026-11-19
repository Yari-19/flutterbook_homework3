import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'tasks_model.dart';

/// A stateless widget that displays the list of saved tasks.
class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TasksModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => model.startEditingEntry(Task()),
      ),
      body: model.entryList.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: model.entryList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = model.entryList[index];
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    endActionPane: ActionPane(
                      extentRatio: .25,
                      motion: const ScrollMotion(),
                      children: <Widget>[
                        SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          label: 'Delete',
                          icon: Icons.delete,
                          onPressed: task.delete,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (bool? value) async =>
                            task.updateCompletion(value, model),
                      ),
                      title: task.styledDescription(context),
                      subtitle: task.styledDueDate(context),
                      onTap: () async => task.edit(model),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Adds UI-specific presentation and interaction behavior to [Task].
extension _TaskUIExtension on Task {
  /// Returns the task description styled according to its completion status.
  Text? styledDescription(BuildContext context) =>
      _styledText(description, context);

  /// Returns the task due date styled according to its completion status.
  Text? styledDueDate(BuildContext context) =>
      _styledText(formattedDueDate, context);

  /// Updates the task's completion status and saves the change.
  void updateCompletion(bool? checked, TasksModel model) {
    completed = checked ?? false;
    model.updateEntry(this);
  }

  /// Starts editing this task if it has not been completed.
  void edit(TasksModel model) {
    if (!completed) {
      model.startEditingEntry(this);
    }
  }

  /// Displays a confirmation dialog and deletes this task if confirmed.
  Future<void> delete(BuildContext context) {
    final model = context.read<TasksModel>();
    final messenger = ScaffoldMessenger.of(context);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Really delete $description?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: Text('Delete'),
              onPressed: () async {
                await model.deleteEntry(this);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                messenger.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Task deleted'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Returns a [Text] widget styled according to the task's
  /// completion status.
  Text? _styledText(String? text, BuildContext context) =>
      text == null ? null : Text(text, style: _textStyle(context));

  /// Returns the text style used to display this task.
  TextStyle _textStyle(BuildContext context) {
    return completed
        ? TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          )
        : TextStyle(color: Theme.of(context).textTheme.titleLarge!.color);
  }
}
