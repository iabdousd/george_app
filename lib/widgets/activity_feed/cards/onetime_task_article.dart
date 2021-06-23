import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/shared/task_feed_article_actions.dart';
import 'package:stackedtasks/widgets/note/task_notes_thread.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

import 'shared/task_feed_header.dart';
import 'shared/task_feed_top_actions.dart';

class OnetimeTaskArticleWidget extends StatelessWidget {
  final String name, profilePicture;
  final Task task;
  final bool showAuthorRow,
      showActions,
      showNotes,
      localTaskPhoto,
      initialShowAll;

  const OnetimeTaskArticleWidget({
    Key key,
    this.name,
    this.profilePicture,
    this.task,
    this.showAuthorRow: true,
    this.showActions: true,
    this.showNotes: true,
    this.localTaskPhoto: false,
    this.initialShowAll: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenshotKey = GlobalKey();
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
          RepaintBoundary(
            key: screenshotKey,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showAuthorRow)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TaskFeedHeader(
                            userID: task.userID,
                            name: name,
                            profilePicture: profilePicture,
                          ),
                        ),
                        TaskFeedTopActions(
                          task: task,
                        ),
                      ],
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
                  if (task.taskPhoto != null)
                    Container(
                      margin: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 6,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: localTaskPhoto
                              ? FileImage(
                                  File(task.taskPhoto),
                                )
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
                  if (task.description != '')
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 6,
                      ),
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
          if (showActions)
            TaskFeedArticleActions(
              task: task,
              screenshotKey: screenshotKey,
            ),
          if (showNotes)
            Container(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: TaskNotesThread(
                task: task.copyWith(
                  id: task.taskID,
                ),
                initialShowAll: initialShowAll,
              ),
            ),
        ],
      ),
    );
  }
}
