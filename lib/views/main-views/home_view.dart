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

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      child: Column(
        children: [
          Container(
            child: Text(
              'Goals',
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Expanded(
            child: Container(
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
                    return Center(
                      child: AppErrorWidget(
                        status: 404,
                        customMessage:
                            'Nothing here. Create a Goal by pressing + to get started',
                      ),
                    );
                  if (snapshot.hasError) return AppErrorWidget();
                  return LoadingWidget();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
