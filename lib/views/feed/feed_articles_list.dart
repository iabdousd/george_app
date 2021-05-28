import 'package:flutter/material.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/widgets/activity_feed/feed_articles_empty.dart';
import 'package:intl/intl.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/widgets/activity_feed/article_skeleton.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/recurring_task_article.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

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
    return StreamBuilder<List<Task>>(
      stream: FeedRepository.fetchArticles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return AppErrorWidget();
        }
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return FeedArticlesEmptyWidget();
          }
          DateTime lastDate;
          return ListView(
            addAutomaticKeepAlives: true,
            children: snapshot.data.map(
              (task) {
                bool showDate = false;
                if (lastDate == null) {
                  showDate = true;
                } else
                  showDate = !(lastDate.day == task.creationDate.day &&
                      lastDate.month == task.creationDate.month &&
                      lastDate.year == task.creationDate.year);

                lastDate = task.creationDate;
                return Row(
                  key: Key(task.id),
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
                                        .format(task.startTime),
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
                          name: task.userName,
                          profilePicture: task.userPhoto,
                          task: task,
                          showAuthorRow: showDate,
                        ),
                      )
                    else
                      Expanded(
                        child: RecurringTaskArticleWidget(
                          name: task.userName,
                          profilePicture: task.userPhoto,
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
