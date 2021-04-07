import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plandoraslist/widgets/activity_feed/feed_articles_empty.dart';
import 'package:intl/intl.dart';

import 'package:plandoraslist/models/Task.dart';
import 'package:plandoraslist/services/user/user_service.dart';
import 'package:plandoraslist/widgets/activity_feed/article_skeleton.dart';
import 'package:plandoraslist/widgets/activity_feed/onetime_task_article.dart';
import 'package:plandoraslist/widgets/activity_feed/recurring_task_article.dart';
import 'package:plandoraslist/constants/user.dart' as user_constants;
import 'package:plandoraslist/constants/feed.dart' as feed_constants;

class FeedArticlesList extends StatefulWidget {
  const FeedArticlesList({Key key}) : super(key: key);

  @override
  _FeedArticlesListState createState() => _FeedArticlesListState();
}

class _FeedArticlesListState extends State<FeedArticlesList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
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
          if (snapshot.data.docs.length == 0) {
            return FeedArticlesEmptyWidget();
          }
          DateTime lastDate;
          return ListView(
            addAutomaticKeepAlives: true,
            children: snapshot.data.docs.map(
              (e) {
                Task task = Task.fromJson(
                  e.data(),
                  id: e.id,
                );
                bool showDate = false;
                if (lastDate == null) {
                  showDate = true;
                } else
                  showDate = !(lastDate.day == task.creationDate.day &&
                      lastDate.month == task.creationDate.month &&
                      lastDate.year == task.creationDate.year);

                lastDate = task.creationDate;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate)
                      Container(
                        margin: EdgeInsets.only(
                          left: 16.0,
                          top: 24.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          DateFormat('EEEE, dd MMMM').format(task.creationDate),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (task.repetition == null)
                      OnetimeTaskArticleWidget(
                        key: Key(task.id),
                        name: 'George',
                        profilePicture:
                            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                        task: task,
                      )
                    else
                      RecurringTaskArticleWidget(
                        key: Key(task.id),
                        name: 'George',
                        profilePicture:
                            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                        task: task,
                      ),
                  ],
                );
              },
            ).toList(),
          );
        }
        return ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) => ArticleSkeletonWidget(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
