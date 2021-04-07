import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plandoraslist/models/Stack.dart';
import 'package:plandoraslist/services/user/user_service.dart';
import 'package:plandoraslist/constants/models/goal.dart' as goal_constants;
import 'package:plandoraslist/constants/user.dart' as user_constants;

Future<List<Stack>> fetchStacks(String goalRef,
    {DocumentSnapshot after}) async {
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
        .map((e) => Stack.fromJson(e.data()))
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
      .map((e) => Stack.fromJson(e.data()))
      .toList();
}
