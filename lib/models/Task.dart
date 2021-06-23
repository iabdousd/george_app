import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:stackedtasks/constants/feed.dart' as feed_constants;
import 'package:stackedtasks/constants/models/goal.dart';
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/goal_summary.dart';
import 'package:stackedtasks/repositories/feed/statistics.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';

import 'InboxItem.dart';
import 'Note.dart';

class Task extends InboxItem {
  String id;
  String userID;
  List<String> partnersIDs;
  List<String> to;
  String goalRef;
  String stackRef;
  String goalTitle;
  String stackTitle;
  TaskRepetition repetition;
  String title;
  String description;
  int status;
  int oldDueDatesCount;
  Duration oldDuration;
  bool anyTime;
  DateTime creationDate;
  List<DateTime> dueDates;
  List<DateTime> donesHistory;
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;

  String stackColor;

  bool notesFetched = false;
  List<Note> detailedTaskNotes = [];
  Note lastNote;

  String userName;
  String userPhoto;
  int likesCount;
  Stream<int> commentsCount;
  Stream<bool> isLiked;

  String taskPhoto;

  get taskID => id.contains('_') ? id.substring(0, id.length - 10) : id;

  Task({
    this.id,
    this.userID,
    this.partnersIDs: const [],
    this.goalRef,
    this.stackRef,
    this.goalTitle,
    this.stackTitle,
    this.stackColor,
    this.title,
    this.description,
    this.status,
    this.oldDueDatesCount,
    this.oldDuration,
    this.anyTime,
    TaskRepetition repetition,
    this.creationDate,
    this.dueDates,
    this.donesHistory,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.lastNote,
    this.taskPhoto,
  }) {
    if (task_constants.REPETITION_OPTIONS
        .contains(repetition?.type?.toLowerCase())) {
      this.repetition = repetition..type.toLowerCase();
      this.dueDates = [];
      DateTime nextDue = startDate;
      int i = 0;
      final now = DateTime.now();
      if (repetition?.type == 'daily') {
        dueDates.add(startDate);
      } else if (repetition?.type == 'monthly' &&
          repetition.dayNumber == now.day) {
        dueDates.add(startDate);
      } else if (repetition?.type == 'weekly' &&
          repetition.selectedWeekDays
              .contains(dateTimeToDayNumber(startDate))) {
        dueDates.add(startDate);
      }
      do {
        nextDue = getNextInstanceDate(after: nextDue);
        if (nextDue == null ||
            nextDue.year * 365 + nextDue.month * 30 + nextDue.day >
                endDate.year * 365 + endDate.month * 30 + endDate.day) {
          break;
        }

        dueDates.add(DateTime(nextDue.year, nextDue.month, nextDue.day));
        i++;
      } while (nextDue.isBefore(endDate) && i < 1000);
    } else {
      this.dueDates = [];
      dueDates.add(startDate);
      DateTime nextDue = startDate;
      do {
        nextDue = getNextInstanceDate(after: nextDue);
        if (nextDue == null ||
            nextDue.year * 365 + nextDue.month * 12 + nextDue.day >
                endDate.year * 365 + endDate.month * 12 + endDate.day) {
          break;
        }

        dueDates.add(DateTime(nextDue.year, nextDue.month, nextDue.day));
      } while (nextDue.year * 365 + nextDue.month * 12 + nextDue.day >
          endDate.year * 365 + endDate.month * 12 + endDate.day);
    }
  }

