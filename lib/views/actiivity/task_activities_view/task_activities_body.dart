import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/views/actiivity/task_activities_view/task_activities_view.dart';

import 'task_attachments.dart';
import 'task_comments.dart';
import 'task_logs.dart';

class TaskActivitiesBody extends StatelessWidget {
  final Task task;
  final TaskActivityType activityType;

  const TaskActivitiesBody({
    Key key,
    @required this.task,
    @required this.activityType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (activityType) {
      case TaskActivityType.comment:
        {
          return TaskComments(
            key: Key('task_comments'),
            task: task,
          );
        }
      case TaskActivityType.attachment:
        return TaskAttachments(
          key: Key('task_attachments'),
          task: task,
        );
        break;
      case TaskActivityType.log:
        return TaskLogs(
          key: Key('task_logs'),
          task: task,
        );
        break;
      default:
        return Container();
    }
  }
}
