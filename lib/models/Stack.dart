import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

import '../constants/models/task.dart';
import 'InboxItem.dart';
import 'Note.dart';
import 'Task.dart';
import 'goal_summary.dart';

class TasksStack extends InboxItem {
  String id;
  String userID;
  List<String> partnersIDs;
  String goalRef;
  String goalTitle;
  String title;
  String color;
  int status;
  DateTime creationDate;

  List<Task> tasks;
  List<Note> notes;

  TasksStack({
    this.id,
    this.userID,
    this.partnersIDs: const [],
    this.goalRef,
    this.goalTitle,
    this.title,
    this.color,
    this.status = 0,
    this.creationDate,
    this.tasks,
  });

  TasksStack.fromJson(
    Map<String, dynamic> jsonObject, {
    String goalRef,
    String goalTitle,
    String id,
  }) {
    this.id = id;
    this.userID = jsonObject[stack_constants.USER_ID_KEY];
    this.partnersIDs =
        List<String>.from(jsonObject[stack_constants.PARTNERS_IDS_KEY]);
    this.goalRef = goalRef ?? jsonObject[stack_constants.GOAL_REF_KEY];
    this.goalTitle = goalTitle;
    this.title = jsonObject[stack_constants.TITLE_KEY];
    this.color = jsonObject[stack_constants.COLOR_KEY];
    this.status = jsonObject[stack_constants.STATUS_KEY];
    this.creationDate =
        (jsonObject[stack_constants.CREATION_DATE_KEY] as Timestamp)
            .toDate()
            .toLocal();
  }

  Map<String, dynamic> toJson() {
    return {
      stack_constants.USER_ID_KEY: userID,
      stack_constants.PARTNERS_IDS_KEY: partnersIDs,
      stack_constants.TITLE_KEY: title,
      stack_constants.GOAL_REF_KEY: goalRef,
      stack_constants.COLOR_KEY: color,
      stack_constants.STATUS_KEY: status,
      stack_constants.CREATION_DATE_KEY: creationDate.toUtc(),
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
          .collection(goal_constants.STACKS_KEY)
          .add(toJson());

      id = documentReference.id;
      if (updateSummaries) await updateSummary();
    } else {
      try {
        await FirebaseFirestore.instance
            .collection(goal_constants.STACKS_KEY)
            .doc(id)
            .update(toJson());
      } on FirebaseException {
        await FirebaseFirestore.instance
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
        ? FirebaseFirestore.instance.collection(INBOX_COLLECTION).doc(id)
        : FirebaseFirestore.instance
            .collection(goal_constants.STACKS_KEY)
            .doc(id);

    final tasks = await FirebaseFirestore.instance
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

  TasksStack copyWith({
    String id,
    String goalRef,
    String goalTitle,
    String title,
    String color,
    int status,
    DateTime creationDate,
    List<Task> tasks,
    List<String> partnersIDs,
  }) {
    return TasksStack(
      id: id ?? this.id,
      goalRef: goalRef ?? this.goalRef,
      goalTitle: goalTitle ?? this.goalTitle,
      title: title ?? this.title,
      color: color ?? this.color,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      tasks: tasks ?? this.tasks,
      partnersIDs: partnersIDs ?? this.partnersIDs,
    );
  }
}
