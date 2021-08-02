import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

class TasksDayView extends StatelessWidget {
  final DateTime day;
  final bool fullScreen;
  final Function(DateTime) updateDay;
  const TasksDayView({
    Key key,
    this.day,
    this.fullScreen: false,
    this.updateDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                day.year,
                day.month,
                day.day,
              ),
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

          return FadeInUp(
            key: Key(day.toString()),
            duration: Duration(milliseconds: 250),
            child: Container(
              width: (kIsWeb
                  ? 2 * MediaQuery.of(context).size.width / 3
                  : MediaQuery.of(context).size.width),
              child: DayView(
                date: DateTime(day.year, day.month, day.day),
                hoursColumnStyle: HoursColumnStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB2B5C3),
                  ),
                ),
                style: DayViewStyle(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  headerSize: 0,
                  hourRowHeight: 96,
                  backgroundRulesColor: Color(0xFFB2B5C3),
                ),
                initialTime: HourMinute(hour: day.hour, minute: day.minute),
                currentTimeIndicatorBuilder:
                    (dayViewStyle, topOffsetCalculator, hoursColumnWidth) =>
                        Container(),
                events: tasks
                    .map(
                      (e) => FlutterWeekViewEvent(
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
                                e.endTime.hour,
                                e.endTime.minute,
                              ),
                        title: e.title,
                        description: e.description,
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => SaveTaskPage(
                            goalRef: e.goalRef,
                            stackRef: e.stackRef,
                            goalTitle: e.goalTitle,
                            stackTitle: e.stackTitle,
                            stackColor: e.stackColor,
                            task: e,
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        eventTextBuilder: (event, ctx, dayView, width, height) {
                          return Text(
                            event.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).backgroundColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
