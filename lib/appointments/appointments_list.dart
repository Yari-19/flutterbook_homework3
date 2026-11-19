import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
//import 'package:flutter_calendar_carousel/classes/event.dart';

import '../base_model.dart' show DateMixin;
import 'appointments_model.dart';

/// A stateless widget that displays appointments in a calendar
/// and lets the user view appointments for a selected date.
class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppointmentsModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => model.startEditingEntry(Appointment()),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: CalendarCarousel<Appointment>.month(
                eventsForDate: (DateTime date) {
                  return model.appointmentsOn(date);
                },
                onDateSelected:
                    (DateTime date, List<Appointment> appointments) async {
                      var appointmentDeleted = false;
                      do {
                        appointmentDeleted = await _showAppointments(
                          context,
                          date,
                        );
                      } while (appointmentDeleted);
                    },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays a bottom sheet showing appointments for a selected date
  /// and allows the user to edit or delete them.
  Future<bool> _showAppointments(BuildContext context, DateTime date) async {
    final model = context.read<AppointmentsModel>();
    final bool? shouldReopen = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext builderContext) {
        final appointments = model.appointmentsOn(date);
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: /* GestureDetector(
              child: */ Column(
              children: <Widget>[
                // Date
                Text(
                  DateMixin.formatDate(date),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 24,
                  ),
                ),
                const Divider(),

                // All appointments on the date
                Expanded(
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (BuildContext builderContext, int index) {
                      Appointment app = appointments[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          extentRatio: .25,
                          motion: ScrollMotion(),
                          children: <Widget>[
                            SlidableAction(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              label: 'Delete',
                              icon: Icons.delete,
                              onPressed: (ctx) async {
                                var deleted = await app.delete(context);
                                if (deleted == true && context.mounted) {
                                  Navigator.pop(context, deleted);
                                }
                              },
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            tileColor: Colors.grey.shade300,
                            title: app.titleAsText,
                            subtitle: app.descriptionAsText,
                            onTap: () => app.edit(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return shouldReopen == true; // will re-show bottom sheet if true
  }
}

/// Adds UI-specific presentation and interaction behavior to [Appointment].
extension _AppointmentUIExtension on Appointment {
  /// Returns the appointment title as a [Text] widget, including the
  /// appointment time when one is available.
  Text? get titleAsText =>
      hasTime ? Text('$title ($formattedTime)') : Text(title!);

  /// Returns the appointment description as a [Text] widget,
  /// or null when the appointment has no description.
  Text? get descriptionAsText => hasDescription ? Text(description!) : null;

  /// Starts editing this appointment and closes the appointment list.
  void edit(BuildContext context) {
    final model = context.read<AppointmentsModel>();
    model.startEditingEntry(this);
    Navigator.pop(context); // appointment lis
  }

  /// Displays a confirmation dialog and deletes this appointment
  /// if the user confirms.
  Future<bool?> delete(BuildContext context) {
    final model = context.read<AppointmentsModel>();
    final messenger = ScaffoldMessenger.of(context);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Really delete $title?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await model.deleteEntry(this);
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
                messenger.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Appointment deleted'),
                  ),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
