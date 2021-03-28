import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/widgets/task/calendar_tasks_list_tile.dart';
import 'package:intl/intl.dart';

class CalendarDayView extends StatelessWidget {
  final DateTime day;
  final List<Task> tasks;
  const CalendarDayView({Key key, @required this.tasks, @required this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tasksWidgets = [];

    Map<int, int> tasksPositions = {};

    int maxLength = 0;
    for (int index = 0; index < 25; index++) {
      int length = tasks
          .where((task) =>
              task.startTime.hour <= index && task.endTime.hour >= index)
          .length;

      if (length > maxLength) maxLength = length;
    }
    for (Task task in tasks) {
      if (!tasksPositions.containsKey(task.startTime.hour))
        tasksPositions[task.startTime.hour] = 0;
      int position = tasksPositions[task.startTime.hour];
      // tasksPositions.forEach((key, value) {
      //   if (key >= task.startTime.hour &&
      //       key <= task.endTime.hour &&
      //       value > position) {
      //     position = tasksPositions[task.startTime.hour];
      //   }
      // });

      for (int i = task.startTime.hour; i <= task.endTime.hour; i++) {
        if (!tasksPositions.containsKey(i)) tasksPositions[i] = 0;
        tasksPositions[i] += 1;
      }

      tasksWidgets.add(
        Positioned(
          left: position * (2 * MediaQuery.of(context).size.width / 3) +
              64.0 +
              8 * position,
          top: (task.startTime.hour) * 93.0 + 20.0,
          child: CalendarTaskListTileWidget(
            task: task,
            stackColor: task.stackColor,
            enforcedDate: day,
            height: task.endTime.hour == 23
                ? 93.0 - 20.0
                : task.endTime.hour * 93.0 - task.startTime.hour * 93.0 - 20.0,
            width: 2 * MediaQuery.of(context).size.width / 3,
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 93 * 24.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
                Container(
                  width: maxLength <= 1
                      ? MediaQuery.of(context).size.width
                      : 60.0 +
                          (2 * MediaQuery.of(context).size.width / 3 + 8.0) *
                              maxLength,
                  height: 93 * 24.0,
                  child: ListView.builder(
                    itemCount: 24,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // if (tasksPerHour[index] != null && tasksPerHour[index].length > 0)
                      return Container(
                        padding: EdgeInsets.only(left: 16),
                        height: 93,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    DateFormat('hh a')
                                        .format(DateTime(1970, 1, 1, index)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(.5),
                                      height: 1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 10),
                                      // width: double.infinity,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                      // return Container();
                    },
                  ),
                ),
              ] +
              tasksWidgets,
        ),
      ),
    );
  }
}
