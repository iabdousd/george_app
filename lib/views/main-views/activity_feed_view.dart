import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/activity_feed/onetime_task_article.dart';
import 'package:george_project/widgets/activity_feed/recurring_task_article.dart';
import 'package:george_project/widgets/activity_feed/today_tasks.dart';
import 'package:george_project/widgets/activity_feed/week_progress.dart';
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/feed.dart' as feed_constants;
import 'package:intl/intl.dart';
// import 'package:george_project/constants/models/task.dart' as task_constants;
// import 'package:george_project/constants/models/stack.dart' as stack_constants;

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
          margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  "Activity feed",
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(
                CupertinoIcons.person_circle_fill,
                size: 36,
              ),
            ],
          ),
        ),
        TodayTasks(),
        WeekProgress(),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(user_constants.USERS_KEY)
              .doc(getCurrentUser().uid)
              .collection(feed_constants.FEED_KEY)
              .orderBy(
                feed_constants.CREATION_DATE_KEY,
                descending: true,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DateTime lastDate;
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  Task task = Task.fromJson(
                    snapshot.data.docs[index].data(),
                    id: snapshot.data.docs[index].id,
                  );
                  bool showDate = false;
                  if (lastDate == null) {
                    lastDate = task.creationDate;
                    showDate = true;
                  } else
                    showDate = !(lastDate.day == task.creationDate.day &&
                        lastDate.month == task.creationDate.month &&
                        lastDate.year == task.creationDate.year);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDate)
                        Container(
                          margin: EdgeInsets.only(
                            left: 16.0,
                            top: 16.0,
                            bottom: 4.0,
                          ),
                          child: Text(
                            DateFormat('EEEE, dd MMMM')
                                .format(task.creationDate),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      if (task.repetition == null)
                        OnetimeTaskArticleWidget(
                          key: Key(task.id),
                          name: 'George',
                          profilePicture:
                              'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                          task: task,
                        )
                      else
                        RecurringTaskArticleWidget(
                          key: Key(task.id),
                          name: 'George',
                          profilePicture:
                              'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                          task: task,
                        ),
                    ],
                  );
                },
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
