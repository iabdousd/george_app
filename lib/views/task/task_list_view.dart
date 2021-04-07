import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:plandoraslist/constants/models/goal.dart' as goal_constants;
import 'package:plandoraslist/constants/user.dart' as user_constants;
import 'package:plandoraslist/constants/models/stack.dart' as stack_constants;
import 'package:plandoraslist/constants/models/task.dart' as task_constants;
import 'package:plandoraslist/models/Stack.dart' as stack_model;
import 'package:plandoraslist/models/Task.dart';
import 'package:plandoraslist/services/feed-back/loader.dart';
import 'package:plandoraslist/services/user/user_service.dart';
import 'package:plandoraslist/views/task/save_task.dart';
import 'package:plandoraslist/widgets/shared/app_action_button.dart';
import 'package:plandoraslist/widgets/task/task_list_tile_widget.dart';
import 'package:get/get.dart';

class TaskListView extends StatefulWidget {
  final stack_model.Stack stack;
  const TaskListView({Key key, this.stack}) : super(key: key);

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with AutomaticKeepAliveClientMixin {
  int limit = 10;
  int elementsCount = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          elementsCount == limit)
        setState(() {
          limit += 10;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: ListView(
        controller: _scrollController,
        children: [
          SizedBox(
            height: 8.0,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                child: AppActionButton(
                  onPressed: () => Get.to(
                    () => SaveTaskPage(
                      goalRef: widget.stack.goalRef,
                      stackRef: widget.stack.id,
                      goalTitle: widget.stack.goalTitle,
                      stackTitle: widget.stack.title,
                      stackColor: widget.stack.color,
                    ),
                  ),
                  icon: Icons.add,
                  label: 'NEW TASK',
                  backgroundColor: Theme.of(context).primaryColor,
                  alignment: Alignment.center,
                  textStyle: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                  iconSize: 26.0,
                ),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(user_constants.USERS_KEY)
                  .doc(getCurrentUser().uid)
                  .collection(goal_constants.GOALS_KEY)
                  .doc(widget.stack.goalRef)
                  .collection(goal_constants.STACKS_KEY)
                  .doc(widget.stack.id)
                  .collection(stack_constants.TASKS_KEY)
                  .orderBy(task_constants.CREATION_DATE_KEY, descending: true)
                  .limit(limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  elementsCount = snapshot.data.docs.length;
                  if (snapshot.data.docs.length > 0)
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      itemCount: snapshot.data.docs.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TaskListTileWidget(
                          task: Task.fromJson(snapshot.data.docs[index].data())
                            ..goalRef = widget.stack.goalRef
                            ..stackRef = widget.stack.id
                            ..id = snapshot.data.docs[index].id,
                          stackColor: widget.stack.color,
                        );
                      },
                    );
                  else
                    return Container();
                }
                return LoadingWidget();
              }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
