import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/stack_summary.dart';
import 'package:stackedtasks/constants/models/goal_summary.dart'
    as goal_summary_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/feed.dart' as feed_constants;
import 'package:stackedtasks/services/user/user_service.dart';

import 'Stack.dart';

class GoalSummary {
  String id;
  String title;
  String color;
  int status;
  int tasksTotal;
  int tasksAccomlished;
  DateTime creationDate;
  Duration allocatedTime;
  List<StackSummary> stacksSummaries;

  GoalSummary({
    this.id,
    this.title,
    this.color,
    this.status,
    this.tasksTotal,
    this.tasksAccomlished,
    this.creationDate,
    this.allocatedTime,
    this.stacksSummaries,
  });

  GoalSummary.fromJson(
    jsonObject, {
    id,
  }) {
    this.id = id;
    this.title = jsonObject[goal_summary_constants.TITLE_KEY];
    this.color = jsonObject[goal_summary_constants.COLOR_KEY];
    this.status = jsonObject[goal_summary_constants.STATUS_KEY];
    this.tasksTotal = jsonObject[goal_summary_constants.TASKS_TOTAL_KEY];
    this.tasksAccomlished =
        jsonObject[goal_summary_constants.TASKS_ACCOMPLISHED_KEY];
    this.creationDate =
        jsonObject[goal_summary_constants.CREATION_DATE_KEY].toDate();
    this.allocatedTime = Duration(
        milliseconds: jsonObject[goal_summary_constants.ALLOCATED_TIME_KEY]);

    this.stacksSummaries = [];
    if (jsonObject[goal_summary_constants.STACKS_SUMMARIES_KEY] != null)
      this.stacksSummaries =
          (jsonObject[goal_summary_constants.STACKS_SUMMARIES_KEY] as List)
              .map(
                (e) => StackSummary.fromJson(e),
              )
              .toList();
  }

  Map toJson() {
    return {
      goal_summary_constants.ID_KEY: id,
      goal_summary_constants.TITLE_KEY: title,
      goal_summary_constants.COLOR_KEY: color,
      goal_summary_constants.STATUS_KEY: status,
      goal_summary_constants.TASKS_TOTAL_KEY: tasksTotal,
      goal_summary_constants.TASKS_ACCOMPLISHED_KEY: tasksAccomlished,
      goal_summary_constants.CREATION_DATE_KEY: creationDate,
      goal_summary_constants.ALLOCATED_TIME_KEY: allocatedTime.inMilliseconds,
      goal_summary_constants.STACKS_SUMMARIES_KEY:
          stacksSummaries.map((e) => e.toJson()).toList()
    };
  }

  double get completionPercentage => tasksAccomlished / max(1.0, tasksTotal);

