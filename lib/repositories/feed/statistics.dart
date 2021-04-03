import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/models/Task.dart';

import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/feed.dart' as feed_constants;
// import 'package:george_project/constants/models/task.dart' as task_constants;
// import 'package:george_project/constants/models/stack.dart' as stack_constants;

addTaskAccomplishment(Task task) async {
  DateTime start = DateTime(
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).year,
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).month,
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).day,
  );

  DocumentReference documentReference = FirebaseFirestore.instance
      .collection(user_constants.USERS_KEY)
      .doc(getCurrentUser().uid)
      .collection(feed_constants.STATISTICS_KEY)
      .doc(task.creationDate.year.toString())
      .collection(feed_constants.WEEKLY_STATISTICS_KEY)
      .doc(start.toString());

  DocumentSnapshot snapshot = await documentReference.get();
  Map data = snapshot.data() ?? {};
  await documentReference.set({
    feed_constants.STATISTICS_CREATION_DATE_KEY: DateTime.now(),
    feed_constants.WEEK_START_DATE_KEY: start,
    ...data,
    feed_constants.ACCOMPLISHED_TASKS_KEY:
        (data[feed_constants.ACCOMPLISHED_TASKS_KEY] ?? 0) + 1,
  });
}

removeTaskAccomplishment(Task task) async {
  DateTime start = DateTime(
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).year,
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).month,
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).day,
  );

  DocumentReference documentReference = FirebaseFirestore.instance
      .collection(user_constants.USERS_KEY)
      .doc(getCurrentUser().uid)
      .collection(feed_constants.STATISTICS_KEY)
      .doc(task.creationDate.year.toString())
      .collection(feed_constants.WEEKLY_STATISTICS_KEY)
      .doc(start.toString());

  DocumentSnapshot snapshot = await documentReference.get();
  Map data = snapshot.data() ?? {};
  await documentReference.set({
    feed_constants.STATISTICS_CREATION_DATE_KEY: DateTime.now(),
    feed_constants.WEEK_START_DATE_KEY: start,
    ...data,
    feed_constants.ACCOMPLISHED_TASKS_KEY: max(
      ((data[feed_constants.ACCOMPLISHED_TASKS_KEY] ?? 1) - 1).toInt() as int,
      0,
    ),
  });
}

Stream<QuerySnapshot> getWeeklyAccomlishements() {
  final now = DateTime.now();
  DateTime start = now.subtract(Duration(days: now.weekday - 1));

  return FirebaseFirestore.instance
      .collection(user_constants.USERS_KEY)
      .doc(getCurrentUser().uid)
      .collection(feed_constants.STATISTICS_KEY)
      .doc(now.year.toString())
      .collection(feed_constants.WEEKLY_STATISTICS_KEY)
      .where(
        feed_constants.WEEK_START_DATE_KEY,
        isGreaterThanOrEqualTo: DateTime(
          start.subtract(Duration(days: 7 * 11)).year,
          start.subtract(Duration(days: 7 * 11)).month,
          start.subtract(Duration(days: 7 * 11)).day,
        ),
      )
      .where(
        feed_constants.WEEK_START_DATE_KEY,
        isLessThanOrEqualTo: DateTime(
          start.subtract(Duration(days: 7 * 0)).year,
          start.subtract(Duration(days: 7 * 0)).month,
          start.subtract(Duration(days: 7 * 0)).day,
        ),
      )
      .snapshots();
}
