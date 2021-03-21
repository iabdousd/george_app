import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/constants/user.dart' as user_constants;

import 'Task.dart';

class Stack {
  String id;
  String goalRef;
  String title;
  String color;
  int status;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  List<Task> tasks;

  Stack({
    this.id,
    this.goalRef,
    this.title,
    this.color,
    this.status = 0,
    this.creationDate,
    this.startDate,
    this.endDate,
    this.tasks,
  });

  Stack.fromJson(
    Map<String, dynamic> jsonObject, {
    String goalRef,
    String id,
  }) {
    this.id = id;
    this.goalRef = goalRef;
    this.title = jsonObject[stack_constants.TITLE_KEY];
    this.color = jsonObject[stack_constants.COLOR_KEY];
    this.status = jsonObject[stack_constants.STATUS_KEY];
    this.creationDate =
        (jsonObject[stack_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.startDate =
        (jsonObject[stack_constants.START_DATE_KEY] as Timestamp).toDate();
    this.endDate =
        (jsonObject[stack_constants.END_DATE_KEY] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      stack_constants.TITLE_KEY: title,
      stack_constants.COLOR_KEY: color,
      stack_constants.STATUS_KEY: status,
      stack_constants.CREATION_DATE_KEY: creationDate,
      stack_constants.START_DATE_KEY: startDate,
      stack_constants.END_DATE_KEY: endDate,
    };
  }

  Future save() async {
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
    } else {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(id)
          .update(toJson());
    }
  }

  Future delete() async {
    assert(id != null);
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(goalRef)
        .collection(goal_constants.STACKS_KEY)
        .doc(id)
        .delete();
  }
}
