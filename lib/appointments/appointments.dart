import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appointments_entry.dart';
import 'appointments_list.dart';
import 'appointments_model.dart';

class Appointments extends StatelessWidget {
  const Appointments({super.key});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: context.watch<AppointmentsModel>().screen.index,
      children: const <Widget>[AppointmentsList(), AppointmentsEntry()],
    );
  }
}
