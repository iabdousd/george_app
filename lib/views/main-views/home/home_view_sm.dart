import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

import 'package:stackedtasks/widgets/goal/GoalTile.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class HomeViewSM extends StatefulWidget {
  @override
  _HomeViewSMState createState() => _HomeViewSMState();
}

class _HomeViewSMState extends State<HomeViewSM>
    with AutomaticKeepAliveClientMixin {
  int elementsCount = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 20.0,
              bottom: 12.0,
            ),
            child: Text(
              'Stackedtasks',
              style: Theme.of(context).textTheme.headline4.copyWith(
                    fontFamily: 'logo',
                    color: Theme.of(context).primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
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
                    .collection(user_constants.USERS_KEY)
                    .doc(getCurrentUser().uid)
                    .collection(goal_constants.GOALS_KEY)
                    .orderBy(goal_constants.CREATION_DATE_KEY, descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    elementsCount = snapshot.data.docs.length;
                    if (snapshot.data.docs.length > 0)
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
                  }
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
