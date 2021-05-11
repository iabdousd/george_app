import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/goal_summary.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/feed_articles_empty.dart';
import 'package:stackedtasks/widgets/activity_feed/week_progress.dart';
import 'package:stackedtasks/widgets/goal/goal_summary.dart';
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/feed.dart' as feed_constants;

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
            children: <Widget>[
                  if (kIsWeb) WeekProgress(),
                ] +
                snapshot.data.docs.map(
                  (e) {
                    GoalSummary goalSummary = GoalSummary.fromJson(e.data());
                    return GoalSummaryWidget(
                      name: FirebaseAuth.instance.currentUser.displayName,
                      profilePicture:
                          FirebaseAuth.instance.currentUser.photoURL,
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
