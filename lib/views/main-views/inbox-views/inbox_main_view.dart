import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/InboxItem.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/views/goal/save_goal.dart';
import 'package:stackedtasks/views/main-views/home/lg_views/goal_list.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/widgets/home/tiles/lg_stack_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

import '../../../models/Stack.dart';
import '../../../services/feed-back/loader.dart';
import '../../../widgets/shared/app_error_widget.dart';
import '../../../widgets/stack/StackTile.dart';
import '../../../widgets/task/task_list_tile_widget.dart';

class InboxMainView extends StatefulWidget {
  final StreamController<int> pageIndexStreamController;
  InboxMainView({
    Key key,
    this.pageIndexStreamController,
  }) : super(key: key);

  @override
  _InboxMainViewState createState() => _InboxMainViewState();
}

class _InboxMainViewState extends State<InboxMainView>
    with AutomaticKeepAliveClientMixin {
  int elementsCount = 0;
  List<InboxItem> selectedInboxItems = [];

  /*
   * 0 - No selection
   * 1 - Stacks are selected
   * 2 - Tasks are selected
   */
  int selectionStatus = 0;

  @override
  void initState() {
    super.initState();
    widget.pageIndexStreamController.stream.listen((event) {
      if (event != -1 && event != 0) {
        setState(() {
          selectionStatus = 0;
          selectedInboxItems.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: StreamBuilder<List<InboxItem>>(
        stream: InboxRepository.getInboxItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final items = selectionStatus == 1
                ? snapshot.data
                    .where((element) => element is TasksStack)
                    .toList()
                : selectionStatus == 2
                    ? snapshot.data.where((element) => element is Task).toList()
                    : snapshot.data;
            elementsCount = items.length;
            if (items.length > 0)
              return Stack(
                children: [
                  Positioned.fill(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        if (items[index] is TasksStack)
                          return StackListTileWidget(
                            stack: items[index],
                            selected: selectedInboxItems
                                .where(
                                  (e) =>
                                      (e as TasksStack).id ==
                                      (items[index] as TasksStack).id,
                                )
                                .isNotEmpty,
                            onLongPress: () => setState(
                              () {
                                if (selectionStatus == 0) {
                                  widget.pageIndexStreamController.add(-1);
                                  selectionStatus = 1;
                                  selectedInboxItems.add(items[index]);
                                } else {
                                  selectedInboxItems
                                          .where(
                                            (e) =>
                                                (e as TasksStack).id ==
                                                (items[index] as TasksStack).id,
                                          )
                                          .isEmpty
                                      ? setState(() {
                                          selectedInboxItems.add(items[index]);
                                        })
                                      : setState(() {
                                          selectedInboxItems.removeWhere(
                                            (e) =>
                                                (e as TasksStack).id ==
                                                (items[index] as TasksStack).id,
                                          );
                                          if (selectedInboxItems.isEmpty) {
                                            selectionStatus = 0;
                                            widget.pageIndexStreamController
                                                .add(0);
                                          }
                                        });
                                }
                              },
                            ),
                            onClickEvent: selectionStatus == 1
                                ? () => selectedInboxItems
                                        .where(
                                          (e) =>
                                              (e as TasksStack).id ==
                                              (items[index] as TasksStack).id,
                                        )
                                        .isEmpty
                                    ? setState(() {
                                        selectedInboxItems.add(items[index]);
                                      })
                                    : setState(() {
                                        selectedInboxItems.removeWhere(
                                          (e) =>
                                              (e as TasksStack).id ==
                                              (items[index] as TasksStack).id,
                                        );
                                        if (selectedInboxItems.isEmpty) {
                                          selectionStatus = 0;
                                          widget.pageIndexStreamController
                                              .add(0);
                                        }
                                      })
                                : null,
                          );
                        return TaskListTileWidget(
                          task: items[index],
                          stackColor: Theme.of(context)
                              .primaryColor
                              .value
                              .toRadixString(16),
                          selected: selectedInboxItems
                              .where(
                                (e) =>
                                    (e as Task).id == (items[index] as Task).id,
                              )
                              .isNotEmpty,
                          onClickEvent: selectionStatus == 2
                              ? () => selectedInboxItems
                                      .where(
                                        (e) =>
                                            (e as Task).id ==
                                            (items[index] as Task).id,
                                      )
                                      .isEmpty
                                  ? setState(() {
                                      selectedInboxItems.add(items[index]);
                                    })
                                  : setState(() {
                                      selectedInboxItems.removeWhere(
                                        (e) =>
                                            (e as Task).id ==
                                            (items[index] as Task).id,
                                      );
                                      if (selectedInboxItems.isEmpty) {
                                        selectionStatus = 0;
                                        widget.pageIndexStreamController.add(0);
                                      }
                                    })
                              : null,
                          onLongPress: () => setState(
                            () {
                              if (selectionStatus == 0) {
                                widget.pageIndexStreamController.add(-1);
                                selectionStatus = 2;
                                selectedInboxItems.add(items[index]);
                              } else {
                                selectedInboxItems
                                        .where(
                                          (e) =>
                                              (e as Task).id ==
                                              (items[index] as Task).id,
                                        )
                                        .isEmpty
                                    ? setState(() {
                                        selectedInboxItems.add(items[index]);
                                      })
                                    : setState(() {
                                        selectedInboxItems.removeWhere(
                                          (e) =>
                                              (e as Task).id ==
                                              (items[index] as Task).id,
                                        );
                                        if (selectedInboxItems.isEmpty) {
                                          widget.pageIndexStreamController
                                              .add(0);
                                          selectionStatus = 0;
                                        }
                                      });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (selectionStatus != 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 64),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            '${selectedInboxItems.length} Selected',
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Theme.of(context).backgroundColor,
                                    ),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: submitSelection,
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Theme.of(context).backgroundColor,
                          child: Icon(
                            Icons.list_alt_sharp,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            else
              return Center(
                child: AppErrorWidget(
                  status: 404,
                  customMessage:
                      'Nothing here. Create a Task or Stack by pressing + to get started',
                ),
              );
          }
          if (snapshot.hasError) return AppErrorWidget();
          return LoadingWidget();
        },
      ),
    );
  }

  submitSelection() async {
    bool submit = false;
    if (selectionStatus == 1) {
      Goal selectedGoal;

      submit = await showDialog<bool>(
            context: context,
            builder: (context) => Dialog(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 32,
                    child: Column(
                      children: [
                        Expanded(
                          child: HomeLGGoalList(
                            selectedGoal: selectedGoal,
                            selectGoal: (goal) => selectedGoal?.id == goal.id
                                ? setState(
                                    () {
                                      selectedGoal = null;
                                    },
                                  )
                                : setState(
                                    () {
                                      selectedGoal = goal;
                                    },
                                  ),
                          ),
                        ),
                        AppActionButton(
                          onPressed: () => Get.to(
                            () => SaveGoalPage(),
                          ),
                          label: 'Create new Goal',
                          backgroundColor: Theme.of(context).backgroundColor,
                          textStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppActionButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                backgroundColor: Colors.red,
                                label: 'Cancel',
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                margin: EdgeInsets.zero,
                              ),
                              AppActionButton(
                                onPressed: () {
                                  if (selectedGoal != null) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                                label: 'Add To Selected',
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                margin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              insetPadding: EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 16,
              ),
            ),
          ) ??
          false;
      if (submit) {
        final res = await InboxRepository.groupStacks(
          List<TasksStack>.from(selectedInboxItems),
          selectedGoal,
        );
        if (res)
          setState(
            () {
              widget.pageIndexStreamController.add(0);
              selectionStatus = 0;
              selectedInboxItems.clear();
            },
          );
      }
    } else if (selectionStatus == 2) {
      TasksStack selectedStack;

      submit = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          child: StreamBuilder<List<TasksStack>>(
            stream: InboxRepository.getInboxStacks(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0)
                  return Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                'Select Stack',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ],
                          ),
                        ),
                        StatefulBuilder(
                          builder: (context, setState) {
                            return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                final stack = snapshot.data[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: LGStackTile(
                                    stack: stack,
                                    selected: selectedStack?.id == stack.id,
                                    onSelected: () => setState(
                                      () => selectedStack?.id == stack.id
                                          ? selectedStack = null
                                          : selectedStack = stack,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        AppActionButton(
                          onPressed: () => Get.to(
                            () => SaveStackPage(
                              goalRef: 'inbox',
                              goalColor: Theme.of(context)
                                  .primaryColor
                                  .value
                                  .toRadixString(16),
                            ),
                          ),
                          label: 'Create new Stack',
                          backgroundColor: Theme.of(context).backgroundColor,
                          textStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppActionButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                backgroundColor: Colors.red,
                                label: 'Cancel',
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                margin: EdgeInsets.zero,
                              ),
                              AppActionButton(
                                onPressed: () {
                                  if (selectedStack != null) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                                label: 'Add To Selected',
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                margin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                else
                  return AppErrorWidget(
                    status: 404,
                    customMessage: 'No tasks added yet',
                  );
              }

              return LoadingWidget();
            },
          ),
        ),
        barrierDismissible: false,
      );
      if (submit) {
        final res = await InboxRepository.groupTasks(
          List<Task>.from(selectedInboxItems),
          selectedStack,
        );
        if (res)
          setState(
            () {
              widget.pageIndexStreamController.add(0);
              selectionStatus = 0;
              selectedInboxItems.clear();
            },
          );
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
