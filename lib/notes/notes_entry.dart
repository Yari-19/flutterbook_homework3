import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notes_model.dart';

/// A stateful widget for creating and editing a note.
class NotesEntry extends StatefulWidget {
  const NotesEntry({super.key});

  @override
  State<NotesEntry> createState() => _NotesEntryState();
}

class _NotesEntryState extends State<NotesEntry> {
  final TextEditingController _titleEditingController = TextEditingController();

  final TextEditingController _contentEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Note being edited.
  Note? _currentNote;

  /// Initializes the text controllers and synchronizes their
  /// values with the note currently being edited.
  @override
  void initState() {
    super.initState();
    final model = context.read<NotesModel>();
    _titleEditingController.addListener(() {
      model.entryBeingEdited?.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      model.entryBeingEdited?.content = _contentEditingController.text;
    });
  }

  /// Releases the resources used by the text editing controllers.
  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    super.dispose();
  }

  /// Builds the note editing form and its controls.
  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotesModel>();

    // for "editing" a (different) existing note
    if (_currentNote != model.entryBeingEdited) {
      _currentNote = model.entryBeingEdited;
      _titleEditingController.text = _currentNote?.title ?? '';
      _contentEditingController.text = _currentNote?.content ?? '';
    }
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildControlButtons(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTitleListTile(),
            _buildContentListTile(),
            _buildColorListTile(context),
          ],
        ),
      ),
    );
  }

  /// Builds the title input field.
  ListTile _buildTitleListTile() {
    return ListTile(
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
    );
  }

  /// Builds the content input field.
  ListTile _buildContentListTile() {
    return ListTile(
      leading: const Icon(Icons.content_paste),
      title: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 8,
        decoration: const InputDecoration(hintText: 'Content'),
        controller: _contentEditingController,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
          }
          return null;
        },
      ),
    );
  }

  /// Builds the color selection list.
  ListTile _buildColorListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: Row(
        children:
            Note.allColors
                .expand((color) => [_buildColorBox(context, color), Spacer()])
                .toList()
              ..removeLast(),
      ),
    );
  }

  /// Builds a selectable color box for [color].
  GestureDetector _buildColorBox(BuildContext context, Color color) {
    final model = context.watch<NotesModel>();
    return GestureDetector(
      child: Container(
        decoration: ShapeDecoration(
          shape:
              Border.all(width: 16, color: color) +
              Border.all(
                width: 4,
                color: model.color == color
                    ? color
                    : Theme.of(context).canvasColor,
              ),
        ),
      ),
      onTap: () => model.color = color,
    );
  }

  /// Builds the Cancel and Save buttons.
  Row _buildControlButtons(BuildContext context) {
    final model = context.read<NotesModel>();
    return Row(
      children: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            model.stopEditingEntry();
          },
          child: const Text('Cancel'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () => _save(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// Validates the form, saves the current note,
  /// and displays a confirmation snack bar.
  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final model = context.read<NotesModel>();
    await model.stopEditingEntry(save: true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Note saved'),
      ),
    );
  }
}
