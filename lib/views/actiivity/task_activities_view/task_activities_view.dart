import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/widgets/shared/bottom_sheet_head.dart';

import 'task_activities_body.dart';

enum TaskActivityType {
  comment,
  attachment,
  log,
}

const TaskActivityTypeIcons = {
  TaskActivityType.comment: Icons.chat_bubble_outline_rounded,
  TaskActivityType.attachment: Icons.attach_file_rounded,
  TaskActivityType.log: Icons.check_circle_outline_rounded,
};

class TaskActivitiesView extends StatefulWidget {
  final Task task;
  TaskActivitiesView({
    Key key,
    @required this.task,
  }) : super(key: key);

  @override
  _TaskActivitiesViewState createState() => _TaskActivitiesViewState();
}

class _TaskActivitiesViewState extends State<TaskActivitiesView> {
  TaskActivityType currentActivityType = TaskActivityType.comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).backgroundColor,
      ),
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
      margin: EdgeInsets.only(
        top: 50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHead(
            title: 'Activity',
            onSubmit: Navigator.of(context).pop,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter by',
                    style: TextStyle(
                      color: Color(0xFFB2B5C3),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final type in TaskActivityType.values)
                  InkWell(
                    onTap: () => _changeCurrentActivityType(type),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        TaskActivityTypeIcons[type],
                        color: currentActivityType == type
                            ? Theme.of(context).accentColor
                            : Color(0xFFB2B5C3),
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TaskActivitiesBody(
              task: widget.task,
              activityType: currentActivityType,
            ),
          ),
        ],
      ),
    );
  }

  void _changeCurrentActivityType(TaskActivityType newValue) {
    if (currentActivityType != newValue)
      setState(() {
        currentActivityType = newValue;
      });
  }
}
