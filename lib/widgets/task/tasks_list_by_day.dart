import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/task/task_list_tile_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TasksListByDay extends StatelessWidget {
  final DateTime day;
  final bool fullScreen;
  TasksListByDay({Key key, @required this.day, this.fullScreen: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fullScreen)
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(user_constants.USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(stack_constants.TASKS_KEY)
            .where(
              task_constants.DUE_DATES_KEY,
              arrayContains: DateTime(day.year, day.month, day.day),
            )
            .orderBy(
              task_constants.START_TIME_KEY,
            )
            .snapshots(),
        builder: (context, snapshot) {
          List<Task> tasks = [];
          if (snapshot.hasData && snapshot.data.docs.length > 0)
            tasks = snapshot.data.docs
                .map(
                  (e) => Task.fromJson(e.data(), id: e.id),
                )
                .toList();
          final now = DateTime.now();

          return DayView(
            date: day,
            dayBarStyle: DayBarStyle(
              dateFormatter: (year, month, day) =>
                  DateFormat('EEE, dd MMM').format(
                DateTime(year, month, day),
              ),
              color: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              textAlignment: Alignment.centerLeft,
            ),
            style: DayViewStyle(
              backgroundColor: Theme.of(context).backgroundColor,
              headerSize: 60,
              backgroundRulesColor: Color(0x88000000),
            ),
            initialTime: HourMinute(hour: day.hour, minute: day.minute),
            events: tasks
                .map((e) => FlutterWeekViewEvent(
                      start: DateTime(
                        day.year,
                        day.month,
                        day.day,
                        e.anyTime ? 0 : e.startTime.hour,
                        e.anyTime ? 0 : e.startTime.minute,
                      ),
                      end: e.anyTime
                          ? DateTime(
                              day.year,
                              day.month,
                              day.day,
                              1,
                              0,
                            )
                          : DateTime(
                              day.year,
                              day.month,
                              day.day,
                            ).add(Duration(
                              minutes: max(
                                e.startTime.hour * 60 + 60 + e.startTime.minute,
                                e.endTime.hour * 60 + e.endTime.minute,
                              ),
                            )),
                      title: e.title,
                      description: e.description,
                      onTap: () => Get.to(
                        () => SaveTaskPage(
                          goalRef: e.goalRef,
                          stackRef: e.stackRef,
                          goalTitle: e.goalTitle,
                          stackTitle: e.stackTitle,
                          stackColor: e.stackColor,
                          task: e,
                        ),
                      ),
                      margin: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                  e.startTime.hour,
                                  e.startTime.minute,
                                ).isBefore(now) &&
                                DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                  e.endTime.hour,
                                  e.endTime.minute,
                                ).isAfter(now) &&
                                !e.anyTime
                            ? HexColor.fromHex(e.stackColor).lighten()
                            : DateTime(
                                      day.year,
                                      day.month,
                                      day.day,
                                      e.endTime.hour,
                                      e.endTime.minute,
                                    ).isBefore(now) &&
                                    !e.anyTime
                                ? HexColor.fromHex(e.stackColor).darken()
                                : Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          width: 1,
                          color: HexColor.fromHex(e.stackColor),
                        ),
                      ),
                      eventTextBuilder: (event, ctx, dayView, width, height) {
                        return Container(
                          child: Text(
                            event.title,
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: DateTime(
                                                event.end.year,
                                                event.end.month,
                                                event.end.day,
                                                event.end.hour,
                                                event.end.minute,
                                              ).isBefore(now) &&
                                              !e.anyTime
                                          ? Colors.white
                                          : Colors.black87,
                                      decoration: e.isDone(date: day)
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      fontStyle: e.isDone(date: day)
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                            overflow: TextOverflow.clip,
                          ),
                        );
                      },
                    ))
                .toList(),
          );
        },
      );

    return Container(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 12.0,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Text(
            'Upcoming',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(user_constants.USERS_KEY)
                .doc(getCurrentUser().uid)
                .collection(stack_constants.TASKS_KEY)
                .where(
                  task_constants.DUE_DATES_KEY,
                  arrayContains: DateTime(day.year, day.month, day.day),
                )
                .orderBy(
                  task_constants.START_TIME_KEY,
                )
                .snapshots(),
            builder: (context, snapshot) {
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
                    return TaskListTileWidget(
                      task: task,
                      stackColor: task.stackColor,
                      enforcedDate: day,
                    );
                  },
                );
              else
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: AppErrorWidget(
                    customMessage:
                        'You don\' have tasks on ${DateFormat("dd MMMM").format(day)}',
                  ),
                );
              return LoadingWidget();
            },
          ),
        ],
      ),
    );
  }
}
