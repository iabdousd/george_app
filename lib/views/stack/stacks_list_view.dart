import 'package:flutter/material.dart';

import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/repositories/stack/stack_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/not_found.dart';
import 'package:stackedtasks/widgets/stack/StackTile.dart';

class StacksListView extends StatefulWidget {
  final Goal goal;
  final Function(bool) updateIsEmpty;
  const StacksListView({
    Key key,
    @required this.goal,
    this.updateIsEmpty,
  }) : super(key: key);

  @override
  _StacksListViewState createState() => _StacksListViewState();
}

class _StacksListViewState extends State<StacksListView> {
  List<TasksStack> stacks = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<TasksStack>>(
        stream: StackRepository.streamStacks(widget.goal),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            stacks = snapshot.data;
            if (snapshot.data.length > 0) {
              return ReorderableListView.builder(
                onReorder: (oldIndex, newIndex) async {
                  List<Future> futures = [];

                  TasksStack old = stacks[oldIndex];
                  if (oldIndex > newIndex) {
                    for (int i = oldIndex; i > newIndex; i--) {
                      futures.add(
                        StackRepository.changeStackOrder(stacks[i - 1], i),
                      );
                      stacks[i] = stacks[i - 1];
                    }
                    futures.add(
                      StackRepository.changeStackOrder(old, newIndex),
                    );
                    stacks[newIndex] = old;
                  } else {
                    for (int i = oldIndex; i < newIndex - 1; i++) {
                      futures.add(
                        StackRepository.changeStackOrder(stacks[i + 1], i),
                      );
                      stacks[i] = stacks[i + 1];
                    }
                    futures.add(
                      StackRepository.changeStackOrder(old, newIndex - 1),
                    );
                    stacks[newIndex - 1] = old;
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
                itemCount: stacks.length,
                itemBuilder: (context, index) {
                  return StackListTileWidget(
                    key: Key(stacks[index].id),
                    stack: stacks[index],
                  );
                },
              );
            } else {
              if (widget.updateIsEmpty != null)
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  widget.updateIsEmpty(true);
                });
              return NotFoundErrorWidget(
                title: 'There are no stacks',
                message: 'Create a Stack by pressing + to get started',
              );
            }
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
}
