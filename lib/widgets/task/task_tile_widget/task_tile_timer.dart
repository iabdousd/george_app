import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

class TaskTileTimer extends StatefulWidget {
  final Task task;
  final BoxDecoration decoration;
  final VoidCallback editTask, deleteTask, taskEndedCallback;
  const TaskTileTimer({
    Key key,
    @required this.task,
    this.decoration,
    @required this.editTask,
    @required this.deleteTask,
    @required this.taskEndedCallback,
  }) : super(key: key);

  @override
  _TaskTileTimerState createState() => _TaskTileTimerState();
}

class _TaskTileTimerState extends State<TaskTileTimer> {
  Timer timer;
  bool notifiedAboutDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000 - DateTime.now().millisecond))
        .then(
      (_) => timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (widget.task.endTime ==
                DateTime(
                  1970,
                  1,
                  1,
                  DateTime.now().hour,
                  DateTime.now().minute,
                ) ||
            widget.task.endTime.isBefore(
              DateTime(
                1970,
                1,
                1,
                DateTime.now().hour,
                DateTime.now().minute,
              ),
            )) {
          if (!notifiedAboutDone) {
            notifiedAboutDone = true;
            _confirmTaskCompletion();
          }
          widget.taskEndedCallback();
        }
        if (mounted)
          setState(() {});
        else
          timer.cancel();
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void _handleClick(String action) {
    if (action == 'edit')
      widget.editTask();
    else if (action == 'delete') widget.deleteTask();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime(
      1970,
      1,
      1,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    return Container(
      decoration: widget.decoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Time remaining',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF3B404A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: _handleClick,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 24,
                  color: Color(0xFFB2B5C3),
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 32.0,
              bottom: 35,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.task.endTime.difference(now).toString().split(':')[0]}',
                  style: TextStyle(
                    color: Color(0xFF767C8D),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: .35,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 24,
                  ),
                  child: Text(
                    'hours',
                    style: TextStyle(
                      color: Color(0xFF767C8D),
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${widget.task.endTime.difference(now).toString().split(':')[1]}',
                  style: TextStyle(
                    color: Color(0xFF767C8D),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: .35,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: Text(
                    'minutes',
                    style: TextStyle(
                      color: Color(0xFF767C8D),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmTaskCompletion() {
    if (!widget.task.isDone(
      date: DateTime.now(),
    )) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(widget.task.title),
          content: Text(
            'Task time ended! Would you like to mark it as done?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Ignore',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                toggleLoading(state: true);
                await widget.task.accomplish(
                  customDate: DateTime.now(),
                );
                toggleLoading(state: false);
                Get.back();
                showFlushBar(
                  title: 'Task Completed!',
                  message: 'Congrats! The task has been marked as completed!',
                );
              },
              child: Text(
                'Mark as done',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
