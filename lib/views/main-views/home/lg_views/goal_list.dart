import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/home/tiles/lg_goal_tile.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class HomeLGGoalList extends StatelessWidget {
  final Goal selectedGoal;
  final Function(Goal) selectGoal;
  const HomeLGGoalList({
    Key key,
    this.selectedGoal,
    this.selectGoal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 0.0,
          ),
          child: Row(
            children: [
              Text(
                'Goals:',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            margin: const EdgeInsets.only(bottom: 8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(goal_constants.GOALS_KEY)
                  .where(goal_constants.USER_ID_KEY,
                      isEqualTo: getCurrentUser().uid)
                  .orderBy(goal_constants.CREATION_DATE_KEY, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.length > 0)
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        final goal = Goal.fromJson(
                          snapshot.data.docs[index].data(),
                          id: snapshot.data.docs[index].id,
                        );
                        return LGGoalTile(
                          goal: goal,
                          selected: selectedGoal?.id == goal.id,
                          onSelected: () => selectGoal(goal),
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
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return AppErrorWidget();
                }
                return LoadingWidget();
              },
            ),
          ),
        ),
      ],
    );
  }
}
