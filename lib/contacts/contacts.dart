import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'contacts_entry.dart';
import 'contacts_list.dart';
import 'contacts_model.dart';

/// Set the directory where avatar image files are to be stored.
Future<void> setAvatarDirectory() async {
  Avatar.avatarDir = await getApplicationDocumentsDirectory();
}

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: context.watch<ContactsModel>().screen.index,
      children: const <Widget>[ContactsList(), ContactsEntry()],
    );
  }
}
