import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TasksListByWeek extends StatelessWidget {
  final DateTime day;
  final bool fullScreen;
  final Function(DateTime) updateDay;
  const TasksListByWeek({
    Key key,
    this.day,
    this.fullScreen: false,
    this.updateDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabsCount = kIsWeb ? 5 : 3;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(stack_constants.TASKS_KEY)
          .where(
            task_constants.DUE_DATES_KEY,
            arrayContainsAny: [
              for (int i = 0; i < tabsCount; i++)
                DateTime(day.year, day.month, day.day + i - tabsCount ~/ 2),
              // DateTime(day.year, day.month, day.day),
              // DateTime(day.year, day.month, day.day + tabsCount ~/ 2)
            ],
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

        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 54,
                top: 64,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < tabsCount; i++)
                    Expanded(
                      key: Key('title${i}_' + day.toString()),
                      child: InkWell(
                        onTap: () {
                          if (i != tabsCount ~/ 2) {
                            updateDay(
                              day.add(
                                Duration(days: i - tabsCount ~/ 2),
                              ),
                            );
                          }
                        },
                        child: i == tabsCount ~/ 2
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border(
                                    right: i == tabsCount - 1
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Color(0x40000000),
                                          ),
                                    bottom: BorderSide(
                                      color: Color(0x40000000),
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      DateFormat('dd').format(day.subtract(
                                          Duration(days: tabsCount ~/ 2 - i))),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            fontSize: 14,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : i < tabsCount ~/ 2
                                ? ZoomIn(
                                    duration: Duration(milliseconds: 250),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.25),
                                        borderRadius: i == 0
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              )
                                            : null,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: Text(
                                            DateFormat('dd').format(
                                                day.subtract(Duration(
                                                    days: tabsCount ~/ 2 - i))),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  fontSize: 14,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : FadeInRight(
                                    duration: Duration(milliseconds: 250),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.25),
                                        borderRadius: i == tabsCount - 1
                                            ? BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              )
                                            : null,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: Text(
                                            DateFormat('dd').format(
                                                day.subtract(Duration(
                                                    days: tabsCount ~/ 2 - i))),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  fontSize: 14,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              key: Key(day.toString()),
              child: FadeIn(
                duration: Duration(milliseconds: 750),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Row(
                    children: [
                      for (int i = 0; i < tabsCount; i++)
                        Container(
                          width: (MediaQuery.of(context).size.width - 54 - 32) /
                                  tabsCount +
                              (i == 0 ? 54 : 0),
                          child: DayView(
                            date: DateTime(day.year, day.month,
                                day.day - tabsCount ~/ 2 + i),
                            dayBarStyle: DayBarStyle(
                              dateFormatter: (year, month, day) =>
                                  DateFormat('dd').format(
                                DateTime(year, month, day),
                              ),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    color: Theme.of(context).backgroundColor,
                                  ),
                              textAlignment: Alignment.center,
                            ),
                            userZoomable: false,
                            style: DayViewStyle(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              headerSize: 0,
                              backgroundRulesColor: Color(0x88000000),
                            ),
                            hoursColumnStyle: HoursColumnStyle(
                              width: i == 0 ? 54 : 0,
                            ),
                            initialTime:
                                HourMinute(hour: day.hour, minute: day.minute),
                            inScrollableWidget: true,
                            currentTimeIndicatorBuilder: (dayViewStyle,
                                    topOffsetCalculator, hoursColumnWidth) =>
                                Container(),
                            events: tasks
                                .where((element) =>
                                    (element.repetition == null &&
                                        element.startDate ==
                                            DateTime(
                                              day.year,
                                              day.month,
                                              day.day - tabsCount ~/ 2 + i,
                                            )) ||
                                    element.dueDates.contains(DateTime(
                                      day.year,
                                      day.month,
                                      day.day - tabsCount ~/ 2 + i,
                                    )))
                                .map((e) => FlutterWeekViewEvent(
                                      start: DateTime(
                                        day.year,
                                        day.month,
                                        day.day - tabsCount ~/ 2 + i,
                                        e.anyTime ? 0 : e.startTime.hour,
                                        e.anyTime ? 0 : e.startTime.minute,
                                      ),
                                      end: e.anyTime
                                          ? DateTime(
                                              day.year,
                                              day.month,
                                              day.day - tabsCount ~/ 2 + i,
                                              1,
                                              0,
                                            )
                                          : DateTime(
                                              day.year,
                                              day.month,
                                              day.day - tabsCount ~/ 2 + i,
                                            ).add(Duration(
                                              minutes: max(
                                                e.startTime.hour * 60 +
                                                    60 +
                                                    e.startTime.minute,
                                                e.endTime.hour * 60 +
                                                    e.endTime.minute,
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
                                                  day.day - tabsCount ~/ 2 + i,
                                                  e.startTime.hour,
                                                  e.startTime.minute,
                                                ).isBefore(now) &&
                                                DateTime(
                                                  day.year,
                                                  day.month,
                                                  day.day - tabsCount ~/ 2 + i,
                                                  e.endTime.hour,
                                                  e.endTime.minute,
                                                ).isAfter(now) &&
                                                !e.anyTime
                                            ? HexColor.fromHex(e.stackColor)
                                                .lighten()
                                            : DateTime(
                                                      day.year,
                                                      day.month,
                                                      day.day -
                                                          tabsCount ~/ 2 +
                                                          i,
                                                      e.endTime.hour,
                                                      e.endTime.minute,
                                                    ).isBefore(now) &&
                                                    !e.anyTime
                                                ? HexColor.fromHex(e.stackColor)
                                                    .darken()
                                                : Theme.of(context)
                                                    .backgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          width: 1,
                                          color: HexColor.fromHex(e.stackColor),
                                        ),
                                      ),
                                      eventTextBuilder:
                                          (event, ctx, dayView, width, height) {
                                        return Container(
                                          child: Text(
                                            event.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(
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
                                                  decoration:
                                                      e.isDone(date: day)
                                                          ? TextDecoration
                                                              .lineThrough
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
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