  Task.fromJson(
    Map<String, dynamic> jsonObject, {
    String id,
  }) {
    this.id = id;
    this.userID = jsonObject[task_constants.USER_ID_KEY];
    this.to = jsonObject[feed_constants.TO_KEY] == null
        ? []
        : List<String>.from(jsonObject[feed_constants.TO_KEY]);
    this.partnersIDs =
        List<String>.from(jsonObject[task_constants.PARTNERS_IDS_KEY]);
    this.goalRef = jsonObject[task_constants.GOAL_REF_KEY];
    this.stackRef = jsonObject[task_constants.STACK_REF_KEY];
    this.goalTitle = jsonObject[task_constants.GOAL_TITLE_KEY];
    this.stackTitle = jsonObject[task_constants.STACK_TITLE_KEY];
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
        jsonObject[task_constants.CREATION_DATE_KEY] is Timestamp
            ? (jsonObject[task_constants.CREATION_DATE_KEY] as Timestamp)
                .toDate()
                .toLocal()
            : DateTime.fromMillisecondsSinceEpoch(
                jsonObject[task_constants.CREATION_DATE_KEY]);

    if (jsonObject[task_constants.DONES_HISTORY_KEY] != null &&
        jsonObject[task_constants.DONES_HISTORY_KEY] is List)
      this.donesHistory =
          List<DateTime>.from(jsonObject[task_constants.DONES_HISTORY_KEY]
              .map(
                (e) => e is Timestamp
                    ? e.toDate().toLocal()
                    : DateTime.fromMillisecondsSinceEpoch(e),
              )
              .toList());
    else
      this.donesHistory = [];

    if (jsonObject[task_constants.DUE_DATES_KEY] != null &&
        jsonObject[task_constants.DUE_DATES_KEY] is List)
      this.dueDates =
          List<DateTime>.from(jsonObject[task_constants.DUE_DATES_KEY]
              .map(
                (e) => e is Timestamp
                    ? e.toDate().toLocal()
                    : DateTime.fromMillisecondsSinceEpoch(e),
              )
              .toList());
    else
      this.dueDates = [];

    this.startDate = jsonObject[task_constants.START_DATE_KEY] is Timestamp
        ? (jsonObject[task_constants.START_DATE_KEY] as Timestamp)
            .toDate()
            .toLocal()
        : DateTime.fromMillisecondsSinceEpoch(
            jsonObject[task_constants.START_DATE_KEY]);
    this.endDate = jsonObject[task_constants.END_DATE_KEY] is Timestamp
        ? (jsonObject[task_constants.END_DATE_KEY] as Timestamp)
            .toDate()
            .toLocal()
        : DateTime.fromMillisecondsSinceEpoch(
            jsonObject[task_constants.END_DATE_KEY]);
    this.startTime = jsonObject[task_constants.START_TIME_KEY] is Timestamp
        ? (jsonObject[task_constants.START_TIME_KEY] as Timestamp)
            .toDate()
            .toLocal()
        : DateTime.fromMillisecondsSinceEpoch(
            jsonObject[task_constants.START_TIME_KEY]);

    this.endTime = jsonObject[task_constants.END_TIME_KEY] is Timestamp
        ? (jsonObject[task_constants.END_TIME_KEY] as Timestamp)
            .toDate()
            .toLocal()
        : DateTime.fromMillisecondsSinceEpoch(
            jsonObject[task_constants.END_TIME_KEY]);

    this.lastNote = jsonObject[task_constants.LAST_NOTE_KEY] != null
        ? Note.fromJson(jsonObject[task_constants.LAST_NOTE_KEY])
        : null;

    this.likesCount = jsonObject[feed_constants.LIKES_COUNT_KEY] ?? 0;
    this.taskPhoto = jsonObject[feed_constants.TASK_PHOTO_KEY];
  }

