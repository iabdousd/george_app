import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;

Future<List<Task>> fetchTasks(String goalRef, String stackRef,
    {DocumentSnapshot after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(stack_constants.TASKS_KEY)
            .where(task_constants.STACK_REF_KEY, isEqualTo: stackRef)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => Task.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(stack_constants.TASKS_KEY)
          .where(task_constants.STACK_REF_KEY, isEqualTo: stackRef)
          .limit(10)
          .get())
      .docs
      .map((e) => Task.fromJson(e.data()))
      .toList();
}
