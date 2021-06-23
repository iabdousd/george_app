import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/models/Note.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/repositories/note/note_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/shared/sharing/sharing_task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/feed/add_post_photo.dart';
import 'package:stackedtasks/widgets/note/note_thread_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

class TaskFeedArticleActions extends StatelessWidget {
  final Task task;
  final GlobalKey screenshotKey;
  const TaskFeedArticleActions({
    Key key,
    @required this.task,
    @required this.screenshotKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<bool>(
              stream: task.isLiked,
              builder: (context, snapshot) {
                final liked = snapshot.data ?? false;
                return InkWell(
                  onTap: likeTask,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          task.likesCount.toString(),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<int>(
              stream: task.commentsCount,
              builder: (context, snapshot) {
                final commentsCount = snapshot.data ?? 0;
                return InkWell(
                  onTap: () => commentOnTask(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          commentsCount.toString(),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // if (task.userID == getCurrentUser().uid ||
          //     (task.partnersIDs ?? []).contains(getCurrentUser().uid))
          //

          Expanded(
            child: InkWell(
              onTap: handleShare,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.black38,
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
              if (task.userID == getCurrentUser().uid)
                AppActionButton(
                  onPressed: () => task
                      .saveAsFeed(
                        task.to.contains("*")
                            ? task.partnersIDs
                            : ['*', ...task.to],
                      )
                      .then(
                        (value) => Get.back(),
                      ),
                  icon: Icons.public_rounded,
                  label: task.to.contains('*')
                      ? 'Make Private'
                      : 'Make Public on Stacked Tasks',
                  backgroundColor: Theme.of(context).backgroundColor,
                  textStyle: Theme.of(context).textTheme.subtitle1,
                  iconColor: Theme.of(context).primaryColor,
                  shadows: [],
                  margin: EdgeInsets.only(bottom: 0, top: 4),
                  iconSize: 28,
                ),
              if (task.userID == getCurrentUser().uid)
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
                onPressed: () => shareTask(task, screenshotKey),
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
    await FeedRepository.likeArticle(task.id);
  }

  void commentOnTask(BuildContext context) async {
    final _commentController = TextEditingController();

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: true,
      builder: (context) {
        bool loading = false;
        return SafeArea(
          bottom: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Comments:',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            InkWell(
                              child: Icon(Icons.close),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<Note>>(
                          stream: NoteRepository.streamFeedComments(task),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: AppErrorWidget(),
                              );
                            }
                            if (snapshot.hasData) if (snapshot.data.isEmpty)
                              return Center(
                                child: Text('No comments yet!'),
                              );
                            else
                              return ListView.builder(
                                itemCount: snapshot.data.length,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final note = snapshot.data[index];

                                  return NoteThreadTile(
                                    key: Key(note.id),
                                    note: note,
                                    index: index,
                                    isLast: index != snapshot.data.length - 1,
                                    showAll: true,
                                  );
                                },
                              );
                            return Center(
                              child: LoadingWidget(),
                            );
                          },
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _commentController,
                                  label: null,
                                  hint: 'Type your comment here',
                                  minLines: 1,
                                  maxLines: 3,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              loading
                                  ? Container(
                                      width: 42,
                                      height: 42,
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor,
                                        ),
                                        strokeWidth: 1,
                                      ))
                                  : IconButton(
                                      icon: Icon(Icons.send_rounded),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        if (_commentController.text
                                                .replaceAll('\n', '')
                                                .trim() ==
                                            '') return;
                                        setState(() => loading = true);

                                        await FeedRepository.commentOnArticle(
                                          task,
                                          _commentController.text.trim(),
                                        );

                                        _commentController.text = '';
                                        setState(() => loading = false);
                                        showFlushBar(
                                          title: 'Note added successfully!',
                                          message:
                                              'You can now see your note in notes list.',
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  addPhotoForPost() {
    Get.back();
    Get.to(
      () => AddPostPhoto(
        task: task,
      ),
    );
  }
}
