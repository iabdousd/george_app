import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/config/app_preferences.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/actiivity/task_activities_view/task_activities_view.dart';
import 'package:stackedtasks/views/feed/add_post_photo.dart';
import 'package:stackedtasks/views/feed/share_post.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class TaskFeedArticleActions extends StatefulWidget {
  final Task task;
  final GlobalKey screenshotKey;
  const TaskFeedArticleActions({
    Key key,
    @required this.task,
    @required this.screenshotKey,
  }) : super(key: key);

  @override
  _TaskFeedArticleActionsState createState() => _TaskFeedArticleActionsState();
}

class _TaskFeedArticleActionsState extends State<TaskFeedArticleActions> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StreamBuilder<bool>(
          stream: widget.task.isLiked,
          builder: (context, snapshot) {
            final liked = snapshot.data ?? false;
            return InkWell(
              onTap: likeTask,
              child: Badge(
                showBadge: widget.task.likesCount > 0,
                badgeColor: Theme.of(context).primaryColor,
                badgeContent: Container(
                  width: 12,
                  height: 12,
                  alignment: Alignment.center,
                  child: Text(
                    widget.task.likesCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 12,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          },
        ),
        StreamBuilder<int>(
          stream: widget.task.commentsCount,
          builder: (context, snapshot) {
            final commentsCount = snapshot.data ?? 0;
            final lastCommentsCount = AppPreferences.preferences
                .getInt('${widget.task.id}_comments_count');
            return InkWell(
              onTap: () => commentOnTask(
                context,
                commentsCount,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Badge(
                  showBadge: commentsCount != lastCommentsCount,
                  badgeColor: Theme.of(context).primaryColor,
                  position: BadgePosition.topEnd(
                    top: .25,
                    end: .25,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/icons/activity2.svg',
                  ),
                ),
              ),
            );
          },
        ),
        InkWell(
          onTap: handleShare,
          child: SvgPicture.asset(
            'assets/images/icons/share.svg',
          ),
        ),
      ],
    );
  }

  handleShare() {
    showMaterialModalBottomSheet(
      context: Get.context,
      backgroundColor: Colors.transparent,
      expand: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.task.userID == getCurrentUser().uid)
                AppActionButton(
                  onPressed: () => widget.task
                      .saveAsFeed(
                        widget.task.to.contains("*")
                            ? widget.task.partnersIDs
                            : ['*', ...widget.task.to],
                      )
                      .then(
                        (value) => Get.back(),
                      ),
                  icon: Icons.public_rounded,
                  label: widget.task.to.contains('*')
                      ? 'Make Private'
                      : 'Make Public on Stacked Tasks',
                  backgroundColor: Theme.of(context).backgroundColor,
                  textStyle: Theme.of(context).textTheme.subtitle1,
                  iconColor: Theme.of(context).primaryColor,
                  shadows: [],
                  margin: EdgeInsets.only(bottom: 0, top: 4),
                  iconSize: 28,
                ),
              if (widget.task.userID == getCurrentUser().uid)
                AppActionButton(
                  onPressed: addPhotoForPost,
                  icon: Icons.add_a_photo_rounded,
                  label: 'Add photo for the post',
                  backgroundColor: Theme.of(context).backgroundColor,
                  textStyle: Theme.of(context).textTheme.subtitle1,
                  iconColor: Theme.of(context).primaryColor,
                  shadows: [],
                  margin: EdgeInsets.only(bottom: 0, top: 4),
                  iconSize: 28,
                ),
              AppActionButton(
                onPressed: () => Get.to(
                  () => SharePost(
                    task: widget.task,
                  ),
                ),
                icon: Icons.share_rounded,
                label: 'Share in another App',
                backgroundColor: Theme.of(context).backgroundColor,
                textStyle: Theme.of(context).textTheme.subtitle1,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 0, top: 4),
                iconSize: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void likeTask() async {
    await FeedRepository.likeArticle(widget.task.id);
  }

  void commentOnTask(BuildContext context, int commentsCount) async {
    AppPreferences.preferences.setInt(
      '${widget.task.id}_comments_count',
      commentsCount,
    );
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActivitiesView(
        task: widget.task,
      ),
    ).then((value) => mounted
        ? setState(
            () {},
          )
        : null);
  }

  addPhotoForPost() {
    Get.back();
    Get.to(
      () => AddPostPhoto(
        task: widget.task,
      ),
    );
  }
}
