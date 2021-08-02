import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stackedtasks/config/app_preferences.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/note/note_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/note/note_thread_tile.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

class TaskComments extends StatelessWidget {
  final Task task;
  TaskComments({
    Key key,
    @required this.task,
  }) : super(key: key);

  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Comments',
            style: TextStyle(
              color: Color(0xFF3B404A),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Note>>(
            stream: NoteRepository.streamFeedComments(task),
            builder: (context, snapshot) {
              print(snapshot.error);
              if (snapshot.hasData) {
                if (snapshot.data.isEmpty)
                  return Center(
                    child: Text(
                      'No comments, be the first one to send a comment!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF767C8D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                final notes = snapshot.data;
                return ListView.builder(
                  itemCount: notes.length,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return NoteThreadTile(
                      note: notes[index],
                    );
                  },
                );
              } else
                return LoadingWidget();
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _commentController,
                hint: 'Type something...',
                containerDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Color.fromRGBO(241, 240, 243, 1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(22.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ),
            InkWell(
              onTap: _sendComment,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).primaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.send_rounded,
                  color: Theme.of(context).backgroundColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendComment() async {
    if (_commentController.text.replaceAll('\n', '').trim().isEmpty) {
      return;
    }
    toggleLoading(state: true);
    Note note = Note(
      userID: getCurrentUser().uid,
      status: 0,
      content: _commentController.text.trim(),
      goalRef: task.goalRef,
      stackRef: task.stackRef,
      taskRef: task.taskID,
      feedArticleID: task.id,
      taskTitle: task.title,
      creationDate: DateTime.now(),
    );
    await note.save();

    final articleDocument = await FirebaseFirestore.instance
        .collection(TASKS_KEY)
        .doc(task.taskID)
        .get();

    await articleDocument.reference.update({
      COMMENTS_COUNT_KEY: (articleDocument.data()[COMMENTS_COUNT_KEY] ?? 0) + 1,
    });

    await AppPreferences.preferences.setInt(
      '${task.id}_comments_count',
      (AppPreferences.preferences.getInt('${task.id}_comments_count') ?? 0) + 1,
    );
    _commentController.text = '';

    toggleLoading(state: false);
    showFlushBar(
      title: 'Note added successfully!',
      message: 'You can now see your note in notes list.',
    );
  }
}
