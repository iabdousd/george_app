import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/views/goal/goal_detials.dart';
import 'package:george_project/widgets/goal/GoalTile.dart';
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              getCurrentUser()?.uid ?? 'NONE',
              textAlign: TextAlign.center,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 32.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(user_constants.USERS_KEY)
                    .doc(getCurrentUser().uid)
                    .collection(goal_constants.GOALS_KEY)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  print(snapshot.data);
                  if (snapshot.hasData)
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GoalListTileWidget(
                            goal: Goal.fromJson(
                                snapshot.data.docs[index].data()));
                      },
                    );
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(GoalDetails()),
        child: Icon(Icons.add),
      ),
    );
  }
}
