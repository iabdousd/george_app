import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plandoraslist/models/Goal.dart';
import 'package:plandoraslist/services/user/user_service.dart';
import 'package:plandoraslist/constants/models/goal.dart' as goal_constants;
import 'package:plandoraslist/constants/user.dart' as user_constants;

Future<List<Goal>> fetchGoals({DocumentSnapshot after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(goal_constants.GOALS_KEY)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => Goal.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .limit(10)
          .get())
      .docs
      .map((e) => Goal.fromJson(e.data()))
      .toList();
}
