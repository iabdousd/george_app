import 'package:flutter/material.dart';
import 'package:george_project/widgets/activity_feed/today_tasks.dart';
import 'package:george_project/widgets/activity_feed/week_progress.dart';

class ActivityFeedView extends StatefulWidget {
  ActivityFeedView({Key key}) : super(key: key);

  @override
  _ActivityFeedViewState createState() => _ActivityFeedViewState();
}

class _ActivityFeedViewState extends State<ActivityFeedView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0 + 20.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Activity feed",
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TodayTasks(),
        WeekProgress(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