  fetchGoal() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id)
        .get();

    var jsonObject = snapshot.data();
    this.title = jsonObject[goal_summary_constants.TITLE_KEY];
    this.color = jsonObject[goal_summary_constants.COLOR_KEY];
    this.status = jsonObject[goal_summary_constants.STATUS_KEY];
    this.tasksTotal = jsonObject[goal_summary_constants.TASKS_TOTAL_KEY];
    this.tasksAccomlished =
        jsonObject[goal_summary_constants.TASKS_ACCOMPLISHED_KEY];
    this.creationDate =
        jsonObject[goal_summary_constants.CREATION_DATE_KEY].toDate();
    this.allocatedTime = Duration(
        milliseconds: jsonObject[goal_summary_constants.ALLOCATED_TIME_KEY]);

    this.stacksSummaries = [];
    if (jsonObject[goal_summary_constants.STACKS_SUMMARIES_KEY] != null)
      this.stacksSummaries =
          (jsonObject[goal_summary_constants.STACKS_SUMMARIES_KEY] as List)
              .map(
                (e) => StackSummary.fromJson(e),
              )
              .toList();
  }

  save({bool update: false, Map<String, dynamic> data}) async {
    if (update)
      FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(feed_constants.GOALS_SUMMARIES_KEY)
          .doc(id)
          .update(Map<String, dynamic>.from(data));
    else
      FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(feed_constants.GOALS_SUMMARIES_KEY)
          .doc(id)
          .set(Map<String, dynamic>.from(toJson()));
  }

  addStack(TasksStack stack, {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    DocumentReference reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id);
    stacksSummaries.add(
      StackSummary(
        id: stack.id,
        title: stack.title,
        allocatedTime: Duration(microseconds: 0),
        tasksTotal: 0,
        tasksAccomlished: 0,
      ),
    );
    await reference.update(
      {
        goal_summary_constants.STACKS_SUMMARIES_KEY:
            stacksSummaries.map((e) => e.toJson()).toList(),
      },
    );
  }

  saveStack(TasksStack stack, {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    DocumentReference reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id);
    int i = 0;
    stacksSummaries.removeWhere(
      (e) {
        if (e.id == stack.id) {
          i = stacksSummaries.indexOf(e);
          return true;
        }
        return false;
      },
    );

    if (i < stacksSummaries.length)
      stacksSummaries.insert(
        i,
        StackSummary(
          id: stack.id,
          title: stack.title,
          allocatedTime: Duration(microseconds: 0),
          tasksTotal: 0,
          tasksAccomlished: 0,
        ),
      );
    else
      stacksSummaries.add(
        StackSummary(
          id: stack.id,
          title: stack.title,
          allocatedTime: Duration(microseconds: 0),
          tasksTotal: 0,
          tasksAccomlished: 0,
        ),
      );

    await reference.update(
      {
        goal_summary_constants.STACKS_SUMMARIES_KEY:
            stacksSummaries.map((e) => e.toJson()).toList(),
      },
    );
  }

  deleteStack(TasksStack stack, {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    stacksSummaries.removeWhere(
      (e) => e.id == stack.id,
    );
    FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id)
        .update(
      {
        goal_summary_constants.STACKS_SUMMARIES_KEY:
            stacksSummaries.map((e) => e.toJson()).toList(),
      },
    );
  }

  addTasks(int amount, Duration duration, String stackRef,
      {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    tasksTotal += amount;
    for (int i = 0; i < stacksSummaries.length; i++) {
      if (stacksSummaries[i].id == stackRef) {
        stacksSummaries[i].tasksTotal += amount;
        stacksSummaries[i].allocatedTime +=
            Duration(milliseconds: duration.inMilliseconds * amount);
        break;
      }
    }

    DocumentReference reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id);

    await reference.update({
      goal_summary_constants.TASKS_TOTAL_KEY: tasksTotal,
      goal_summary_constants.ALLOCATED_TIME_KEY:
          (allocatedTime.abs().inMilliseconds +
              amount * duration.abs().inMilliseconds),
      goal_summary_constants.STACKS_SUMMARIES_KEY:
          stacksSummaries.map((e) => e.toJson()).toList(),
    });
  }

  deleteTask(
      int amount, int accoumplishedCount, Duration duration, String stackRef,
      {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    tasksTotal -= amount;
    tasksAccomlished -= accoumplishedCount;
    for (int i = 0; i < stacksSummaries.length; i++) {
      if (stacksSummaries[i].id == stackRef) {
        stacksSummaries[i].tasksAccomlished -= accoumplishedCount;
        stacksSummaries[i].tasksTotal -= amount;
        stacksSummaries[i].allocatedTime -=
            Duration(milliseconds: duration.inMilliseconds * amount);
        break;
      }
    }

    DocumentReference reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id);

    await reference.update({
      goal_summary_constants.TASKS_TOTAL_KEY: tasksTotal,
      goal_summary_constants.TASKS_ACCOMPLISHED_KEY: tasksAccomlished,
      goal_summary_constants.ALLOCATED_TIME_KEY:
          (allocatedTime.abs().inMilliseconds -
              amount * duration.abs().inMilliseconds),
      goal_summary_constants.STACKS_SUMMARIES_KEY:
          stacksSummaries.map((e) => e.toJson()).toList(),
    });
  }

  accomplishTask(int amount, String stackRef, {bool withFetch: false}) async {
    if (withFetch) await fetchGoal();
    tasksAccomlished += amount;
    for (int i = 0; i < stacksSummaries.length; i++) {
      if (stacksSummaries[i].id == stackRef) {
        stacksSummaries[i].tasksAccomlished += amount;
        break;
      }
    }

    DocumentReference reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id);
    await reference.update(
      {
        goal_summary_constants.TASKS_ACCOMPLISHED_KEY: tasksAccomlished,
        goal_summary_constants.STACKS_SUMMARIES_KEY:
            stacksSummaries.map((e) => e.toJson()).toList(),
      },
    );
  }

  delete() async {
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(feed_constants.GOALS_SUMMARIES_KEY)
        .doc(id)
        .delete();
  }
}
