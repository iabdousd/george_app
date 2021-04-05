import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_project/models/goal_summary.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/activity_feed/feed_articles_empty.dart';
import 'package:george_project/widgets/goal/goal_summary.dart';
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/feed.dart' as feed_constants;

class GoalsSummaryView extends StatefulWidget {
  GoalsSummaryView({Key key}) : super(key: key);

  @override
  _GoalsSummaryViewState createState() => _GoalsSummaryViewState();
}

class _GoalsSummaryViewState extends State<GoalsSummaryView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(feed_constants.GOALS_SUMMARIES_KEY)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.docs.length == 0)
          return FeedArticlesEmptyWidget();
        else if (snapshot.hasData)
          return ListView(
            children: snapshot.data.docs.map(
              (e) {
                GoalSummary goalSummary = GoalSummary.fromJson(e.data());
                return GoalSummaryWidget(
                  name: 'George',
                  profilePicture:
                      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                  goal: goalSummary,
                );
              },
            ).toList(),
          );
        return LoadingWidget();
      },
    );
    // return FeedArticlesEmptyWidget();
  }
}