  Map<String, dynamic> toJson() {
    return {
      task_constants.USER_ID_KEY: userID,
      task_constants.PARTNERS_IDS_KEY: partnersIDs,
      task_constants.GOAL_REF_KEY: goalRef,
      task_constants.STACK_REF_KEY: stackRef,
      if (goalTitle != null) task_constants.GOAL_TITLE_KEY: goalTitle,
      if (stackTitle != null) task_constants.STACK_TITLE_KEY: stackTitle,
      task_constants.STACK_COLOR_KEY: stackColor,
      task_constants.TITLE_KEY: title,
      task_constants.DESCRIPTION_KEY: description,
      task_constants.STATUS_KEY: status,
      task_constants.ANY_TIME_KEY: anyTime,
      task_constants.REPETITION_KEY:
          task_constants.REPETITION_OPTIONS.contains(repetition?.type)
              ? repetition.toJson()
              : null,
      task_constants.CREATION_DATE_KEY: creationDate.toUtc(),
      task_constants.DUE_DATES_KEY: dueDates?.map((e) => e.toUtc())?.toList(),
      task_constants.DONES_HISTORY_KEY: donesHistory,
      task_constants.START_DATE_KEY: startDate.toUtc(),
      task_constants.END_DATE_KEY: endDate.toUtc(),
      task_constants.START_TIME_KEY: startTime,
      task_constants.END_TIME_KEY: endTime,
      task_constants.LAST_NOTE_KEY: lastNote?.toJson(),
      feed_constants.TASK_PHOTO_KEY: taskPhoto,
    };
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  int get maxStreak {
    donesHistory.sort((a, b) => a.compareTo(b));
    // dueDates.sort((a, b) => a.compareTo(b));
    int streak = 0;
    int tempStreak = 0;
    int donesIndex = 0;
    for (int index = 0; index < dueDates.length; index++) {
      if (donesIndex == donesHistory.length) break;
      if (dueDates[index] == donesHistory[donesIndex]) {
        tempStreak++;
        donesIndex++;
      } else {
        tempStreak = 0;
      }
      if (tempStreak > streak) streak = tempStreak;
    }

    return streak;
  }

  double get completionPercent => this.dueDates.length > 0
      ? this.donesHistory.length / this.dueDates.length
      : 0;

  String get completionRate => this.dueDates.length > 0
      ? (100 * this.donesHistory.length / this.dueDates.length)
          .toStringAsFixed(0)
      : '0';

  bool isDone({DateTime date}) =>
      (repetition == null && status == 1) ||
      ((donesHistory ?? []).length > 0 &&
          donesHistory.contains(
            (date != null
                ? DateTime(date.year, date.month, date.day)
                : dueDates.firstWhere(
                    (element) => DateTime(
                      element.year,
                      element.month,
                      element.day,
                      endTime.hour,
                      endTime.minute,
                    ).isAfter(
                      DateTime.now(),
                    ),
                    orElse: () => donesHistory.last,
                  )),
          ));

  bool get hasNext => (repetition != null && status != 1);

  DateTime nextDueDate() {
    if (repetition?.type == null) {
      return status == 1
          ? null
          : DateTime.now().isAfter(startDate)
              ? DateTime.now().isBefore(endDate)
                  ? DateTime.now()
                  : endDate
              : startDate;
    }
    if (this.dueDates.length > 0) {
      for (DateTime due in this.dueDates) {
        if (!this.donesHistory.contains(due)) return due;
      }
    }
    return null;
  }

  Future<List> getAllPartners() async {
    List<String> allPartners = [...(partnersIDs ?? [])];
    if (stackRef != null && stackRef != 'inbox') {
      final stackRaw = await FirebaseFirestore.instance
          .collection(STACKS_KEY)
          .doc(stackRef)
          .get();
      if (stackRaw.exists && stackRaw.data() != null) {
        final stack = TasksStack.fromJson(
          stackRaw.data(),
          id: stackRaw.id,
        );
        allPartners.addAll(stack.partnersIDs);
      }
      if (goalRef != null && goalRef != 'inbox') {
        final goalRaw = await FirebaseFirestore.instance
            .collection(GOALS_KEY)
            .doc(goalRef)
            .get();
        final goal = Goal.fromJson(
          goalRaw.data(),
          id: goalRaw.id,
        );
        allPartners.addAll(goal.partnersIDs);
      }
    }
    return allPartners;
  }

  accomplish({DateTime customDate, bool unChecking: false}) async {
    if (repetition == null) {
      if (status == 1) {
        status = 0;
        await save(
          updateSummaries: false,
        );
        await FirebaseFirestore.instance
            .collection(feed_constants.FEED_KEY)
            .doc(
              id + DateFormat('yyyy_MM_dd').format(startDate),
            )
            .delete();
        // TODO: !
        if (stackRef != 'inbox' && goalRef != 'inbox') {
          await removeTaskAccomplishment(this);
          if (stackRef != 'inbox' && goalRef != 'inbox')
            await GoalSummary(id: goalRef).accomplishTask(
              -1,
              stackRef,
              withFetch: true,
            );
        }
      } else {
        status = 1;
        await save(
          updateSummaries: false,
        );
        List<String> allPartners = await getAllPartners();

        await saveAsFeed(
          [getCurrentUser().uid, ...allPartners],
          tryUpdate: false,
          customID: this.id + DateFormat('yyyy_MM_dd').format(startDate),
        );
        if (stackRef != 'inbox' && goalRef != 'inbox') {
          await addTaskAccomplishment(this);
          await GoalSummary(id: goalRef).accomplishTask(
            1,
            stackRef,
            withFetch: true,
          );
        }
      }
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
      // UNCHECKED!
      if (this.donesHistory.length == this.dueDates.length) this.status = 0;
      this.donesHistory.remove(accompishedDate);
      await save(
        updateSummaries: false,
      );
      await FirebaseFirestore.instance
          .collection(feed_constants.FEED_KEY)
          .doc(
            id + DateFormat('yyyy_MM_dd').format(accompishedDate),
          )
          .delete();
      // TODO: !
      if (stackRef != 'inbox' && goalRef != 'inbox') {
        await removeTaskAccomplishment(this);
        await GoalSummary(id: goalRef)
            .accomplishTask(-1, stackRef, withFetch: true);
      }
    } else {
      // CHECKED!
      this.donesHistory.add(accompishedDate);
      if (this.donesHistory.length == this.dueDates.length) this.status = 1;
      await save(
        updateSummaries: false,
      );
      List<String> allPartners = await getAllPartners();
      await saveAsFeed(
        [getCurrentUser().uid, ...allPartners],
        tryUpdate: false,
        customID: this.id + DateFormat('yyyy_MM_dd').format(accompishedDate),
      );

      if (stackRef != 'inbox' && goalRef != 'inbox') {
        await addTaskAccomplishment(this);
        await GoalSummary(id: goalRef)
            .accomplishTask(1, stackRef, withFetch: true);
      }
    }
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
    return weekDays[DateFormat('E').format(dateTime)];
  }

  DateTime getNextInstanceDate({DateTime after}) {
    DateTime now = after ?? DateTime.now();
    if (repetition == null || repetition.type == 'daily') {
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
      DateUtil util = DateUtil();
      while (forced ||
          (now.isAfter(next) ||
                  now.year * 365 +
                          now.month * util.daysInMonth(now.month, now.year) +
                          now.day ==
                      next.year * 365 +
                          next.month * util.daysInMonth(next.month, next.year) +
                          next.day) &&
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

  Future<void> updateSummary() async {
    if (goalRef == 'inbox') {
      // TODO:
      return;
    }
    await GoalSummary(id: goalRef).addTasks(
      task_constants.REPETITION_OPTIONS
              .contains(this.repetition?.type?.toLowerCase())
          ? this.dueDates.length
          : 1,
      endTime.difference(startTime).abs(),
      stackRef,
      withFetch: true,
    );
  }

  Future save({bool updateSummaries: true}) async {
    assert(goalRef != null && stackRef != null);
    if (anyTime) {
      startTime = DateTime.fromMillisecondsSinceEpoch(0).add(
        Duration(hours: 23),
      );
      endTime = DateTime.fromMillisecondsSinceEpoch(0).add(
        Duration(hours: 23, minutes: 59),
      );
    }
    if (id == null) {
      DocumentReference<Map<String, dynamic>> docRef = await FirebaseFirestore
          .instance
          .collection(stack_constants.TASKS_KEY)
          .add(toJson());

      this.id = docRef.id;

      if (updateSummaries) await updateSummary();
    } else {
      DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore
          .instance
          .collection(stack_constants.TASKS_KEY)
          .doc(id);
      await docRef.update(toJson());

      if (updateSummaries) await updateSummary();
    }
  }

  Future delete() async {
    await FirebaseFirestore.instance
        .collection(stack_constants.TASKS_KEY)
        .doc(id)
        .delete();

    if (stackRef == 'inbox') {
      await InboxRepository.deleteInboxItem(id);
    }

    // TODO:
    if (stackRef != 'inbox' && goalRef != 'inbox')
      await GoalSummary(id: goalRef).deleteTask(
        this.dueDates.length,
        repetition == null
            ? status == 1
                ? 1
                : 0
            : this.donesHistory.length,
        endTime.difference(startTime).abs(),
        stackRef,
        withFetch: true,
      );
  }

  Future saveAsFeed(
    List<String> to, {
    bool tryUpdate: true,
    String customID,
  }) async {
    try {
      if (tryUpdate)
        await FirebaseFirestore.instance
            .collection(feed_constants.FEED_KEY)
            .doc(
              customID ?? id,
            )
            .update({
          task_constants.TITLE_KEY: title,
          task_constants.DESCRIPTION_KEY: description,
          feed_constants.TO_KEY: [getCurrentUser().uid, ...to],
          task_constants.STATUS_KEY: status,
        });
      else {
        await FirebaseFirestore.instance
            .collection(feed_constants.FEED_KEY)
            .doc(
              customID ?? id,
            )
            .set({
          task_constants.TITLE_KEY: title,
          task_constants.DESCRIPTION_KEY: description,
          feed_constants.TO_KEY: [getCurrentUser().uid, ...to],
          task_constants.CREATION_DATE_KEY: DateTime.now(),
          ...toJson(),
        });
      }
    } catch (e) {
      await FirebaseFirestore.instance
          .collection(feed_constants.FEED_KEY)
          .doc(
            id,
          )
          .set({
        task_constants.TITLE_KEY: title,
        task_constants.DESCRIPTION_KEY: description,
        feed_constants.TO_KEY: [getCurrentUser().uid, ...to],
        task_constants.CREATION_DATE_KEY: DateTime.now(),
        ...toJson(),
      });
    }
  }

  Future deleteAsFeed() async {
    await FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .doc(
          id,
        )
        .delete();
  }

  Task copyWith({
    String id,
    String userID,
    List<String> partnersIDs,
    String goalRef,
    String stackRef,
    String goalTitle,
    String stackTitle,
    List<String> taskNotes,
    String title,
    String description,
    int status,
    int oldDueDatesCount,
    Duration oldDuration,
    bool anyTime,
    DateTime creationDate,
    List<DateTime> dueDates,
    List<DateTime> donesHistory,
    DateTime startDate,
    DateTime endDate,
    DateTime startTime,
    DateTime endTime,
    String stackColor,
    bool notesFetched,
    List<Note> detailedTaskNotes,
    Note lastNote,
    String userName,
    String userPhoto,
    String taskPhoto,
  }) {
    return Task(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      partnersIDs: partnersIDs ?? this.partnersIDs,
      goalRef: goalRef ?? this.goalRef,
      stackRef: stackRef ?? this.stackRef,
      goalTitle: goalTitle ?? this.goalTitle,
      stackTitle: stackTitle ?? this.stackTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      oldDueDatesCount: oldDueDatesCount ?? this.oldDueDatesCount,
      oldDuration: oldDuration ?? this.oldDuration,
      anyTime: anyTime ?? this.anyTime,
      creationDate: creationDate ?? this.creationDate,
      dueDates: dueDates ?? this.dueDates,
      donesHistory: donesHistory ?? this.donesHistory,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stackColor: stackColor ?? this.stackColor,
      lastNote: lastNote ?? this.lastNote,
      taskPhoto: taskPhoto ?? this.taskPhoto,
    );
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
