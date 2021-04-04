import 'package:flutter/material.dart';
import 'package:george_project/widgets/activity_feed/feed_articles_empty.dart';

class GoalsSummaryView extends StatefulWidget {
  GoalsSummaryView({Key key}) : super(key: key);

  @override
  _GoalsSummaryViewState createState() => _GoalsSummaryViewState();
}

class _GoalsSummaryViewState extends State<GoalsSummaryView> {
  @override
  Widget build(BuildContext context) {
    return FeedArticlesEmptyWidget();
  }
}
