import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:george_project/widgets/activity_feed/task_feed_article_actions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OnetimeTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;

  const OnetimeTaskArticleWidget({
    Key key,
    this.name,
    this.profilePicture,
    this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Color(0x22000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(42.0),
                  child: Image(
                    image: CachedImageProvider(profilePicture),
                    fit: BoxFit.cover,
                    width: 42,
                    height: 42,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      DateFormat('EEE, dd MMM yyyy   hh:mm a')
                          .format(task.creationDate),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    decoration: task.status == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
            ),
          ),
          if (task.description != '')
            Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
              child: Text(
                task.description,
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      decoration: task.status == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
              top: 8.0,
            ),
            child: FutureProvider<String>(
              initialData: '',
              create: (_) {
                return task.fetchNotes();
              },
              child: Consumer<String>(
                builder: (context, data, _) {
                  if (data == null)
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 8.0,
                            ),
                            height: 12,
                            color: Theme.of(context).backgroundColor,
                            width: double.infinity,
                          ),
                          Container(
                            height: 12,
                            color: Theme.of(context).backgroundColor,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  if (data == '')
                    return Container();
                  else
                    return Text(
                      data,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(),
                    );
                },
              ),
            ),
          ),
          TaskFeedArticleActions(
            task: task,
          ),
        ],
      ),
    );
  }
}
