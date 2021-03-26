import 'package:flutter/material.dart';
import 'package:george_project/widgets/task/tasks_timer_list.dart';

class TimerView extends StatefulWidget {
  TimerView({Key key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Duration durationBeforeNextTask;

  @override
  Widget build(BuildContext context) {
    durationBeforeNextTask = Duration(hours: 15, minutes: 10);

    return ListView(
      children: [
        Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Text(
                'You have',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.w100),
              ),
              Text(
                '${durationBeforeNextTask.inHours.toStringAsFixed(0)}:${durationBeforeNextTask.inMinutes % 60}',
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
          ),
        ),
        TasksTimerList(),
      ],
    );
  }
}
