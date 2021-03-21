import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/services/user/user_service.dart';

class Task {
  String id;
  String goalRef;
  String stackRef;
  String title;
  String description;
  int status;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  Task({
    this.id,
    this.goalRef,
    this.stackRef,
    this.title,
    this.description,
    this.status,
    this.creationDate,
    this.startDate,
    this.endDate,
  });

  Task.fromJson(Map<String, dynamic> jsonObject) {
    this.title = jsonObject[task_constants.TITLE_KEY];
    this.description = jsonObject[task_constants.DESCRIPTION_KEY];
    this.status = jsonObject[task_constants.STATUS_KEY];
    this.creationDate =
        (jsonObject[task_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.startDate =
        (jsonObject[task_constants.START_DATE_KEY] as Timestamp).toDate();
    this.endDate =
        (jsonObject[task_constants.END_DATE_KEY] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      task_constants.TITLE_KEY: title,
      task_constants.DESCRIPTION_KEY: description,
      task_constants.STATUS_KEY: status,
      task_constants.CREATION_DATE_KEY: creationDate,
      task_constants.START_DATE_KEY: startDate,
      task_constants.END_DATE_KEY: endDate,
    };
  }

  Future save() async {
    assert(goalRef != null && stackRef != null);
    if (id == null) {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.TASKS_KEY)
          .add(toJson());
    } else {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.TASKS_KEY)
          .doc(id)
          .update(toJson());
    }
  }

  Future delete() async {
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(goalRef)
        .collection(goal_constants.STACKS_KEY)
        .doc(stackRef)
        .collection(stack_constants.TASKS_KEY)
        .doc(id)
        .delete();
  }
}
