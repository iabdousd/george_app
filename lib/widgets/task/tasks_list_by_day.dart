import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/views/task/save_task.dart';
import 'package:george_project/widgets/calendar/calendar_day_view.dart';
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/widgets/shared/app_error_widget.dart';
import 'package:george_project/widgets/task/task_list_tile_widget.dart';
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
                  DateFormat('EEE, dd yyyy').format(
                DateTime(year, month, day),
              ),
              color: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              textAlignment: Alignment.centerLeft,
            ),
            style: DayViewStyle(
              backgroundColor: Theme.of(context).backgroundColor,
              headerSize: 80,
              backgroundRulesColor: Color(0x88000000),
            ),
            initialTime: HourMinute(hour: day.hour, minute: day.minute),
            events: tasks
                .map((e) => FlutterWeekViewEvent(
                      start: DateTime(
                        day.year,
                        day.month,
                        day.day,
                        e.startTime.hour,
                        e.startTime.minute,
                      ),
                      end: DateTime(
                        day.year,
                        day.month,
                        day.day,
                        e.endTime.hour,
                        e.endTime.minute,
                      ),
                      title: e.title,
                      description: e.description,
                      onTap: () => Get.to(
                        () => SaveTaskPage(
                          goalRef: e.goalRef,
                          stackRef: e.stackRef,
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

//  OLD VERSION
// return Container(
//   height: MediaQuery.of(context).size.height,
//   color: Theme.of(context).backgroundColor,
//   padding: const EdgeInsets.only(bottom: 80),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: [
//       Container(
//         padding: const EdgeInsets.only(
//           top: 20.0,
//           left: 12.0,
//           right: 12.0,
//         ),
//         decoration: BoxDecoration(
//           color: Theme.of(context).backgroundColor,
//           boxShadow: [
//             BoxShadow(
//               color: Color(0x22000000),
//               blurRadius: 4,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${DateFormat("MMMM yyyy").format(day)}',
//               style: Theme.of(context)
//                   .textTheme
//                   .headline6
//                   .copyWith(fontWeight: FontWeight.w500),
//             ),
//             SizedBox(
//               height: 4,
//             ),
//             Container(
//               padding: EdgeInsets.only(
//                   top: 8.0, bottom: 8.0, left: 4.0, right: 12.0),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).backgroundColor,
//                 border: Border(
//                   right: BorderSide(
//                     color: Color(0x22000000),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     DateFormat('EEE').format(day).toUpperCase(),
//                     style: Theme.of(context).textTheme.subtitle1.copyWith(
//                           color: Theme.of(context).primaryColor,
//                         ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       DateFormat('dd').format(day),
//                       style:
//                           Theme.of(context).textTheme.headline6.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       Expanded(
//         child: Container(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection(user_constants.USERS_KEY)
//                 .doc(getCurrentUser().uid)
//                 .collection(stack_constants.TASKS_KEY)
//                 .where(
//                   task_constants.DUE_DATES_KEY,
//                   arrayContains: DateTime(day.year, day.month, day.day),
//                 )
//                 .orderBy(
//                   task_constants.START_TIME_KEY,
//                 )
//                 .snapshots(),
//             builder: (context, snapshot) {
//               List<Task> tasks = [];
//               if (snapshot.hasData && snapshot.data.docs.length > 0)
//                 tasks = snapshot.data.docs
//                     .map(
//                       (e) => Task.fromJson(e.data(), id: e.id),
//                     )
//                     .toList();

//               return CalendarDayView(
//                 tasks: tasks,
//                 day: day,
//               );
//             },
//           ),
//         ),
//       ),
//     ],
//   ),
// );
