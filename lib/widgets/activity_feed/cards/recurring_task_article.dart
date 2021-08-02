import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/shared/task_feed_article_actions.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

import '../task_progress_indicator.dart';
import 'shared/task_feed_header.dart';
import 'shared/task_feed_top_actions.dart';

class RecurringTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;
  final bool showAuthorRow,
      showActions,
      showNotes,
      localTaskPhoto,
      initialShowAll,
      sharing;

  final Function(GlobalKey) onScreenshotReady;

  const RecurringTaskArticleWidget({
    Key key,
    this.name,
    this.profilePicture,
    this.task,
    this.showAuthorRow: true,
    this.showActions: true,
    this.showNotes: true,
    this.localTaskPhoto: false,
    this.initialShowAll: false,
    this.sharing: false,
    this.onScreenshotReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenshotKey = GlobalKey();
    if (onScreenshotReady != null)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onScreenshotReady(screenshotKey);
      });
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              0,
              0,
              0,
              .12,
            ),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 8,
                color: HexColor.fromHex(task.stackColor),
              ),
              bottom: BorderSide(width: 0),
              right: BorderSide(width: 0),
              top: BorderSide(width: 0),
            ),
            color: Theme.of(context).backgroundColor,
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RepaintBoundary(
                key: screenshotKey,
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showAuthorRow)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 20.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TaskFeedHeader(
                                  userID: task.userID,
                                  name: name,
                                  profilePicture: profilePicture,
                                  creationDate: task.creationDate,
                                ),
                              ),
                              if (task.userID == getCurrentUser().uid)
                                TaskFeedTopActions(
                                  task: task,
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              task.goalTitle,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            Expanded(
                              child: Text(
                                task.stackTitle,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        task.title,
                        style: TextStyle(
                          color: Color(0xFF3B404A),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.taskPhoto != null)
                        Container(
                          margin: EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: localTaskPhoto
                                  ? FileImage(File(task.taskPhoto))
                                  : CachedImageProvider(
                                      task.taskPhoto,
                                    ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                            onTap: () => Get.to(
                              () => AppPhotoView(
                                imageProvider: localTaskPhoto
                                    ? FileImage(File(task.taskPhoto))
                                    : CachedImageProvider(
                                        task.taskPhoto,
                                      ),
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                            ),
                          ),
                        ),
                      if (sharing && task.repetition != null)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          child: Text(
                            '${task.completionRate}% completion  |  ${task.maxStreak} days streak',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF767C8D),
                            ),
                          ),
                        ),
                      if (sharing && task.repetition != null)
                        TaskProgressIndicator(
                          dueDates: task.dueDates,
                          donesHistory: task.donesHistory,
                        ),
                    ],
                  ),
                ),
              ),
              if (showActions)
                TaskFeedArticleActions(
                  task: task,
                  screenshotKey: screenshotKey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
