import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/goal.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/Task.dart';

import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/services/user/user_service.dart';

class StackRepository {
  static Stream<List<TasksStack>> streamStacks(Goal goal) =>
      FirebaseFirestore.instance
          .collection(STACKS_KEY)
          .where(
            stack_constants.GOAL_REF_KEY,
            isEqualTo: goal.id,
          )
          .orderBy(
            stack_constants.INDEX_KEY,
            descending: false,
          )
          .orderBy(
            stack_constants.CREATION_DATE_KEY,
            descending: true,
          )
          .snapshots()
          .map(
            (event) => event.docs
                .map(
                  (e) => TasksStack.fromJson(
                    e.data(),
                    goalRef: goal.id,
                    goalTitle: goal.title,
                    id: e.id,
                  ),
                )
                .toList(),
          );

  static Future<List<Task>> getStackTasks(TasksStack stack, [int limit]) async {
    if (limit != null)
      return (await FirebaseFirestore.instance
              .collection(stack_constants.TASKS_KEY)
              .where(task_constants.USER_ID_KEY,
                  isEqualTo: getCurrentUser().uid)
              .where(task_constants.STACK_REF_KEY, isEqualTo: stack.id)
              .orderBy(task_constants.CREATION_DATE_KEY, descending: true)
              .limit(limit)
              .get())
          .docs
          .map((e) => Task.fromJson(
                e.data(),
                id: e.id,
              ))
          .toList();
    return (await FirebaseFirestore.instance
            .collection(stack_constants.TASKS_KEY)
            .where(task_constants.USER_ID_KEY, isEqualTo: getCurrentUser().uid)
            .where(task_constants.STACK_REF_KEY, isEqualTo: stack.id)
            .orderBy(task_constants.CREATION_DATE_KEY, descending: true)
            .get())
        .docs
        .map((e) => Task.fromJson(
              e.data(),
              id: e.id,
            ))
        .toList();
  }

  static Stream<List<Task>> streamStackTasks(TasksStack stack) {
    return FirebaseFirestore.instance
        .collection(stack_constants.TASKS_KEY)
        .where(task_constants.USER_ID_KEY, isEqualTo: getCurrentUser().uid)
        .where(task_constants.STACK_REF_KEY, isEqualTo: stack.id)
        .orderBy(task_constants.INDEX_KEY, descending: false)
        .orderBy(task_constants.CREATION_DATE_KEY, descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Task.fromJson(
                    e.data(),
                    id: e.id,
                  ))
              .toList(),
        );
  }

  static Future<void> changeStackOrder(TasksStack stack, int newIndex) async {
    if (stack.goalRef == 'inbox') {
      await FirebaseFirestore.instance
          .collection(INBOX_COLLECTION)
          .doc(stack.id)
          .update({
        stack_constants.INDEX_KEY: newIndex,
      });
    } else {
      await FirebaseFirestore.instance
          .collection(STACKS_KEY)
          .doc(stack.id)
          .update({
        stack_constants.INDEX_KEY: newIndex,
      });
    }
  }
}
