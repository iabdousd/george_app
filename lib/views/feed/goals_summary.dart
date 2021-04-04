import 'package:flutter/material.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/widgets/activity_feed/feed_articles_empty.dart';
import 'package:george_project/widgets/goal/goal_summary.dart';

class GoalsSummaryView extends StatefulWidget {
  GoalsSummaryView({Key key}) : super(key: key);

  @override
  _GoalsSummaryViewState createState() => _GoalsSummaryViewState();
}

class _GoalsSummaryViewState extends State<GoalsSummaryView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GoalSummaryWidget(
          name: 'George',
          profilePicture:
              'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
          goal: Goal(
            creationDate: DateTime.now(),
          ),
        ),
      ],
    );
    // return FeedArticlesEmptyWidget();
  }
}
