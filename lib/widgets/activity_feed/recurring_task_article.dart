import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/widgets/activity_feed/task_feed_article_actions.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stackedtasks/widgets/note/task_notes_thread.dart';

import 'task_progress_indicator.dart';

class RecurringTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;
  final bool showAuthorRow;

  const RecurringTaskArticleWidget({
    Key key,
    this.name,
    this.profilePicture,
    this.task,
    this.showAuthorRow: true,
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
      margin: EdgeInsets.only(top: showAuthorRow ? 8 : 0),
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
                  if (showAuthorRow)
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
                          Text(
                            name ?? '',
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                    child: TaskProgressIndicator(
                      dueDates: task.dueDates,
                      donesHistory: task.donesHistory,
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
          Container(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: TaskNotesThread(
              task: task.copyWith(
                id: task.id.substring(0, task.id.length - 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
