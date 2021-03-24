import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/widgets/shared/app_error_widget.dart';
import 'package:george_project/widgets/task/task_list_tile_widget.dart';
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:intl/intl.dart';

class TasksListByDay extends StatelessWidget {
  final DateTime day;
  TasksListByDay({Key key, @required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Text(
            'Upcoming',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(user_constants.USERS_KEY)
                .doc(getCurrentUser().uid)
                .collection(stack_constants.TASKS_KEY)
                .where(
                  task_constants.DUE_DATES_KEY,
                  arrayContains: DateTime(day.year, day.month, day.day),
                )
                .snapshots(),
            builder: (context, snapshot) {
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
      ),
    );
  }
}
