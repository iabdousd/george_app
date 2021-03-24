import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/services/user/user_service.dart';

class Task {
  String id;
  String goalRef;
  String stackRef;
  String repetition;
  String title;
  String description;
  int status;
  DateTime creationDate;
  List<DateTime> dueDates;
  List<DateTime> donesHistory;
  DateTime startDate;
  DateTime endDate;

  String stackColor;

  Task({
    this.id,
    this.goalRef,
    this.stackRef,
    this.stackColor,
    this.title,
    this.description,
    this.status,
    repetition,
    this.creationDate,
    this.dueDates,
    this.donesHistory,
    this.startDate,
    this.endDate,
  }) {
    if (task_constants.REPETITION_OPTIONS.contains(repetition)) {
      this.repetition = repetition;
      this.dueDates = [];
      DateTime nextDue = startDate;
      while (nextDue.isBefore(endDate)) {
        dueDates.add(DateTime(nextDue.year, nextDue.month, nextDue.day));
        nextDue = getNextInstanceDate(after: nextDue);
      }
    }
  }

  Task.fromJson(
    Map<String, dynamic> jsonObject, {
    String id,
  }) {
    this.id = id;
    this.goalRef = jsonObject[task_constants.GOAL_REF_KEY];
    this.stackRef = jsonObject[task_constants.STACK_REF_KEY];
    this.stackColor = jsonObject[task_constants.STACK_COLOR_KEY];
    this.title = jsonObject[task_constants.TITLE_KEY];
    this.description = jsonObject[task_constants.DESCRIPTION_KEY];

    this.status = jsonObject[task_constants.STATUS_KEY];
    if (task_constants.REPETITION_OPTIONS
        .contains(jsonObject[task_constants.REPETITION_KEY]))
      this.repetition = jsonObject[task_constants.REPETITION_KEY];

    this.creationDate =
        (jsonObject[task_constants.CREATION_DATE_KEY] as Timestamp).toDate();

    if (jsonObject[task_constants.DONES_HISTORY_KEY] != null &&
        jsonObject[task_constants.DONES_HISTORY_KEY] is List)
      this.donesHistory = List<DateTime>.from(
          jsonObject[task_constants.DONES_HISTORY_KEY]
              .map((e) => (e as Timestamp).toDate())
              .toList());
    else
      this.donesHistory = [];

    if (jsonObject[task_constants.DUE_DATES_KEY] != null &&
        jsonObject[task_constants.DUE_DATES_KEY] is List)
      this.dueDates = List<DateTime>.from(
          jsonObject[task_constants.DUE_DATES_KEY]
              .map((e) => (e as Timestamp).toDate())
              .toList());
    else
      this.dueDates = [];

    this.startDate =
        (jsonObject[task_constants.START_DATE_KEY] as Timestamp).toDate();
    this.endDate =
        (jsonObject[task_constants.END_DATE_KEY] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      task_constants.GOAL_REF_KEY: goalRef,
      task_constants.STACK_REF_KEY: stackRef,
      task_constants.STACK_COLOR_KEY: stackColor,
      task_constants.TITLE_KEY: title,
      task_constants.DESCRIPTION_KEY: description,
      task_constants.STATUS_KEY: status,
      task_constants.REPETITION_KEY:
          task_constants.REPETITION_OPTIONS.contains(repetition)
              ? repetition
              : null,
      task_constants.CREATION_DATE_KEY: creationDate,
      task_constants.DUE_DATES_KEY: dueDates,
      task_constants.DONES_HISTORY_KEY: donesHistory,
      task_constants.START_DATE_KEY: startDate,
      task_constants.END_DATE_KEY: endDate,
    };
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  bool isDone({DateTime date}) =>
      (repetition == null && status == 1) ||
      ((donesHistory ?? []).length > 0 &&
          donesHistory.contains(
            DateTime((date ?? DateTime.now()).year,
                (date ?? DateTime.now()).month, (date ?? DateTime.now()).day),
          ));

  bool get hasNext => (repetition != null && status != 1);

  DateTime nextDueDate() {
    if (this.dueDates.length > 0) {
      print(this.donesHistory);
      for (DateTime due in this.dueDates) {
        if (!this.donesHistory.contains(due)) return due;
      }
    }
    return this.endDate;
  }

  accomplish({DateTime customDate}) async {
    if (repetition == null) {
      status = status == 1 ? 0 : 1;
      await save();
      return;
    }
    DateTime now = customDate ?? DateTime.now();
    if (this.donesHistory == null) this.donesHistory = [];

    DateTime accompishedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (this.donesHistory.contains(accompishedDate)) {
      if (this.donesHistory.length == this.dueDates.length) this.status = 0;
      this.donesHistory.remove(accompishedDate);
    } else {
      this.donesHistory.add(accompishedDate);
      if (this.donesHistory.length == this.dueDates.length) this.status = 1;
    }
    await save();
  }

  DateTime getNextInstanceDate({DateTime after}) {
    DateTime now = after ?? DateTime.now();

    if (repetition == 'daily') {
      return DateTime(
        now.year,
        now.month,
        now.day + 1,
        startDate.hour,
        startDate.minute,
      );
    } else if (repetition == 'weekly') {
      DateTime next = DateTime(
        now.year,
        now.month,
        now.day + 7,
        startDate.hour,
        startDate.minute,
      );
      return next;
    } else if (repetition == 'monthly')
      return DateTime(
        now.year,
        now.month <= startDate.month ? now.month : now.month + 1,
        startDate.day,
        startDate.hour,
        startDate.minute,
      );

    return startDate;
  }

  bool get done => status == 1;

  Future save() async {
    assert(goalRef != null && stackRef != null);
    if (id == null) {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.TASKS_KEY)
          .add(toJson());
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(stack_constants.TASKS_KEY)
          .doc(docRef.id)
          .set(toJson());
    } else {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.TASKS_KEY)
          .doc(id);

      await docRef.set(toJson());
      DocumentReference standAloneDocRef = FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(stack_constants.TASKS_KEY)
          .doc(id);
      await standAloneDocRef.set(toJson());
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
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(stack_constants.TASKS_KEY)
        .doc(id)
        .delete();
  }
}
