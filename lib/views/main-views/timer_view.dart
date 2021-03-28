import 'dart:async';

import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/widgets/task/tasks_timer_list.dart';

class TimerView extends StatefulWidget {
  TimerView({Key key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView>
    with AutomaticKeepAliveClientMixin {
  Duration durationBeforeNextTask;
  StreamController<Task> currentTask = StreamController<Task>.broadcast();
  Timer refreshTimer;

  emitCurrentTask(Task task) {
    if (task == null) {
      durationBeforeNextTask = null;
      currentTask.add(task);
      refreshTimer?.cancel();
    }
    currentTask.add(task);
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (task.endTime.isBefore(DateTime(
        1970,
        1,
        1,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ))) setState(() {});

      currentTask.add(task);
    });
  }

  @override
  void dispose() {
    super.dispose();
    currentTask.close();
    refreshTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Container(
          padding: EdgeInsets.all(32.0),
          child: StreamBuilder<Task>(
              stream: currentTask.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  DateTime timeNow = DateTime(
                    1970,
                    1,
                    1,
                    DateTime.now().hour,
                    DateTime.now().minute,
                  );
                  if (snapshot.data != null) if (snapshot.data.startTime
                      .isBefore(timeNow)) {
                    durationBeforeNextTask =
                        snapshot.data.endTime.difference(timeNow);
                  } else {
                    durationBeforeNextTask =
                        snapshot.data.startTime.difference(timeNow);
                  }
                }
                if (durationBeforeNextTask == null) {
                  return Container(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Congratulations!',
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'There\'s no more tasks for today!',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.w100),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Text(
                      'You have',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontWeight: FontWeight.w100),
                    ),
                    Text(
                      '${durationBeforeNextTask.inHours.toStringAsFixed(0)}:${durationBeforeNextTask.inMinutes % 60 < 10 ? '0' : ''}${durationBeforeNextTask.inMinutes % 60}',
                      style: Theme.of(context)
                          .textTheme
                          .headline2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Before the next task',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontWeight: FontWeight.w200),
                    ),
                  ],
                );
              }),
        ),
        TasksTimerList(
          emitFirstTask: emitCurrentTask,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
