import 'package:flutter/material.dart';

import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/task/task_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/not_found.dart';
import 'package:stackedtasks/widgets/task/task_tile_widget/task_list_tile_widget.dart';
import 'package:stackedtasks/repositories/stack/stack_repository.dart';

class TaskListView extends StatefulWidget {
  final stack_model.TasksStack stack;
  const TaskListView({Key key, this.stack}) : super(key: key);

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with AutomaticKeepAliveClientMixin {
  List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<Task>>(
        stream: StackRepository.streamStackTasks(
          widget.stack,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            tasks = snapshot.data;
            if (snapshot.data.length > 0) {
              List<Task> tasks = snapshot.data;

              tasks.sort(
                (a, b) => a.nextDueDate() == null ? 1 : -1,
              );

              final currentTasks = tasks
                  .where(
                    (task) => task.nextDueDate() != null,
                  )
                  .toList();
              final completedTasks = tasks
                  .where(
                    (task) => task.nextDueDate() == null,
                  )
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 8.0,
                      left: 16.0,
                    ),
                    child: Text(
                      'Current tasks',
                      style: TextStyle(
                        color: Color(0xFFB2B5C3),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) async {
                      List<Future> futures = [];

                      var old = tasks[oldIndex];
                      if (oldIndex > newIndex) {
                        for (int i = oldIndex; i > newIndex; i--) {
                          futures.add(
                            TaskRepository.changeTaskOrder(tasks[i - 1], i),
                          );
                          tasks[i] = tasks[i - 1];
                        }
                        futures.add(
                          TaskRepository.changeTaskOrder(
                            old,
                            newIndex,
                          ),
                        );
                        tasks[newIndex] = old;
                      } else {
                        for (int i = oldIndex; i < newIndex - 1; i++) {
                          futures.add(
                            TaskRepository.changeTaskOrder(
                              tasks[i + 1],
                              i,
                            ),
                          );
                          tasks[i] = tasks[i + 1];
                        }
                        futures.add(
                          TaskRepository.changeTaskOrder(
                            old,
                            newIndex - 1,
                          ),
                        );
                        tasks[newIndex - 1] = old;
                      }
                      setState(() {});
                      await Future.wait(futures);
                    },
                    proxyDecorator: (widget, extent, animation) => Material(
                      child: widget,
                      shadowColor: Colors.transparent,
                      color: Colors.transparent,
                      elevation: animation.value,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    itemCount: currentTasks.length,
                    itemBuilder: (context, index) {
                      final task = currentTasks[index];
                      return TaskListTileWidget(
                        key: Key(task.id),
                        task: task,
                        stackColor: widget.stack.color,
                      );
                    },
                  ),
                  if (completedTasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 8.0,
                        left: 16.0,
                      ),
                      child: Text(
                        'Completed tasks',
                        style: TextStyle(
                          color: Color(0xFFB2B5C3),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (completedTasks.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];
                        return TaskListTileWidget(
                          key: Key(task.id),
                          task: task,
                          stackColor: widget.stack.color,
                          showDragIndicator: false,
                        );
                      },
                    ),
                ],
              );
            } else
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.top -
                    MediaQuery.of(context).viewInsets.bottom -
                    100,
                child: NotFoundErrorWidget(
                  title: 'There are no tasks',
                  message: 'Create a Task by pressing + to get started',
                ),
              );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return AppErrorWidget();
          }
          return LoadingWidget();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
