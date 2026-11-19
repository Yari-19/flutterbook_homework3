import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appointments_model.dart';

class AppointmentsEntry extends StatefulWidget {
  const AppointmentsEntry({super.key});

  @override
  State<AppointmentsEntry> createState() => _AppointmentsEntryState();
}

/// A stateful widget for creating and editing an appointment.
class _AppointmentsEntryState extends State<AppointmentsEntry> {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Appointment being edited.
  Appointment? _currentAppointment;

  /// Initializes the text controllers and synchronizes them with
  /// the appointment being edited.
  @override
  void initState() {
    super.initState();
    final model = context.read<AppointmentsModel>();
    _titleEditingController.addListener(() {
      model.entryBeingEdited?.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      model.entryBeingEdited?.description = _descriptionEditingController.text;
    });
  }

  /// Releases the resources used by the text controllers.
  @override
  void dispose() {
    _titleEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppointmentsModel>();
    if (_currentAppointment != model.entryBeingEdited) {
      _currentAppointment = model.entryBeingEdited;
      _titleEditingController.text = _currentAppointment?.title ?? '';
      _descriptionEditingController.text =
          _currentAppointment?.description ?? '';
    }
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                model.stopEditingEntry();
              },
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => _save(context, model),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // appointment title
            ListTile(
              leading: const Icon(Icons.title),
              title: TextFormField(
                decoration: const InputDecoration(hintText: 'Title'),
                controller: _titleEditingController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),

            // appointment description
            ListTile(
              leading: const Icon(Icons.content_paste),
              title: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: const InputDecoration(hintText: 'Description'),
                controller: _descriptionEditingController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),

            // appointment date
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Date'),
              subtitle: model.entryBeingEdited?.dateAsText,
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () =>
                    model.entryBeingEdited?.pickDate(context, model),
              ),
            ),

            // appointment time
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Time'),
              subtitle: model.entryBeingEdited?.timeAsText,
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () =>
                    model.entryBeingEdited?.pickTime(context, model),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates the form, saves the appointment, and returns to
  /// the appointment list.
  Future<void> _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await model.stopEditingEntry(save: true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Appointment saved'),
      ),
    );
  }
}

/// Adds UI-specific presentation and interaction behavior to [Appointment].
extension _AppointmentUIExtension on Appointment {
  /// Returns the appointment time as a [Text] widget,
  /// or `null` if no time is set.
  Text? get timeAsText => hasTime ? Text(formattedTime!) : null;

  /// Returns the appointment date as a [Text] widget,
  /// or `null` if no date is set.
  Text? get dateAsText => hasDate ? Text(formattedDate!) : null;

  /// Displays a date picker and updates the appointment if
  /// a date is selected.
  Future<void> pickDate(BuildContext context, AppointmentsModel model) async {
    final chosenDate = await _selectDate(context, date);
    if (chosenDate != null) {
      model.setDate(chosenDate);
    }
  }

  /// Displays a time picker and updates the appointment if
  /// a time is selected.
  Future<void> pickTime(BuildContext context, AppointmentsModel model) async {
    final initialTime = hasTime
        ? TimeOfDay(hour: time!.hour, minute: time!.minute)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      model.setTime(picked.hour, picked.minute);
    }
  }

  /// Displays a date picker, initially showing [date] or the
  /// current date if [date] is `null`.
  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) {
    return showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }
}
