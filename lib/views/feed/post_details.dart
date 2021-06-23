import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/article_skeleton.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/recurring_task_article.dart';

class PostDetails extends StatefulWidget {
  final Task task;
  PostDetails({Key key, this.task}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  bool loading = true;
  Task task;

  _init() async {
    task = widget.task;
    final user = await UserService.getUser(task.userID);

    task.isLiked = FirebaseFirestore.instance
        .collection(FEED_KEY)
        .doc(task.id)
        .collection(FEED_LIKES_COLLECTION)
        .doc(getCurrentUser().uid)
        .snapshots()
        .map(
          (event) => event.exists && event.data() != null,
        );
    task.commentsCount = FirebaseFirestore.instance
        .collection(TASKS_KEY)
        .doc(task.taskID)
        .snapshots()
        .map(
          (event) => event.data()[COMMENTS_COUNT_KEY],
        );

    task.userName = user.fullName;
    task.userPhoto = user.photoURL;
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          children: [
            if (loading)
              ArticleSkeletonWidget()
            else if (task.repetition != null)
              StreamBuilder<Task>(
                  stream: FeedRepository.streamArticle(task.id),
                  initialData: task,
                  builder: (context, snapshot) {
                    Task task = snapshot.data;

                    return RecurringTaskArticleWidget(
                      name: task.userName,
                      profilePicture: task.userPhoto,
                      showAuthorRow: true,
                      task: task,
                      showActions: true,
                      showNotes: true,
                      initialShowAll: true,
                    );
                  })
            else
              StreamBuilder<Task>(
                stream: FeedRepository.streamArticle(task.id),
                initialData: task,
                builder: (context, snapshot) {
                  Task task = snapshot.data;

                  return OnetimeTaskArticleWidget(
                    name: task.userName,
                    profilePicture: task.userPhoto,
                    showAuthorRow: true,
                    task: task,
                    showActions: true,
                    showNotes: true,
                    initialShowAll: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
