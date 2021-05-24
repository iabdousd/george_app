import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/widgets/activity_feed/task_feed_article_actions.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stackedtasks/widgets/note/task_notes_thread.dart';

class OnetimeTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;
  final bool showAuthorRow;

  const OnetimeTaskArticleWidget({
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
                              // Text(
                              //   DateFormat('hh:mm a').format(task.creationDate),
                              //   style: Theme.of(context).textTheme.bodyText2,
                              // ),
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
                        left: 16.0, right: 16.0, top: 0.0),
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            decoration: task.status == 1
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                    ),
                  ),
                  if (task.description != '')
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 6),
                      child: Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 16,
                              decoration: task.status == 1
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
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
