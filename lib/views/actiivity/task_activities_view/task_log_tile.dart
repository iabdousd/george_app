import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/models/TaskLog.dart';

class TaskLogTile extends StatelessWidget {
  final TaskLog taskLog;
  final bool showLinkLine;
  final bool nextLineDone;

  const TaskLogTile({
    Key key,
    @required this.taskLog,
    this.showLinkLine: false,
    this.nextLineDone: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  taskLog.log,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3B404A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Text(
                        DateFormat(
                                'EEE, dd MMM ${taskLog.uid == 'recent_instance_log' || taskLog.uid == 'upcoming_instance_log' ? '' : ' - hh:mm'}')
                            .format(taskLog.creationDateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: taskLog.status == 2
                              ? Theme.of(context).accentColor
                              : Color(0xFF767C8D),
                        ),
                      ),
                      if (taskLog.uid == 'recent_instance_log')
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Icon(
                            Icons.done,
                            size: 18,
                            color: taskLog.status == 2
                                ? Theme.of(context).accentColor
                                : Color(0xFF767C8D),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
