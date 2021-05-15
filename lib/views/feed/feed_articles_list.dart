import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/widgets/activity_feed/feed_articles_empty.dart';
import 'package:intl/intl.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/article_skeleton.dart';
import 'package:stackedtasks/widgets/activity_feed/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/recurring_task_article.dart';
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/feed.dart' as feed_constants;

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
                return Row(
                  crossAxisAlignment: showDate
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 8.0,
                      ),
                      width: 80,
                      child: showDate
                          ? Column(
                              children: [
                                Text(
                                  DateFormat('EEEE\nMMMM d')
                                      .format(task.creationDate)
                                      .toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .color
                                            .withOpacity(.6),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    DateFormat('hh:mm a')
                                        .format(task.creationDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color
                                              .withOpacity(.5),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              DateFormat('hh:mm a').format(task.creationDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color
                                        .withOpacity(.5),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    if (task.repetition == null)
                      Expanded(
                        child: OnetimeTaskArticleWidget(
                          key: Key(task.id),
                          name: FirebaseAuth.instance.currentUser.displayName,
                          profilePicture:
                              FirebaseAuth.instance.currentUser.photoURL,
                          task: task,
                          showAuthorRow: showDate,
                        ),
                      )
                    else
                      Expanded(
                        child: RecurringTaskArticleWidget(
                          key: Key(task.id),
                          name: FirebaseAuth.instance.currentUser.displayName,
                          profilePicture:
                              FirebaseAuth.instance.currentUser.photoURL,
                          task: task,
                          showAuthorRow: showDate,
                        ),
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
