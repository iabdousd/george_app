import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

class TodayTasks extends StatelessWidget {
  const TodayTasks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(stack_constants.TASKS_KEY)
            .where(
              task_constants.USER_ID_KEY,
              isEqualTo: getCurrentUser().uid,
            )
            .where(
              task_constants.DUE_DATES_KEY,
              arrayContains: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Task> tasks = snapshot.data.docs
                .map((e) => Task.fromJson(e.data(), id: e.id))
                .toList();
            int completedTasksCount = tasks
                .where(
                  (element) => (element.donesHistory.contains(
                        DateTime(
                          now.year,
                          now.month,
                          now.day,
                        ),
                      ) ||
                      element.status == 1),
                )
                .length;
            int totalTasksCount = snapshot.data.docs.length;
            double percentage = completedTasksCount / totalTasksCount;

            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: 100.0,
                          lineWidth: 9.0,
                          animation: true,
                          percent: percentage,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (percentage * 100).toStringAsFixed(0) + "%",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Completed',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(fontSize: 10, height: 1),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Theme.of(context).primaryColor,
                          backgroundColor: Color(0x0F000000),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Today\'s Progress",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          'You have completed $completedTasksCount task${completedTasksCount > 1 ? 's' : ''} out of $totalTasksCount today!',
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                                fontWeight: FontWeight.w200,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return LoadingWidget();
        },
      ),
    );
  }
}
