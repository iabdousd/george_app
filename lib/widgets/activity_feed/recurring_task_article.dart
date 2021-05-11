import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/widgets/activity_feed/task_feed_article_actions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';

import 'task_progress_indicator.dart';

class RecurringTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;

  const RecurringTaskArticleWidget({
    Key key,
    this.name,
    this.profilePicture,
    this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenshotController = ScreenshotController();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Color(0x22000000),
        ),
        color: Theme.of(context).backgroundColor,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Screenshot(
            controller: screenshotController,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(42.0),
                          child: profilePicture != null
                              ? Image(
                                  image: CachedImageProvider(profilePicture),
                                  fit: BoxFit.cover,
                                  width: 42,
                                  height: 42,
                                )
                              : SvgPicture.asset(
                                  'assets/images/profile.svg',
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
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(task.creationDate),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 4.0),
                    child: Text(
                      '${task.goalTitle} > ${task.stackTitle}',
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 4.0),
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 4.0,
                      top: 4.0,
                    ),
                    child: Text(
                      '${task.completionRate}% completion  |  ${task.maxStreak} days streak',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return TaskProgressIndicator(
                        dueDates: task.dueDates,
                        donesHistory: task.donesHistory,
                      );
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 12.0,
                      top: 4.0,
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
                            return Container(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                data,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                            );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TaskFeedArticleActions(
            task: task,
            screenshotController: screenshotController,
          ),
        ],
      ),
    );
  }
}
