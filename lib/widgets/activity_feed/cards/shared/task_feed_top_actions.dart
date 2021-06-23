import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/views/feed/save_task_feed_article.dart';

class TaskFeedTopActions extends StatelessWidget {
  final Task task;
  const TaskFeedTopActions({
    Key key,
    @required this.task,
  }) : super(key: key);

  void handleClick(String action) {
    if (action == 'delete') {
      showDialog(
        context: Get.context,
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
      );
    } else if (action == 'edit') {
      Get.to(
        () => SaveTaskFeedArticle(
          task: task,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<String>(
        onSelected: handleClick,
        icon: Icon(
          Icons.more_vert_rounded,
          size: 18,
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ];
        },
      ),
    );
  }
}
