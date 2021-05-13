import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/Task.dart';

import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/services/user/user_service.dart';

class StackRepository {
  static Future<List<Task>> getStackTasks(TasksStack stack, int limit) async {
    return (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(stack_constants.TASKS_KEY)
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
  }

  static Stream<List<Task>> streamStackTasks(TasksStack stack, int limit) {
    return FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(stack_constants.TASKS_KEY)
        .where(task_constants.STACK_REF_KEY, isEqualTo: stack.id)
        .orderBy(task_constants.CREATION_DATE_KEY, descending: true)
        .limit(limit)
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
}
