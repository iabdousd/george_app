import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/task/task_repository.dart';
import 'package:stackedtasks/views/actiivity/task_activities_view/task_log_tile.dart';
import 'package:stackedtasks/widgets/activity_feed/task_progress_indicator.dart';

class TaskLogs extends StatelessWidget {
  final Task task;
  const TaskLogs({
    Key key,
    @required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _taskLogs = TaskRepository.getTaskLogs(task);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Task completion',
          style: TextStyle(
            color: Color(0xFF3B404A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        if (task.repetition != null)
          Container(
            padding: const EdgeInsets.only(
              top: 2.0,
              bottom: 12.0,
            ),
            child: Text(
              '${task.completionRate}% completion  |  ${task.maxStreak} days streak',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF767C8D),
              ),
            ),
          )
        else
          SizedBox(
            height: 8.0,
          ),
        Expanded(
          child: _taskLogs.isEmpty
              ? Center(
                  child: Text(
                    'No logs yet!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF767C8D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _taskLogs.length + 1,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    if (index == _taskLogs.length) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (task.repetition != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0,
                              ),
                              child: TaskProgressIndicator(
                                dueDates: task.dueDates,
                                donesHistory: task.donesHistory,
                                toRemoveFromWidth: 8,
                              ),
                            ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: task.isDone()
                                      ? Theme.of(context).accentColor
                                      : Color.fromRGBO(178, 181, 195, 0.2),
                                ),
                              ),
                              Text(
                                'Completion',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF3B404A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return TaskLogTile(
                      taskLog: _taskLogs[index],
                      showLinkLine: true,
                      nextLineDone:
                          index != _taskLogs.length - 1 || task.isDone(),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
