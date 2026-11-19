import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'contacts_db_worker.dart';
import "../base_model.dart";

class ContactsModel extends BaseModel<Contact> with Avatar<Contact> {
  ContactsModel() : super(ContactsDBWorker.db);

  Future<void> setAvatar(XFile image) async {
    await File(image.path).copy(avatarTempFileName());
    notifyListeners();
  }

  void setBirthday(DateTime date) {
    entryBeingEdited!.birthday = date;
    notifyListeners();
  }

  /// Starts editing the specified contact by navigating to the edit screen.
  /// If no contact is specified, a new contract is created.
  @override
  void startEditingEntry(Contact entry) {
    deleteAvatarTempFile();
    super.startEditingEntry(entry);
  }

  /// Stops editing the current contact by navigating to the list screen.
  @override
  Future<int?> stopEditingEntry({bool save = false, bool notify = true}) async {
    var id = await super.stopEditingEntry(save: save, notify: false);
    // remove or rename temp avatar file.
    if (save) {
      assert(id != null);
      renameAvatarTempFile(id!);
    } else {
      deleteAvatarTempFile();
    }
    if (notify) {
      notifyListeners();
    }
    return id;
  }
}

class Contact extends Entry with DateMixin {
  String? name;
  String? phone;
  String? email;

  Contact({
    super.id = Entry.noId,
    this.name,
    this.phone,
    this.email,
    DateTime? birthday,
  }) {
    date = birthday;
  }

  // better names for properties inherited from DateEntry mixin.
  bool get hasBirthday => hasDate;
  DateTime? get birthday => date;
  set birthday(DateTime? birthday) => date = birthday;
  int? get birthdayInUnix => dateInUnix;
  set birthdayInUnix(int? millis) => dateInUnix = millis;
  String? get formattedBirthday => formattedDate;

  @override
  String toString() =>
      '{id=$id, name=$name, phone=$phone, email=$email, '
      'birthday=$birthday}';
}

/// A mixin to manage avatar-related file operations.
/// Provides utility methods for generating temporary and
/// user-specific avatar file names in a platform-neutral manner.
/// The directory for storing avatar files must be set via
/// the static `avatarDir` property before usage.
///
mixin Avatar<T extends Entry> on BaseModel<T> {
  static late Directory avatarDir;

  File avatarTempFile() {
    return File(avatarTempFileName());
  }

  String avatarTempFileName() {
    return path.join(avatarDir.path, 'avatar');
  }

  String avatarFileName(int id) {
    return path.join(avatarDir.path, id.toString());
  }

  void renameAvatarTempFile(int id) {
    File avatarFile = avatarTempFile();
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(avatarFileName(id));
    }
  }

  void deleteAvatarTempFile() {
    File avatarFile = avatarTempFile();
    if (avatarFile.existsSync()) {
      avatarFile.deleteSync();
    }
  }

  File avatarFile() {
    File avatarFile = avatarTempFile();
    if (!avatarFile.existsSync() &&
        entryBeingEdited != null &&
        !entryBeingEdited!.isNew) {
      avatarFile = File(avatarFileName(entryBeingEdited!.id));
    }
    return avatarFile;
  }
}
