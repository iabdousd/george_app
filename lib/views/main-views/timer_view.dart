import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/widgets/task/tasks_timer_list.dart';

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
      return;
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
    currentTask?.close();
    refreshTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: kIsWeb
            ? EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width - 600) / 2)
            : EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.all(32.0),
            child: StreamBuilder<Task>(
                stream: currentTask.stream,
                builder: (context, snapshot) {
                  bool actual = false;
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
                      actual = true;
                      durationBeforeNextTask =
                          snapshot.data.endTime.difference(timeNow);
                    } else {
                      actual = false;
                      durationBeforeNextTask =
                          snapshot.data.startTime.difference(timeNow);
                    }
                  }
                  if (durationBeforeNextTask == null) {
                    return Container(
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
                      margin: EdgeInsets.only(top: 50),
                      height: kIsWeb
                          ? 536
                          : 2 * MediaQuery.of(context).size.width / 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No task scheduled',
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        actual
                            ? 'Time remaining for current task'
                            : 'Time till next task',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.w300),
                      ),
                      Text(
                        '${durationBeforeNextTask.inHours.toStringAsFixed(0)}:${durationBeforeNextTask.inMinutes % 60 < 10 ? '0' : ''}${durationBeforeNextTask.inMinutes % 60}',
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }),
          ),
          TasksTimerList(
            emitFirstTask: emitCurrentTask,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
