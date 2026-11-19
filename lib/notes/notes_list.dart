import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'notes_model.dart';

/// A stateless widget that displays the list of saved notes.
class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotesModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.startEditingEntry(Note()),
        child: const Icon(Icons.add),
      ),
      body: model.entryList.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
              itemCount: model.entryList.length,
              itemBuilder: (context, index) {
                final Note note = model.entryList[index];

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    endActionPane: ActionPane(
                      extentRatio: .25,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          label: 'Delete',
                          icon: Icons.delete,
                          onPressed: (ctx) => _deleteNote(context, note),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 8,
                      color: note.color,
                      child: ListTile(
                        title: Text(note.title ?? ''),
                        subtitle: Text(note.content ?? ''),
                        onTap: () => model.startEditingEntry(note),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a confirmation dialog and deletes [note] if confirmed.
  Future<void> _deleteNote(BuildContext context, Note note) {
    final model = context.read<NotesModel>();
    final messenger = ScaffoldMessenger.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Really delete ${note.title ?? 'this note'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await model.deleteEntry(note);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                messenger.showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Note deleted'),
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
