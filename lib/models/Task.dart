import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/services/user/user_service.dart';
import 'package:intl/intl.dart';

class Task {
  String id;
  String goalRef;
  String stackRef;
  TaskRepetition repetition;
  String title;
  String description;
  int status;
  bool anyTime;
  DateTime creationDate;
  List<DateTime> dueDates;
  List<DateTime> donesHistory;
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;

  String stackColor;

  Task({
    this.id,
    this.goalRef,
    this.stackRef,
    this.stackColor,
    this.title,
    this.description,
    this.status,
    this.anyTime,
    TaskRepetition repetition,
    this.creationDate,
    this.dueDates,
    this.donesHistory,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  }) {
    if (task_constants.REPETITION_OPTIONS.contains(repetition?.type)) {
      this.repetition = repetition;
      this.dueDates = [];
      DateTime nextDue =
          DateTime.now().isAfter(startDate) ? DateTime.now() : startDate;
      int i = 0;
      if (repetition?.type == 'daily' && DateTime.now().isBefore(startDate))
        dueDates.add(startDate);
      do {
        nextDue = getNextInstanceDate(after: nextDue);
        if (nextDue == null || nextDue.isAfter(endDate)) break;

        dueDates.add(DateTime(nextDue.year, nextDue.month, nextDue.day));
        i++;
      } while (nextDue.isBefore(endDate) && i < 50);
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
    this.anyTime = jsonObject[task_constants.ANY_TIME_KEY];
    if (jsonObject[task_constants.REPETITION_KEY] != null &&
        task_constants.REPETITION_OPTIONS.contains(
            jsonObject[task_constants.REPETITION_KEY]
                [task_constants.REPETITION_TYPE_KEY]))
      this.repetition =
          TaskRepetition.fromJson(jsonObject[task_constants.REPETITION_KEY]);

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
    this.startTime =
        (jsonObject[task_constants.START_TIME_KEY] as Timestamp).toDate();
    this.endTime =
        (jsonObject[task_constants.END_TIME_KEY] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      task_constants.GOAL_REF_KEY: goalRef,
      task_constants.STACK_REF_KEY: stackRef,
      task_constants.STACK_COLOR_KEY: stackColor,
      task_constants.TITLE_KEY: title,
      task_constants.DESCRIPTION_KEY: description,
      task_constants.STATUS_KEY: status,
      task_constants.ANY_TIME_KEY: anyTime,
      task_constants.REPETITION_KEY:
          task_constants.REPETITION_OPTIONS.contains(repetition?.type)
              ? repetition.toJson()
              : null,
      task_constants.CREATION_DATE_KEY: creationDate,
      task_constants.DUE_DATES_KEY: dueDates,
      task_constants.DONES_HISTORY_KEY: donesHistory,
      task_constants.START_DATE_KEY: startDate,
      task_constants.END_DATE_KEY: endDate,
      task_constants.START_TIME_KEY: startTime,
      task_constants.END_TIME_KEY: endTime,
    };
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  bool isDone({DateTime date}) =>
      (repetition == null && status == 1) ||
      ((donesHistory ?? []).length > 0 &&
          donesHistory.contains(
            DateTime(
                (date ??
                        dueDates.firstWhere(
                            (element) => element.isAfter(DateTime.now())))
                    .year,
                (date ??
                        dueDates.firstWhere(
                            (element) => element.isAfter(DateTime.now())))
                    .month,
                (date ??
                        dueDates.firstWhere(
                            (element) => element.isAfter(DateTime.now())))
                    .day),
          ));

  bool get hasNext => (repetition != null && status != 1);

  DateTime nextDueDate() {
    if (repetition?.type == null) {
      return status == 1
          ? null
          : DateTime.now().isAfter(startDate)
              ? DateTime.now()
              : startDate;
    }
    if (this.dueDates.length > 0) {
      // print('donesHistory: ${this.donesHistory}');
      // print('dueDates: ${this.dueDates}');
      for (DateTime due in this.dueDates) {
        if (!this.donesHistory.contains(due) && due.isAfter(DateTime.now()))
          return due;
      }
    }
    return null;
  }

  accomplish({DateTime customDate, bool unChecking: false}) async {
    if (repetition == null) {
      status = status == 1 ? 0 : 1;
      await save();
      return;
    }
    if (this.donesHistory == null) this.donesHistory = [];
    DateTime now =
        customDate ?? (unChecking ? this.donesHistory.last : nextDueDate());

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

  int dateTimeToDayNumber(DateTime dateTime) {
    Map<String, int> weekDays = {
      'Mon': 0,
      'Tue': 1,
      'Wed': 2,
      'Thu': 3,
      'Fri': 4,
      'Sat': 5,
      'Sun': 6,
    };
    // print(DateFormat('E').format(dateTime));
    return weekDays[DateFormat('E').format(dateTime)];
  }

  DateTime getNextInstanceDate({DateTime after}) {
    DateTime now = after ?? DateTime.now();

    if (repetition == null) {
      return null;
      //  DateTime(
      //   endDate.year,
      //   endDate.month,
      //   endDate.day,
      //   startTime.hour,
      //   startTime.minute,
      // );
    } else if (repetition.type == 'daily') {
      return DateTime(
        now.year,
        now.month,
        now.day + 1,
        startTime.hour,
        startTime.minute,
      );
    } else if (repetition.type == 'weekly') {
      bool forced = false;
      DateTime next = DateTime(
        startDate.year,
        startDate.month,
        startDate.day -
            dateTimeToDayNumber(startDate) +
            repetition.selectedWeekDays.firstWhere(
              (element) => DateTime(now.year, now.month, now.day).isBefore(
                DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day - dateTimeToDayNumber(startDate) + element,
                ),
              ),
              orElse: () {
                forced = true;
                return repetition.weeksCount * 7;
              },
            ),
        startTime.hour,
        startTime.minute,
      );
      int i = 0;
      while (forced ||
          (now.isAfter(next) ||
                  now.year * 365 + now.month * 30 + now.day ==
                      next.year * 365 + next.month * 30 + next.day) &&
              i < 50) {
        i++;
        forced = false;
        next = DateTime(
          next.year,
          next.month,
          next.day +
              repetition.selectedWeekDays.firstWhere(
                (element) => DateTime(now.year, now.month, now.day).isBefore(
                  DateTime(
                    next.year,
                    next.month,
                    next.day + element,
                  ),
                ),
                orElse: () {
                  forced = true;
                  return repetition.weeksCount * 7;
                },
              ),
          startTime.hour,
          startTime.minute,
        );
      }
      if (i >= 49) print(i);
      return next;
    } else if (repetition.type == 'monthly') {
      if (now.month % repetition.monthsCount == 0 &&
          now.day + now.hour / 24 + now.minute / (24 * 60) <
              repetition.dayNumber +
                  startTime.hour / 24 +
                  startTime.minute / (24 * 60))
        return DateTime(
          now.year,
          now.month,
          repetition.dayNumber,
          startTime.hour,
          startTime.minute,
        );

      DateTime next = DateTime(
        now.year,
        now.month - now.month % repetition.monthsCount + repetition.monthsCount,
        repetition.dayNumber,
        startTime.hour,
        startTime.minute,
      );

      while (next.isBefore(now))
        next = DateTime(
          next.year,
          next.month -
              next.month % repetition.monthsCount +
              repetition.monthsCount,
          repetition.dayNumber,
          startTime.hour,
          startTime.minute,
        );
      return next;
    }

    return null;
  }

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

class TaskRepetition {
  String type;

  // WEEKLY
  int weeksCount;
  List<int> selectedWeekDays;

  // MONTHLY
  int monthsCount;
  int dayNumber;

  TaskRepetition({
    this.type,
    this.weeksCount,
    List<int> selectedWeekDays,
    this.dayNumber,
    this.monthsCount,
  }) {
    if (selectedWeekDays != null) {
      this.selectedWeekDays = selectedWeekDays..sort((a, b) => a.compareTo(b));
    }
  }

  TaskRepetition.fromJson(jsonObject) {
    this.type = jsonObject[task_constants.REPETITION_TYPE_KEY];
    this.weeksCount = jsonObject[task_constants.REPETITION_WEEKS_COUNT_KEY];
    this.selectedWeekDays =
        List<int>.from(jsonObject[task_constants.REPETITION_WEEK_DAYS_KEY]) ??
            [];
    this.dayNumber = jsonObject[task_constants.REPETITION_DAY_NUMBER_KEY];
    this.monthsCount = jsonObject[task_constants.REPETITION_MONTHS_COUNT_KEY];
  }

  Map<String, dynamic> toJson() {
    return {
      task_constants.REPETITION_TYPE_KEY: type,
      task_constants.REPETITION_WEEKS_COUNT_KEY: weeksCount,
      task_constants.REPETITION_WEEK_DAYS_KEY: selectedWeekDays,
      task_constants.REPETITION_DAY_NUMBER_KEY: dayNumber,
      task_constants.REPETITION_MONTHS_COUNT_KEY: monthsCount,
    };
  }
}
