import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/not_found.dart';
import 'package:stackedtasks/widgets/task/task_tile_widget/task_list_tile_widget.dart';

class TasksTimerList extends StatefulWidget {
  TasksTimerList({Key key}) : super(key: key);

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
            .collection(stack_constants.TASKS_KEY)
            .where(
              task_constants.USER_ID_KEY,
              isEqualTo: getCurrentUser().uid,
            )
            .where(
              task_constants.DUE_DATES_KEY,
              arrayContains: DateTime.utc(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
            )
            .where(
              task_constants.END_TIME_KEY,
              isGreaterThan: DateTime(
                1970,
                1,
                1,
                DateTime.now().hour,
                DateTime.now().minute + 1,
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
          if (snapshot.hasData) if (snapshot.data.docs.isNotEmpty) {
            Task firstTask = Task.fromJson(
              snapshot.data.docs[0].data(),
              id: snapshot.data.docs[0].id,
            );
            if (firstTask.endTime ==
                DateTime(
                  1970,
                  1,
                  1,
                  DateTime.now().hour,
                  DateTime.now().minute,
                )) {
              if (snapshot.data.docs.length > 2) {
                firstTask = Task.fromJson(
                  snapshot.data.docs[1].data(),
                  id: snapshot.data.docs[1].id,
                );
              } else {
                firstTask = null;
              }
            }
            if (firstTask != null) {
              Future.delayed(
                firstTask.startTime.isBefore(DateTime(
                          1970,
                          1,
                          1,
                          DateTime.now().hour,
                          DateTime.now().minute,
                        )) ||
                        firstTask.startTime ==
                            DateTime(
                              1970,
                              1,
                              1,
                              DateTime.now().hour,
                              DateTime.now().minute,
                            )
                    ? firstTask.endTime
                        .difference(DateTime(
                          1970,
                          1,
                          1,
                          DateTime.now().hour,
                          DateTime.now().minute,
                        ))
                        .abs()
                    : firstTask.startTime
                        .difference(DateTime(
                          1970,
                          1,
                          1,
                          DateTime.now().hour,
                          DateTime.now().minute,
                        ))
                        .abs(),
              ).then(
                (value) => mounted
                    ? setState(() {
                        print('SET STATED');
                      })
                    : null,
              );
            }

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              padding: EdgeInsets.only(top: 16, bottom: 12),
              itemBuilder: (context, index) {
                Task task = Task.fromJson(
                  snapshot.data.docs[index].data(),
                  id: snapshot.data.docs[index].id,
                );

                return Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (index == 0 &&
                          task.startTime.hour + task.startTime.minute / 60 >
                              DateTime.now().hour + DateTime.now().minute / 60)
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
                          height: kIsWeb
                              ? 536
                              : 2 * MediaQuery.of(context).size.width / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No current task',
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
                                  DateTime.now().minute / 60 &&
                          snapshot.data.size > 0)
                        Container(
                          padding: EdgeInsets.only(
                            top: 24,
                            left: 0,
                            bottom: 8,
                          ),
                          child: Text(
                            'Upcoming tasks:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB2B5C3),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      TaskListTileWidget(
                        task: task,
                        stackColor: task.stackColor,
                        enforcedDate: now,
                        showHirachy: index == 0 &&
                            task.startTime.isBefore(
                              DateTime(1970, 1, 1, now.hour, now.minute + 1),
                            ),
                        showPartners: true,
                        showTimer: index == 0 &&
                            task.startTime.isBefore(
                              DateTime(1970, 1, 1, now.hour, now.minute + 1),
                            ),
                        showDescription: true,
                        showNoteInput: index == 0 &&
                            task.startTime.isBefore(
                              DateTime(1970, 1, 1, now.hour, now.minute + 1),
                            ),
                        showDragIndicator: false,
                        onAccomplishmentEvent: () => setState(
                          () {},
                        ),
                      ),
                      if (index == 0 &&
                          snapshot.data.docs.length > 1 &&
                          task.startTime.hour + task.startTime.minute / 60 <=
                              now.hour + now.minute / 60)
                        Container(
                          padding: EdgeInsets.only(
                            top: 24,
                            left: 0,
                            bottom: 8,
                          ),
                          child: Text(
                            'Upcoming tasks:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB2B5C3),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          } else {
            return NotFoundErrorWidget(
              title: 'No current tasks',
              message: 'You don\'t have any scheduled tasks for today!',
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return AppErrorWidget();
          }
          return LoadingWidget();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
