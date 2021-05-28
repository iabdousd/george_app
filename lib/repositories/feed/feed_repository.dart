import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/feed.dart' as feed_constants;

class FeedRepository {
  static Stream<List<Task>> fetchUserArticles(String uid) {
    return FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .where(
          feed_constants.USER_ID_KEY,
          isEqualTo: uid,
        )
        .orderBy(
          feed_constants.CREATION_DATE_KEY,
          descending: true,
        )
        .snapshots()
        .asyncMap(
      (event) async {
        List<Task> tasks = [];
        for (final doc in event.docs) {
          Task task = Task.fromJson(
            doc.data(),
            id: doc.id,
          );
          if (task.userID != getCurrentUser().uid) {
            final user = UserModel.fromMap(
              (await FirebaseFirestore.instance
                      .collection(USERS_KEY)
                      .doc(task.userID)
                      .get())
                  .data(),
            );
            task.userName = user.fullName;
            task.userPhoto = user.photoURL;
          } else {
            task.userName = getCurrentUser().displayName;
            task.userPhoto = getCurrentUser().photoURL;
          }
          task.isLiked = FirebaseFirestore.instance
              .collection(feed_constants.FEED_KEY)
              .doc(task.id)
              .collection(feed_constants.FEED_LIKES_COLLECTION)
              .doc(getCurrentUser().uid)
              .snapshots()
              .map(
                (event) => event.exists && event.data() != null,
              );

          tasks.add(task);
        }
        return tasks;
      },
    );
  }

  static Stream<List<Task>> fetchArticles() {
    return FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .where(
          feed_constants.TO_KEY,
          arrayContainsAny: ['*', getCurrentUser().uid],
        )
        .orderBy(
          feed_constants.CREATION_DATE_KEY,
          descending: true,
        )
        .snapshots()
        .asyncMap(
          (event) async {
            List<Task> tasks = [];
            for (final doc in event.docs) {
              Task task = Task.fromJson(
                doc.data(),
                id: doc.id,
              );
              if (task.userID != getCurrentUser().uid) {
                final user = UserModel.fromMap(
                  (await FirebaseFirestore.instance
                          .collection(USERS_KEY)
                          .doc(task.userID)
                          .get())
                      .data(),
                );
                task.userName = user.fullName;
                task.userPhoto = user.photoURL;
              } else {
                task.userName = getCurrentUser().displayName;
                task.userPhoto = getCurrentUser().photoURL;
              }
              task.isLiked = FirebaseFirestore.instance
                  .collection(feed_constants.FEED_KEY)
                  .doc(task.id)
                  .collection(feed_constants.FEED_LIKES_COLLECTION)
                  .doc(getCurrentUser().uid)
                  .snapshots()
                  .map(
                    (event) => event.exists && event.data() != null,
                  );

              tasks.add(task);
            }
            return tasks;
          },
        );
  }

  static Future<void> likeArticle(String articleID) async {
    final likeDocument = await FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .doc(articleID)
        .collection(feed_constants.FEED_LIKES_COLLECTION)
        .doc(
          getCurrentUser().uid,
        )
        .get();
    final articleDocument = await FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .doc(articleID)
        .get();

    if (likeDocument.exists && likeDocument.data() != null) {
      await likeDocument.reference.delete();
      await articleDocument.reference.update({
        feed_constants.LIKES_COUNT_KEY:
            (articleDocument.data()[feed_constants.LIKES_COUNT_KEY] ?? 0) - 1,
      });
    } else {
      await likeDocument.reference.set({
        feed_constants.FEED_LIKE_CREATION_DATE: Timestamp.fromDate(
          DateTime.now(),
        ),
        feed_constants.FEED_LIKE_USER_ID: getCurrentUser().uid,
      });
      await articleDocument.reference.update({
        feed_constants.LIKES_COUNT_KEY:
            (articleDocument.data()[feed_constants.LIKES_COUNT_KEY] ?? 0) + 1,
      });
    }
  }

  static Future<void> commentOnArticle(Task task, String comment) async {
    Note note = Note(
      userID: getCurrentUser().uid,
      content: comment,
      goalRef: task.goalRef,
      stackRef: task.stackRef,
      taskRef: task.id,
      taskTitle: task.title,
      creationDate: DateTime.now(),
    );

    await note.save();
    final articleDocument = await FirebaseFirestore.instance
        .collection(feed_constants.FEED_KEY)
        .doc(task.id)
        .get();
    await articleDocument.reference.update({
      feed_constants.COMMENTS_COUNT_KEY:
          (articleDocument.data()[feed_constants.COMMENTS_COUNT_KEY] ?? 0) + 1,
    });
  }
}
