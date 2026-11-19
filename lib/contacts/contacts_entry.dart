import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'contacts_model.dart';

/// A stateful widget for creating and editing a contact.
class ContactsEntry extends StatefulWidget {
  const ContactsEntry({super.key});

  @override
  State<ContactsEntry> createState() => _ContactsEntryState();
}

class _ContactsEntryState extends State<ContactsEntry> {
  final TextEditingController _nameEditingController = TextEditingController();

  final TextEditingController _phoneEditingController = TextEditingController();

  final TextEditingController _emailEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Contact? _currentContact;

  /// Initializes the text controllers and synchronizes their
  /// values with the contact currently being edited.
  @override
  void initState() {
    super.initState();
    final model = context.read<ContactsModel>();
    _nameEditingController.addListener(() {
      model.entryBeingEdited?.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      model.entryBeingEdited?.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      model.entryBeingEdited?.email = _emailEditingController.text;
    });
  }

  /// Releases the resources used by the text editing controllers.
  @override
  void dispose() {
    _nameEditingController.dispose();
    _phoneEditingController.dispose();
    _emailEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ContactsModel>();

    // for "editing" an existing contact
    if (_currentContact != model.entryBeingEdited) {
      _currentContact = model.entryBeingEdited!;
      _nameEditingController.text = _currentContact?.name ?? '';
      _phoneEditingController.text = _currentContact?.phone ?? '';
      _emailEditingController.text = _currentContact?.email ?? '';
    }

    File avatarFile = model.avatarFile();

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        // cancel and save buttons
        child: Row(
          children: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                model.stopEditingEntry();
              },
            ),
            const Spacer(),
            FilledButton(
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
            ListTile(
              title: avatarFile.existsSync()
                  ?
              //Image.file(avatarFile)
              Image.memory(avatarFile.readAsBytesSync(),
                alignment: Alignment.center,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              )
                  : const Text("No avatar image for this contact"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                //color: Colors.blue,
                onPressed: () => _selectAvatar(context),
              ),
            ),

            ListTile(
              // name
              leading: const Icon(Icons.person),
              title: TextFormField(
                decoration: const InputDecoration(hintText: 'Name'),
                controller: _nameEditingController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),

            ListTile(
              // phone
              leading: const Icon(Icons.phone),
              title: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Phone'),
                controller: _phoneEditingController,
              ),
            ),

            ListTile(
              // email
              leading: const Icon(Icons.email),
              title: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
                controller: _emailEditingController,
              ),
            ),

            ListTile(
              // birthday
              leading: const Icon(Icons.today),
              title: const Text('Birthday'),
              subtitle: model.entryBeingEdited?.birthdayAsText,
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () async =>
                    model.pickBirthday(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog that lets the user choose an avatar
  /// from the device camera or the image gallery.
  Future<void> _selectAvatar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (Platform.isAndroid || Platform.isIOS)
                  InkWell(
                    onTap: () async => _takePicture(context),
                    child: const Text('Take a picture'),
                  ),
                if (!Platform.isAndroid && !Platform.isIOS)
                  InkWell(
                    onTap: null, // disable interaction
                    child: const Text(
                      'Take a picture (not available)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                const Divider(),

                InkWell(
                  child: const Text('Select From Gallery'),
                  onTap: () async => _pickImage(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Opens the device camera and, if an image is captured,
  /// saves it as the temporary avatar for the current contact.
  Future<void> _takePicture(BuildContext context) async {
    final model = context.read<ContactsModel>();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      await model.setAvatar(image);
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Opens the image gallery and, if an image is selected,
  /// saves it as the temporary avatar for the current contact.
  Future<void> _pickImage(BuildContext context) async {
    final model = context.read<ContactsModel>();
    final ImagePicker picker = ImagePicker();
    final XFile? galleryImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (galleryImage != null) {
      await model.setAvatar(galleryImage);
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Validates the form, saves the current contact entry,
  /// and displays a confirmation snack bar.
  Future<void> _save(BuildContext context, ContactsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await model.stopEditingEntry(save: true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Contact saved'),
        ),
      );
    }
  }
}

/// Adds or adapts model operations to Flutter/UI concepts.
extension _ContactsModelUIExtension on ContactsModel {

  /// Displays a date picker for the contact's birthday and,
  /// if a date is selected, updates the birthday of the
  /// contact currently being edited.
  Future<void> pickBirthday(BuildContext context) async {
    final contact = entryBeingEdited!;
    final date = await contact.pickDate(context, contact.birthday);
    if (date != null) {
      setBirthday(date);
    }
  }

}

/// Adds or adapts model operations to Flutter/UI concepts.
extension _ContactUIExtension on Contact {

  /// Returns the contact's birthday as a Flutter [Text] widget,
  /// or `null` if the contact has no birthday.
  Text? get birthdayAsText =>
      hasBirthday ? Text(formattedBirthday ?? '') : null;

  /// Shows a date picker, initially displaying [date] or the
  /// current date if [date] is `null`.
  Future<DateTime?> pickDate(BuildContext context, DateTime? date) {
    return showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }
}