import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plandoraslist/models/Task.dart';
import 'package:plandoraslist/constants/models/task.dart' as task_constants;
import 'package:plandoraslist/constants/models/stack.dart' as stack_constants;
import 'package:plandoraslist/constants/user.dart' as user_constants;
import 'package:plandoraslist/constants/models/goal.dart' as goal_constants;
import 'package:plandoraslist/services/user/user_service.dart';

Future<List<Task>> tasksByDate(DateTime date) async {
  List<Task> tasks = [];
  DateTime now = DateTime.now();
  QuerySnapshot tasksRefs = await FirebaseFirestore.instance
      .collection(user_constants.USERS_KEY)
      .doc(getCurrentUser().uid)
      .collection(stack_constants.TASKS_KEY)
      .where(
        task_constants.DUE_DATES_KEY,
        arrayContains: DateTime(now.year, now.month, now.day),
      )
      .get();
  print(tasksRefs.docs);
  for (var taskRef in tasksRefs.docs) {
    Task task = Task.fromJson(taskRef.data());

    DateTime now = DateTime.now();
    if (task.repetition?.type == 'daily')
      tasks.add(task);
    else if (task.repetition?.type == 'weekly') {
      if (task.getNextInstanceDate().month == now.month &&
          task.getNextInstanceDate().day == now.day) tasks.add(task);
    } else if (task.repetition?.type == 'monthly') {
      if (task.getNextInstanceDate().month == now.month &&
          task.getNextInstanceDate().day == now.day) tasks.add(task);
    } else if (task.repetition?.type == null) {
      tasks.add(task);
    }
  }
  return tasks;
}
