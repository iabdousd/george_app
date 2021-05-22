import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;

Future<List<Goal>> fetchGoals(
    {DocumentSnapshot<Map<String, dynamic>> after}) async {
  if (after != null)
    return (await FirebaseFirestore.instance
            .collection(goal_constants.GOALS_KEY)
            .where(goal_constants.USER_ID_KEY, isEqualTo: getCurrentUser().uid)
            .startAfterDocument(after)
            .limit(10)
            .get())
        .docs
        .map((e) => Goal.fromJson(e.data()))
        .toList();

  return (await FirebaseFirestore.instance
          .collection(goal_constants.GOALS_KEY)
          .where(goal_constants.USER_ID_KEY, isEqualTo: getCurrentUser().uid)
          .limit(10)
          .get())
      .docs
      .map((e) => Goal.fromJson(e.data()))
      .toList();
}
