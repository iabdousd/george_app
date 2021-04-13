import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plandoraslist/services/feed-back/loader.dart';

import 'package:plandoraslist/widgets/goal/GoalTile.dart';
import 'package:plandoraslist/constants/models/goal.dart' as goal_constants;
import 'package:plandoraslist/constants/user.dart' as user_constants;
import 'package:plandoraslist/models/Goal.dart';
import 'package:plandoraslist/services/user/user_service.dart';
import 'package:plandoraslist/widgets/shared/app_error_widget.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  int limit = 10;
  int elementsCount = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          elementsCount == limit)
        setState(() {
          limit += 10;
        });
    });
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
                    .limit(limit)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    elementsCount = snapshot.data.docs.length;
                    if (snapshot.data.docs.length > 0)
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        controller: _scrollController,
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
