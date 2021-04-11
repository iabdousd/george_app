import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:plandoraslist/models/Task.dart';
import 'package:plandoraslist/services/feed-back/flush_bar.dart';
import 'package:plandoraslist/services/shared/sharing/sharing_task.dart';
import 'package:plandoraslist/views/feed/save_task_feed_article.dart';
import 'package:screenshot/screenshot.dart';

class TaskFeedArticleActions extends StatelessWidget {
  final Task task;
  final ScreenshotController screenshotController;
  const TaskFeedArticleActions(
      {Key key, @required this.task, @required this.screenshotController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.to(
                () => SaveTaskFeedArticle(
                  task: task,
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.black38,
                    ),
                    Text(
                      ' Edit',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Article'),
                  content: Text(
                    'Are you sure you want to delete the article \"${task.title}\" ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await task.deleteAsFeed();
                        showFlushBar(
                          title: 'Feed deleted',
                          message: 'This feed was deleted successfully!',
                          success: true,
                        );
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red[700],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.black38,
                    ),
                    Text(
                      ' Delete',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => shareTask(task, screenshotController),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.black38,
                    ),
                    Text(
                      ' Share',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
