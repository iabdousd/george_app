import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/constants/models/goal.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/InboxItem.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/goal/save_goal.dart';
import 'package:stackedtasks/views/main-views/home/lg_views/goal_list.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/widgets/home/tiles/lg_goal_tile.dart';
import 'package:stackedtasks/widgets/home/tiles/lg_stack_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

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
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: FadeInUp(
                        duration: Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              onPressed: () => setState(() {
                                selectionStatus = 0;
                                selectedInboxItems.clear();
                                widget.pageIndexStreamController.add(0);
                              }),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor:
                                  Theme.of(context).backgroundColor,
                              child: Icon(
                                Icons.close,
                              ),
                            ),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      color: Theme.of(context).backgroundColor,
                                    ),
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: submitSelection,
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor:
                                  Theme.of(context).backgroundColor,
                              child: Icon(
                                Icons.list_alt_sharp,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      Goal selectedGoal;

      submit = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          child: StreamBuilder<List<TasksStack>>(
            stream: InboxRepository.getInboxStacks(),
            builder: (context, snapshot) {
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
                    if (snapshot.hasData)
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Expanded(
                            child: DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  TabBar(
                                    labelColor: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .color,
                                    tabs: [
                                      Tab(
                                        text: 'Inbox',
                                      ),
                                      Tab(
                                        text: 'Goals',
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        Column(
                                          children: [
                                            if (snapshot.data.isEmpty)
                                              Expanded(
                                                child: AppErrorWidget(
                                                  status: 404,
                                                  customMessage:
                                                      'No stacks added yet',
                                                ),
                                              )
                                            else
                                              ListView.builder(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                itemCount: snapshot.data.length,
                                                itemBuilder: (context, index) {
                                                  final stack =
                                                      snapshot.data[index];

                                                  return Padding(
                                                    key: Key(stack.id),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: LGStackTile(
                                                      stack: stack,
                                                      selected:
                                                          selectedStack?.id ==
                                                              stack.id,
                                                      onSelected: () =>
                                                          setState(
                                                        () => selectedStack
                                                                    ?.id ==
                                                                stack.id
                                                            ? selectedStack =
                                                                null
                                                            : selectedStack =
                                                                stack,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
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
                                              backgroundColor: Theme.of(context)
                                                  .backgroundColor,
                                              textStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection(USERS_KEY)
                                              .doc(getCurrentUser().uid)
                                              .collection(GOALS_KEY)
                                              .snapshots(),
                                          builder: (context, goalsSnapshot) {
                                            if (!goalsSnapshot.hasData)
                                              return LoadingWidget();

                                            if (selectedGoal != null) {
                                              return StreamBuilder<
                                                  QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection(USERS_KEY)
                                                    .doc(getCurrentUser().uid)
                                                    .collection(GOALS_KEY)
                                                    .doc(selectedGoal.id)
                                                    .collection(STACKS_KEY)
                                                    .snapshots(),
                                                builder: (context,
                                                    goalStacksSnapshot) {
                                                  if (!goalStacksSnapshot
                                                      .hasData)
                                                    return LoadingWidget();

                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons
                                                                  .arrow_back_ios),
                                                              onPressed: () =>
                                                                  setState(() {
                                                                selectedGoal =
                                                                    null;
                                                                selectedStack =
                                                                    null;
                                                              }),
                                                            ),
                                                            Text(
                                                              selectedGoal
                                                                  .title,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline6,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16),
                                                          itemCount:
                                                              goalStacksSnapshot
                                                                  .data
                                                                  .docs
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final goalStack =
                                                                TasksStack
                                                                    .fromJson(
                                                              goalStacksSnapshot
                                                                  .data
                                                                  .docs[index]
                                                                  .data(),
                                                              id: goalStacksSnapshot
                                                                  .data
                                                                  .docs[index]
                                                                  .id,
                                                              goalRef:
                                                                  selectedGoal
                                                                      .id,
                                                              goalTitle:
                                                                  selectedGoal
                                                                      .title,
                                                            );

                                                            return Padding(
                                                              key: Key(
                                                                  goalStack.id),
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          8.0),
                                                              child:
                                                                  LGStackTile(
                                                                stack:
                                                                    goalStack,
                                                                selected:
                                                                    selectedStack
                                                                            ?.id ==
                                                                        goalStack
                                                                            .id,
                                                                onSelected: () =>
                                                                    setState(
                                                                  () => selectedStack
                                                                              ?.id ==
                                                                          goalStack
                                                                              .id
                                                                      ? selectedStack =
                                                                          null
                                                                      : selectedStack =
                                                                          goalStack,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }

                                            return ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              itemCount: goalsSnapshot
                                                  .data.docs.length,
                                              itemBuilder: (context, index) {
                                                final goal = Goal.fromJson(
                                                  goalsSnapshot.data.docs[index]
                                                      .data(),
                                                  id: goalsSnapshot
                                                      .data.docs[index].id,
                                                );

                                                return LGGoalTile(
                                                  goal: goal,
                                                  selected: selectedGoal?.id ==
                                                      goal.id,
                                                  onSelected: () => setState(
                                                    () => selectedGoal?.id ==
                                                            goal.id
                                                        ? selectedGoal = null
                                                        : selectedGoal = goal,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      LoadingWidget(),
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
                            onPressed: () => Navigator.of(context).pop(false),
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
