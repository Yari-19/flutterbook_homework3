import 'package:intl/intl.dart';

import '../base_model.dart';
import 'appointments_db_worker.dart';

class AppointmentsModel extends BaseModel<Appointment> {
  AppointmentsModel() : super(AppointmentsDBWorker.db);

  /// Returns a list of appointments that occur on the given date.
  List<Appointment> appointmentsOn(DateTime date) =>
      entryList.where((app) => app.isOnDate(date)).toList();

  void setDate(DateTime date) {
    assert(entryBeingEdited != null);
    entryBeingEdited!.date = date;
    notifyListeners();
  }

  void setTime(int hour, int minute) {
    assert(entryBeingEdited != null);
    final appointment = entryBeingEdited!;
    final date = appointment.date ?? DateTime.now();
    appointment.time = DateTime(date.year, date.month, date.day, hour, minute);
    notifyListeners();
  }

  @override
  void startEditingEntry(Appointment entry) {
    if (entry.isNew) {
      entry.date = DateTime.now();
    }
    super.startEditingEntry(entry);
  }
}

class Appointment extends Entry with DateMixin {
  String? title;
  String? description;
  DateTime? time;

  Appointment({
    super.id = Entry.noId,
    this.title,
    this.description,
    DateTime? date,
    this.time,
  }) {
    this.date = date;
  }

  bool get hasTitle => title != null && title!.isNotEmpty;

  bool get hasDescription => description != null && description!.isNotEmpty;

  bool get hasTime => time != null;

  String? get formattedTime => hasTime ? formatTime(time!) : null;

  /// Returns the time in Unix epoch time in milliseconds.
  int? get timeInUnix => hasTime ? time!.millisecondsSinceEpoch : null;

  /// Sets the time in Unix epoch time in milliseconds.
  set timeInUnix(int? millis) {
    DateTime? dateTime;
    if (millis != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    }
    time = dateTime;
  }

  /// Returns true if this appointment is on the given date.
  bool isOnDate(DateTime? date) =>
      this.date != null &&
      date != null &&
      DateTime(this.date!.year, this.date!.month, this.date!.day) ==
          DateTime(date.year, date.month, date.day);

  static String formatTime(DateTime time) => DateFormat('h:mm a').format(time);

  @override
  String toString() =>
      '{id=$id, title=$title, description=$description, date=$date, time=$time}';
}
