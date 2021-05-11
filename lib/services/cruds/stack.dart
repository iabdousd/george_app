import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;

Future<List<TasksStack>> fetchStacks(String goalRef,
    {DocumentSnapshot<Map<String, dynamic>> after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .doc(goalRef)
            .collection(goal_constants.STACKS_KEY)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => TasksStack.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .limit(10)
          .get())
      .docs
      .map((e) => TasksStack.fromJson(e.data()))
      .toList();
}
