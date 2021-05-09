import 'package:stackedtasks/models/Stack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/goal_summary.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;

import 'package:stackedtasks/constants/models/goal_summary.dart'
    as goal_summary_constants;

class Goal {
  String id;
  String title;
  String color;
  int status;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  List<TasksStack> stacks;

  Goal({
    this.id,
    this.title,
    this.color,
    this.status = 0,
    this.creationDate,
    this.startDate,
    this.endDate,
    stacks,
  }) {
    this.stacks = stacks ?? [];
  }

  Goal.fromJson(Map<String, dynamic> jsonObject, {String id}) {
    this.id = id;
    this.title = jsonObject[goal_constants.TITLE_KEY];
    this.color = jsonObject[goal_constants.COLOR_KEY];
    this.status = jsonObject[goal_constants.STATUS_KEY];
    this.creationDate =
        (jsonObject[goal_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.startDate =
        (jsonObject[goal_constants.START_DATE_KEY] as Timestamp).toDate();
    this.endDate =
        (jsonObject[goal_constants.END_DATE_KEY] as Timestamp).toDate();
    this.stacks = [];
  }

  Map<String, dynamic> toJson() {
    return {
      goal_constants.TITLE_KEY: title,
      goal_constants.COLOR_KEY: color,
      goal_constants.STATUS_KEY: status,
      goal_constants.CREATION_DATE_KEY: creationDate,
      goal_constants.START_DATE_KEY: startDate,
      goal_constants.END_DATE_KEY: endDate,
      goal_constants.STACKS_KEY: stacks.map((e) => e.toJson()).toList(),
    };
  }

  Future fetch({bool withStacks = false}) async {
    assert(id != null);
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(id)
        .get();
    Goal tempG = Goal.fromJson(
      doc.data(),
    );

    this.title = tempG.title;
    this.color = tempG.color;
    this.status = tempG.status;
    this.creationDate = tempG.creationDate;
    this.startDate = tempG.startDate;
    this.endDate = tempG.endDate;

    if (withStacks) await fetchStacks();
  }

  Future fetchStacks() async {
    assert(id != null);
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(id)
        .collection(goal_constants.STACKS_KEY)
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            this.stacks.add(
                  TasksStack.fromJson(
                    element.data(),
                    goalRef: id,
                    id: element.id,
                  ),
                );
          },
        );
      },
    );
  }

  Future save() async {
    if (id == null) {
      DocumentReference documentReference = await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .add(toJson());

      id = documentReference.id;

      for (TasksStack stack in stacks) {
        DocumentReference docRef = await documentReference
            .collection(goal_constants.STACKS_KEY)
            .add(stack.toJson());
        stack.id = docRef.id;
        stack.goalRef = id;
      }
      await GoalSummary(
        id: id,
        title: title,
        color: color,
        creationDate: creationDate,
        status: status,
        stacksSummaries: [],
        allocatedTime: Duration(),
        tasksTotal: 0,
        tasksAccomlished: 0,
      ).save();
    } else {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(id)
          .update(toJson());
      await GoalSummary(
        id: id,
      ).save(update: true, data: {
        goal_summary_constants.TITLE_KEY: title,
      });
    }
    return this;
  }

  Future addStack(TasksStack stack) async {
    assert(id != null);

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(id)
        .collection(goal_constants.STACKS_KEY)
        .add(stack.toJson());
    stacks.add(
      stack
        ..id = docRef.id
        ..goalRef = id,
    );
  }

  Future delete() async {
    assert(id != null);
    final reference = FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(id);

    final tasksDocs = (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(stack_constants.TASKS_KEY)
            .where(task_constants.GOAL_REF_KEY, isEqualTo: reference.id)
            .get())
        .docs;

    for (final element in tasksDocs) await element.reference.delete();

    await reference.delete();
    await GoalSummary(
      id: id,
    ).delete();
  }
}
