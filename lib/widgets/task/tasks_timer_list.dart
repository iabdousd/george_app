import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/models/Note.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/task/task_list_tile_widget.dart';
import 'package:intl/intl.dart';

class TasksTimerList extends StatefulWidget {
  final Function(Task) emitFirstTask;
  TasksTimerList({Key key, @required this.emitFirstTask}) : super(key: key);

  @override
  _TasksTimerListState createState() => _TasksTimerListState();
}

class _TasksTimerListState extends State<TasksTimerList>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(user_constants.USERS_KEY)
              .doc(getCurrentUser().uid)
              .collection(stack_constants.TASKS_KEY)
              .where(
                task_constants.DUE_DATES_KEY,
                arrayContains: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day),
              )
              .where(
                task_constants.END_TIME_KEY,
                isGreaterThan: DateTime(
                  1970,
                  1,
                  1,
                  DateTime.now().hour,
                  DateTime.now().minute,
                ),
              )
              .orderBy(
                task_constants.END_TIME_KEY,
                descending: false,
              )
              .orderBy(
                task_constants.START_TIME_KEY,
                descending: false,
              )
              .orderBy(
                task_constants.ANY_TIME_KEY,
                descending: false,
              )
              .snapshots(),
          builder: (context, snapshot) {
            final DateTime now = DateTime.now();
            if (snapshot.hasData) if (snapshot.data.docs.isNotEmpty)
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 12),
                itemBuilder: (context, index) {
                  Task task = Task.fromJson(
                    snapshot.data.docs[index].data(),
                    id: snapshot.data.docs[index].id,
                  );
                  if (index == 0) {
                    widget.emitFirstTask(task);
                  }
                  return Container(
                    padding:
                        //  index == 0
                        //     ? EdgeInsets.zero
                        //     :
                        EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 0 &&
                            task.startTime.hour + task.startTime.minute / 60 >
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: 16,
                            ),
                            child: Text(
                              'Next Tasks:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (index == 0 &&
                            task.startTime.hour + task.startTime.minute / 60 <
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                            ),
                            child: Text(
                              'Current task:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        TaskListTileWidget(
                          task: task,
                          stackColor: task.stackColor,
                          enforcedDate: now,
                          showTimer: index == 0 &&
                              task.startTime.isBefore(
                                DateTime(1970, 1, 1, now.hour, now.minute),
                              ),
                          showDescription: index == 0,
                        ),
                        if (index == 0)
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            child: TextField(
                              controller: _contentController,
                              decoration: InputDecoration(
                                labelText: 'Task Notes',
                                hintText: 'The content of the note',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 20.0,
                                ),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(width: 1),
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              minLines: 3,
                              maxLines: 5,
                              onSubmitted: (text) async {
                                if (text.replaceAll('\n', '').trim() == '')
                                  return;
                                Note note = Note(
                                  content: text,
                                  goalRef: task.goalRef,
                                  stackRef: task.stackRef,
                                  taskRef: task.id,
                                  taskTitle: task.title,
                                  creationDate: DateTime.now(),
                                );
                                await note.save();
                                await task.addNote(note.id);
                                _contentController.text = '';
                                showFlushBar(
                                    title: 'Note added successfully!',
                                    message:
                                        'You can now see your note in notes list.');
                              },
                            ),
                          ),
                        if (index == 0 &&
                            snapshot.data.docs.length > 1 &&
                            task.startTime.hour + task.startTime.minute / 60 <=
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: 16,
                            ),
                            child: Text(
                              'Next Tasks:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            else {
              widget.emitFirstTask(null);
              return Container(
                  // padding: const EdgeInsets.all(16.0),
                  // child: AppErrorWidget(
                  //   customMessage:
                  //       'You don\' have tasks on ${DateFormat("dd MMMM").format(now)}',
                  // ),
                  );
            }
            return LoadingWidget();
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
