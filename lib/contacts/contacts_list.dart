import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'contacts_model.dart';

/// A stateless widget that displays the list of contacts and
/// provides actions for adding, editing, and deleting contacts.
class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ContactsModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => model.startEditingEntry(Contact()),
      ),
      body: model.entryList.isEmpty
          ? const Center(child: Text('No contacts yet'))
          : ListView.builder(
              itemCount: model.entryList.length,
              itemBuilder: (context, index) {
                final contact = model.entryList[index];

                return Column(
                  children: [
                    Slidable(
                      endActionPane: ActionPane(
                        extentRatio: .25,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            label: 'Delete',
                            icon: Icons.delete,
                            onPressed: (_) =>
                                model.deleteContact(context, contact),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: contact.avatarAsWidget(model),
                        title: contact.nameAsText,
                        subtitle: contact.phoneAsText,
                        onTap: () => model.startEditingEntry(contact),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
    );
  }
}

/// Adds or adapts model operations to Flutter/UI concepts.
extension _ContactsModelUIExtension on ContactsModel {
  /// Displays a confirmation dialog to delete [contact].
  /// If the contact is deleted, displays a confirmation snack bar.
  Future<void> deleteContact(BuildContext context, Contact contact) {
    final messenger = ScaffoldMessenger.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Really delete ${contact.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await deleteEntry(contact);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Contact deleted'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

/// Adds or adapts contact properties to Flutter/UI concepts.
extension _ContactUIExtension on Contact {
  /// Returns a widget displaying the contact's avatar, or the
  /// first letter of the contact's name when no avatar exists.
  Widget avatarAsWidget(ContactsModel model) {
    final avatarFile = File(model.avatarFileName(id));
    if (avatarFile.existsSync()) {
      return CircleAvatar(
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        backgroundImage: MemoryImage(avatarFile.readAsBytesSync()),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.indigoAccent,
      foregroundColor: Colors.white,
      child: nameAsAvatarText,
    );
  }

  /// Returns the contact's name as a Flutter [Text] widget.
  Text? get nameAsText => name != null ? Text(name!) : null;

  /// Returns the contact's phone number as a Flutter [Text] widget.
  Text? get phoneAsText => phone != null ? Text(phone!) : null;

  /// Returns the first letter of the contact's name as a Flutter [Text]
  /// widget, or '?' if the contact has no name.
  Text get nameAsAvatarText {
    if (name == null || name!.isEmpty) {
      return const Text('?');
    }
    return Text(name![0].toUpperCase());
  }
}
