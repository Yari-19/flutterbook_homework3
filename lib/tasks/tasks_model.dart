import '../base_model.dart';
import 'tasks_db_worker.dart';

class TasksModel extends BaseModel<Task> {
  TasksModel() : super(TasksDBWorker.db);

  Future<void> updateEntry(Task task) async {
    await database.update(task);
    loadData(notify: true);
  }

  void setDueDate(DateTime dueDate) {
    assert(entryBeingEdited != null);
    entryBeingEdited!.dueDate = dueDate;
    notifyListeners();
  }

}

class Task extends Entry with DateMixin {
  String? description;
  bool completed = false;

  Task({
    super.id = Entry.noId,
    this.description,
    DateTime? dueDate,
    this.completed = false,
  }) {
    date = dueDate;
  }

  // better names for properties inherited from DateEntry mixin.
  bool get hasDueDate => hasDate;
  DateTime? get dueDate => date;
  set dueDate(DateTime? dueDate) => date = dueDate;
  int? get dueDateInUnix => dateInUnix;
  set dueDateInUnix(int? millis) => dateInUnix = millis;
  String? get formattedDueDate => formattedDate;

  @override
  String toString() =>
      '{id=$id, description=$description, '
      'dueDate=$dueDate, completed=$completed }';
}
