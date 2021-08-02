import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/task/task_tile_widget/task_list_tile_widget.dart';
import 'package:intl/intl.dart';

class TasksListByDay extends StatelessWidget {
  final DateTime day;
  TasksListByDay({
    Key key,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 16.0,
      ),
      children: [
        Text(
          'Current tasks',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFB2B5C3),
            fontSize: 14,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(stack_constants.TASKS_KEY)
              .where(
                task_constants.USER_ID_KEY,
                isEqualTo: getCurrentUser().uid,
              )
              .where(
                task_constants.DUE_DATES_KEY,
                arrayContains: DateTime.utc(
                  day.year,
                  day.month,
                  day.day,
                ),
              )
              .orderBy(
                task_constants.START_TIME_KEY,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return AppErrorWidget();
            }
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
    );
  }
}
