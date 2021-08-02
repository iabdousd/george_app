import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/shared/sharing/sharing_task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/recurring_task_article.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

import 'add_post_photo.dart';

class SharePost extends StatefulWidget {
  final Task task;
  SharePost({Key key, this.task}) : super(key: key);

  @override
  _SharePostState createState() => _SharePostState();
}

class _SharePostState extends State<SharePost> {
  Task task;
  GlobalKey screenshotKey;
  bool localTaskPhoto = false;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Post'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          children: [
            if (task.repetition != null)
              RecurringTaskArticleWidget(
                name: task.userName,
                profilePicture: task.userPhoto,
                showAuthorRow: true,
                task: task,
                showActions: false,
                sharing: true,
                showNotes: false,
                localTaskPhoto: localTaskPhoto,
                onScreenshotReady: (screenshotKey) =>
                    this.screenshotKey = screenshotKey,
              )
            else
              OnetimeTaskArticleWidget(
                name: task.userName,
                profilePicture: task.userPhoto,
                showAuthorRow: true,
                task: task,
                showActions: false,
                showNotes: false,
                localTaskPhoto: localTaskPhoto,
                onScreenshotReady: (screenshotKey) =>
                    this.screenshotKey = screenshotKey,
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  if (task.userID == getCurrentUser().uid)
                    Expanded(
                      child: AppActionButton(
                        onPressed: addPhoto,
                        label: 'Add Photo',
                        icon: Icons.image_search_rounded,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                  if (task.userID == getCurrentUser().uid) SizedBox(width: 16),
                  Expanded(
                    child: AppActionButton(
                      onPressed: sharePost,
                      label: 'Share',
                      icon: Icons.share_rounded,
                      margin: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  sharePost() {
    shareTask(task, screenshotKey);
  }

  addPhoto() {
    Get.to(
      () => AddPostPhoto(
        task: widget.task,
      ),
    ).then(
      (value) {
        if (value != null && value is Task)
          setState(() {
            task = value.copyWith(
              userID: widget.task.userID,
              userName: widget.task.userName,
              userPhoto: widget.task.userPhoto,
            );
            localTaskPhoto = true;
          });
      },
    );
  }
}
