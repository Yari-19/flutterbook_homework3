import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tasks_model.dart';

/// A stateful widget for creating and editing a task.
class TasksEntry extends StatefulWidget {
  const TasksEntry({super.key});

  @override
  State<TasksEntry> createState() => _TasksEntryState();
}

class _TasksEntryState extends State<TasksEntry> {
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Task being edited.
  Task? _currentTask;

  /// Initializes the text controller and synchronizes it with the model.
  @override
  void initState() {
    super.initState();
    final model = context.read<TasksModel>();
    _descriptionEditingController.addListener(() {
      model.entryBeingEdited?.description = _descriptionEditingController.text;
    });
  }

  /// Releases the resources used by the text controller.
  @override
  void dispose() {
    _descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TasksModel>();

    // for "editing" an existing task
    if (_currentTask != model.entryBeingEdited) {
      _currentTask = model.entryBeingEdited;
      _descriptionEditingController.text =
          model.entryBeingEdited?.description ?? '';
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                model.stopEditingEntry();
              },
            ),
            const Spacer(),
            FilledButton(
              child: const Text('Save'),
              onPressed: () {
                _save(context, model);
              },
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.content_paste),
              title: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: InputDecoration(hintText: 'Description'),
                controller: _descriptionEditingController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Due Date'),
              subtitle: _dueDate(model.entryBeingEdited),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () async => _editDueDate(context, model),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the due date of [task] as a [Text] widget,
  /// or `null` if the task has no due date.
  Text? _dueDate(Task? task) {
    final date = task?.formattedDueDate;
    return date != null ? Text(date) : null;
  }

  /// Displays a date picker for the current task's due date
  /// and updates the task if a date is selected.
  Future<void> _editDueDate(BuildContext context, TasksModel model) async {
    DateTime? chosenDate = await _selectDate(
      context,
      model.entryBeingEdited!.dueDate,
    );
    if (chosenDate != null) {
      model.setDueDate(chosenDate);
    }
  }

  /// Validates the form, saves the current task,
  /// and displays a confirmation message.
  Future<void> _save(BuildContext context, TasksModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await model.stopEditingEntry(save: true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text('Task saved'),
        ),
      );
    }
  }

  /// Displays a date picker, initially displaying [date] or the
  /// current date if [date] is `null`.
  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async {
    return showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }
}
