import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/services/feed-back/loader.dart';

import 'package:george_project/widgets/goal/GoalTile.dart';
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/shared/app_error_widget.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      children: [
        Container(
          child: Text(
            'Goals',
            style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(user_constants.USERS_KEY)
                .doc(getCurrentUser().uid)
                .collection(goal_constants.GOALS_KEY)
                .orderBy(goal_constants.CREATION_DATE_KEY, descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) if (snapshot.data.docs.length > 0)
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GoalListTileWidget(
                      goal: Goal.fromJson(
                        snapshot.data.docs[index].data(),
                        id: snapshot.data.docs[index].id,
                      ),
                    );
                  },
                );
              else
                return AppErrorWidget(
                  status: 404,
                );
              if (snapshot.hasError) return AppErrorWidget();
              return LoadingWidget();
            },
          ),
        ),
      ],
    );
  }
}
