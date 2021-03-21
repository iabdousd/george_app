import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/user.dart' as user_constants;

Future<List<Task>> fetchStacks(String goalRef, String stackRef,
    {DocumentSnapshot after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .doc(goalRef)
            .collection(goal_constants.STACKS_KEY)
            .doc(stackRef)
            .collection(stack_constants.TASKS_KEY)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => Task.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.TASKS_KEY)
          .limit(10)
          .get())
      .docs
      .map((e) => Task.fromJson(e.data()))
      .toList();
}
