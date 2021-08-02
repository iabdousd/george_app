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
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
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
                if (task.repetition == null)
                  return OnetimeTaskArticleWidget(
                    key: Key(task.id),
                    name: task.userName,
                    profilePicture: task.userPhoto,
                    task: task,
                    showAuthorRow: true,
                  );
                else
                  return RecurringTaskArticleWidget(
                    key: Key(task.id),
                    name: task.userName,
                    profilePicture: task.userPhoto,
                    task: task,
                    showAuthorRow: true,
                  );
                // return Column(
                //   children: [
                // if (showDate)
                //   Padding(
                //     padding: const EdgeInsets.only(
                //       top: 16.0,
                //       bottom: 8.0,
                //     ),
                //     child: Row(
                //       children: [
                //         Expanded(
                //           child: Text(
                //             DateFormat('EEEE, MMMM dd').format(lastDate),
                //             style: TextStyle(
                //               color: Color(0xFFB2B5C3),
                //               fontWeight: FontWeight.w600,
                //               fontSize: 14,
                //             ),
                //           ),
                //         ),
                //         Text(
                //           DateFormat('hh:mm').format(lastDate),
                //           style: TextStyle(
                //             color: Color(0xFFB2B5C3),
                //             fontWeight: FontWeight.w600,
                //             fontSize: 14,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // if (task.repetition == null)
                //   OnetimeTaskArticleWidget(
                //     name: task.userName,
                //     profilePicture: task.userPhoto,
                //     task: task,
                //     showAuthorRow: true,
                //   )
                // else
                //   RecurringTaskArticleWidget(
                //     name: task.userName,
                //     profilePicture: task.userPhoto,
                //     task: task,
                //     showAuthorRow: true,
                //   ),
                //   ],
                // );
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
