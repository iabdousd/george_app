import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/user/user_service.dart';

createGoal(Goal goal) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(getCurrentUser().uid)
      .set(
    {
      goal.id: goal.toJson(),
    },
  );
}

updateGoal(Goal newGoal) async {
  FirebaseFirestore.instance
      .collection('users')
      .doc(getCurrentUser().uid)
      .update(
    {
      newGoal.id: newGoal.toJson(),
    },
  );
}

deleteGoal(Goal goal) async {
  // FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(getCurrentUser().uid)
  //     .get(goal)
  //     .delete();
}
