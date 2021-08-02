import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class GoalRepository {
  static Stream<List<Goal>> streamGoals() => FirebaseFirestore.instance
      .collection(goal_constants.GOALS_KEY)
      .where(goal_constants.USER_ID_KEY, isEqualTo: getCurrentUser().uid)
      .orderBy(goal_constants.INDEX_KEY, descending: false)
      .orderBy(goal_constants.CREATION_DATE_KEY, descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (e) => Goal.fromJson(
                e.data(),
                id: e.id,
              ),
            )
            .toList(),
      );

  static Future<void> changeGoalOrder(Goal goal, int newIndex) async {
    await FirebaseFirestore.instance
        .collection(goal_constants.GOALS_KEY)
        .doc(goal.id)
        .update({
      goal_constants.INDEX_KEY: newIndex,
    });
  }
}
