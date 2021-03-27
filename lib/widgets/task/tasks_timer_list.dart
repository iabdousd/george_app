import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/task/task_list_tile_widget.dart';

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
            print(snapshot.data);
            final DateTime now = DateTime.now();
            if (snapshot.hasData) if (snapshot.data.docs.isNotEmpty)
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Task task = Task.fromJson(
                    snapshot.data.docs[index].data(),
                    id: snapshot.data.docs[index].id,
                  );
                  if (index == 0) {
                    widget.emitFirstTask(task);
                  }
                  return Container(
                    padding: index == 0
                        ? EdgeInsets.zero
                        : EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TaskListTileWidget(
                          task: task,
                          stackColor: task.stackColor,
                          enforcedDate: now,
                          shotTimer: index == 0 &&
                              task.startTime.isBefore(
                                DateTime(1970, 1, 1, now.hour, now.minute),
                              ),
                        ),
                        if (index == 0 && snapshot.data.docs.length > 1)
                          Container(
                            padding: EdgeInsets.only(
                              top: 32,
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
