import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Note.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/repositories/stack/note_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/shared/sharing/sharing_task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/feed/save_task_feed_article.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stackedtasks/widgets/note/note_thread_tile.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

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
            child: task.userID != getCurrentUser().uid
                ? StreamBuilder<bool>(
                    stream: task.isLiked,
                    builder: (context, snapshot) {
                      final liked = snapshot.data ?? false;
                      return InkWell(
                        onTap: likeTask,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
                  )
                : InkWell(
                    onTap: () => Get.to(
                      () => SaveTaskFeedArticle(
                        task: task,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            task.status == 1
                                ? Icons.ios_share
                                : Icons.edit_outlined,
                            size: 18,
                            color: task.status == 1
                                ? Theme.of(context).primaryColor
                                : Colors.black38,
                          ),
                          Text(
                            '',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: task.status == 1
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: task.userID != getCurrentUser().uid
                ? InkWell(
                    onTap: () => commentOnTask(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
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
                            task.commentsCount.toString(),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  )
                : InkWell(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.black38,
                          ),
                          // Text(
                          //   ' Delete',
                          //   style: Theme.of(context).textTheme.bodyText2,
                          // ),
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
                    // Text(
                    //   ' Share',
                    //   style: Theme.of(context).textTheme.bodyText2,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void likeTask() async {
    await FeedRepository.likeArticle(task.id);
  }

  void commentOnTask(BuildContext context) async {
    final _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (context) {
        bool loading = false;
        return StatefulBuilder(
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
                        stream: NoteRepository.streamTaskNotes(
                          task,
                          bothNotes: true,
                        ),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
