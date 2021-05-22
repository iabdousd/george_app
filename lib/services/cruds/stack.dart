import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

Future<List<TasksStack>> fetchStacks(String goalRef,
    {DocumentSnapshot<Map<String, dynamic>> after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(goal_constants.STACKS_KEY)
            .where(stack_constants.GOAL_REF_KEY, isEqualTo: goalRef)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => TasksStack.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(goal_constants.STACKS_KEY)
          .where(stack_constants.GOAL_REF_KEY, isEqualTo: goalRef)
          .limit(10)
          .get())
      .docs
      .map((e) => TasksStack.fromJson(e.data()))
      .toList();
}
