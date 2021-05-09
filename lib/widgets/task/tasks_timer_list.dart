import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/task/task_list_tile_widget.dart';

class TasksTimerList extends StatefulWidget {
  final Function(Task) emitFirstTask;
  TasksTimerList({Key key, @required this.emitFirstTask}) : super(key: key);

  @override
  _TasksTimerListState createState() => _TasksTimerListState();
}

class _TasksTimerListState extends State<TasksTimerList>
    with AutomaticKeepAliveClientMixin {
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
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 0)
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                            ),
                            child: Text(
                              'Current task:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (index == 0 &&
                            task.startTime.hour + task.startTime.minute / 60 >
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            height: 2 * MediaQuery.of(context).size.width / 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No task',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        if (index == 0 &&
                            task.startTime.hour + task.startTime.minute / 60 >
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            padding: EdgeInsets.only(
                              top: 24,
                              left: 0,
                            ),
                            child: Text(
                              'Next Tasks:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        // else if (index == 0 &&
                        //     task.startTime.hour + task.startTime.minute / 60 <
                        //         DateTime.now().hour +
                        //             DateTime.now().minute / 60)
                        TaskListTileWidget(
                          task: task,
                          stackColor: task.stackColor,
                          enforcedDate: now,
                          showHirachy: true,
                          showTimer: index == 0 &&
                              task.startTime.isBefore(
                                DateTime(1970, 1, 1, now.hour, now.minute),
                              ),
                          showNoteInput: index == 0 &&
                              task.startTime.isBefore(
                                DateTime(1970, 1, 1, now.hour, now.minute),
                              ),
                          showDescription: true,
                          showLastNote: index == 0 &&
                              task.startTime.isBefore(
                                DateTime(1970, 1, 1, now.hour, now.minute),
                              ),
                        ),
                        if (index == 0 &&
                            snapshot.data.docs.length > 1 &&
                            task.startTime.hour + task.startTime.minute / 60 <=
                                DateTime.now().hour +
                                    DateTime.now().minute / 60)
                          Container(
                            padding: EdgeInsets.only(
                              top: 24,
                              left: 0,
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
