import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;

import '../constants/models/task.dart';
import 'InboxItem.dart';
import 'Note.dart';
import 'Task.dart';
import 'goal_summary.dart';

class TasksStack extends InboxItem {
  String id;
  String goalRef;
  String goalTitle;
  String title;
  String color;
  int status;
  DateTime creationDate;

  List<Task> tasks;
  List<String> tasksKeys;
  List<Note> notes;

  TasksStack({
    this.id,
    this.goalRef,
    this.goalTitle,
    this.title,
    this.color,
    this.status = 0,
    this.creationDate,
    this.tasks,
    this.tasksKeys,
  });

  TasksStack.fromJson(
    Map<String, dynamic> jsonObject, {
    String goalRef,
    String goalTitle,
    String id,
  }) {
    this.id = id;
    this.goalRef = goalRef;
    this.goalTitle = goalTitle;
    this.title = jsonObject[stack_constants.TITLE_KEY];
    this.color = jsonObject[stack_constants.COLOR_KEY];
    this.status = jsonObject[stack_constants.STATUS_KEY];
    this.creationDate =
        (jsonObject[stack_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.tasksKeys = jsonObject[stack_constants.TASKS_KEYS_KEY];
  }

  Map<String, dynamic> toJson() {
    return {
      stack_constants.TITLE_KEY: title,
      stack_constants.COLOR_KEY: color,
      stack_constants.STATUS_KEY: status,
      stack_constants.CREATION_DATE_KEY: creationDate,
      stack_constants.TASKS_KEYS_KEY: tasksKeys,
    };
  }

  Future<void> updateSummary() async {
    if (goalRef == 'inbox') {
      // TODO:
    } else
      await GoalSummary(id: goalRef).addStack(
        this,
        withFetch: true,
      );
  }

  Future save({
    bool updateSummaries: true,
  }) async {
    assert(goalRef != null);

    if (id == null) {
      DocumentReference documentReference = await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .add(toJson());

      id = documentReference.id;
      if (updateSummaries) await updateSummary();
    } else {
      try {
        await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .doc(goalRef)
            .collection(goal_constants.STACKS_KEY)
            .doc(id)
            .update(toJson());
      } on FirebaseException {
        await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .doc(goalRef)
            .collection(goal_constants.STACKS_KEY)
            .doc(id)
            .set(toJson());
      }
      if (updateSummaries) await updateSummary();
    }
  }

  Future delete() async {
    assert(id != null);
    DocumentReference reference = goalRef == 'inbox'
        ? FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(INBOX_COLLECTION)
            .doc(id)
        : FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .doc(goalRef)
            .collection(goal_constants.STACKS_KEY)
            .doc(id);

    final tasks = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(stack_constants.TASKS_KEY)
        .where(STACK_REF_KEY, isEqualTo: id)
        .get();

    for (final task in tasks.docs) await task.reference.delete();

    await reference.delete();
    // TODO: FIX INBOX ONES
    if (goalRef != null && goalRef != 'inbox')
      await GoalSummary(id: goalRef).deleteStack(
        this,
        withFetch: true,
      );
  }
}
