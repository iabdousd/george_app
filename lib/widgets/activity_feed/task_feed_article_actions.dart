import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/shared/sharing/sharing_task.dart';
import 'package:george_project/views/feed/save_task_feed_article.dart';

class TaskFeedArticleActions extends StatelessWidget {
  final Task task;
  const TaskFeedArticleActions({Key key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // border: Border(
          //   top: BorderSide(
          //     width: 1,
          //     color: Color(0x22000000),
          //   ),
          // ),
          ),
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
              onTap: () => _showMoreOptions(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.more_horiz_outlined,
                      size: 18,
                      color: Colors.black38,
                    ),
                    Text(
                      ' See more',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => shareTask(task),
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

  _showMoreOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                onTap: () async {
                  Navigator.pop(context);
                  await task.deleteAsFeed();
                  showFlushBar(
                    title: 'Feed deleted',
                    message: 'This feed was deleted successfully!',
                    success: true,
                  );
                },
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
              )
            ],
          ),
        );
      },
    );
  }
}
