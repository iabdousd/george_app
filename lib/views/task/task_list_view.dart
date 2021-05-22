import 'package:flutter/material.dart';

import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/task/task_list_tile_widget.dart';
import 'package:stackedtasks/repositories/stack/stack_repository.dart';
import 'package:get/get.dart';

class TaskListView extends StatefulWidget {
  final stack_model.TasksStack stack;
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
          StreamBuilder<List<Task>>(
              stream: StackRepository.streamStackTasks(
                widget.stack,
                limit,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  elementsCount = snapshot.data.length;
                  if (snapshot.data.length > 0)
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      itemCount: snapshot.data.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TaskListTileWidget(
                          task: snapshot.data[index],
                          stackColor: widget.stack.color,
                        );
                      },
                    );
                  else
                    return Container();
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return AppErrorWidget();
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
