import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notes_entry.dart';
import 'notes_model.dart';
import 'notes_list.dart';

/// A stateless widget that displays the note-taking interface.
///
/// The widget switches between [NotesList] and [NotesEntry] using an
/// [IndexedStack]. The currently displayed screen is determined by the
/// [NotesModel] provided by an ancestor [ChangeNotifierProvider].
class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotesModel>();
    return IndexedStack(
      index: model.screen.index,
      children: const <Widget>[NotesList(), NotesEntry()],
    );
  }
}
