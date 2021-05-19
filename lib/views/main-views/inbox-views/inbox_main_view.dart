import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/InboxItem.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/services/shared/color.dart';
import 'package:stackedtasks/widgets/forms/date_picker.dart';
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
                                          if (selectedInboxItems.isEmpty)
                                            selectionStatus = 0;
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
                                        if (selectedInboxItems.isEmpty)
                                          selectionStatus = 0;
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
                                      if (selectedInboxItems.isEmpty)
                                        selectionStatus = 0;
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
                                        if (selectedInboxItems.isEmpty)
                                          selectionStatus = 0;
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
      final goalTitleController = TextEditingController();
      DateTime startDate = DateTime.now(),
          endDate = DateTime.now().add(
            Duration(days: 1),
          );
      String selectedColor = randomColor;

      submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Grouping Stacks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: goalTitleController,
                label: 'Goal Title',
                hint: 'Enter the title of the Goal',
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => pickColor(
                        (e) => selectedColor = e,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0x07000000),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.brightness_1,
                          color: HexColor.fromHex(selectedColor),
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DatePickerWidget(
                        title: 'Start:',
                        color: selectedColor,
                        endDate: endDate,
                        onSubmit: (picked) {
                          startDate = picked;
                        },
                        selectedDate: startDate,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DatePickerWidget(
                        title: 'End:',
                        color: selectedColor,
                        onSubmit: (picked) {
                          endDate = picked;
                        },
                        startDate: startDate,
                        selectedDate: endDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            AppActionButton(
              onPressed: () => Navigator.of(context).pop(false),
              backgroundColor: Colors.red,
              label: 'Cancel',
              margin: EdgeInsets.only(right: 4),
            ),
            AppActionButton(
              onPressed: () {
                if (goalTitleController.text.trim().isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  Navigator.of(context).pop(true);
                }
              },
              backgroundColor: Theme.of(context).backgroundColor,
              label: 'Submit',
              textStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.zero,
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (submit) {
        final res = await InboxRepository.groupStacks(
          List<TasksStack>.from(selectedInboxItems),
          goalTitle: goalTitleController.text,
          goalStartDate: startDate,
          goalEndDate: endDate,
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
      final stackTitleController = TextEditingController();
      submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Grouping Tasks'),
          content: AppTextField(
            controller: stackTitleController,
            label: 'Stack Title',
            hint: 'Enter the title of the Stack',
          ),
          actions: [
            AppActionButton(
              onPressed: () => Navigator.of(context).pop(false),
              backgroundColor: Colors.red,
              label: 'Cancel',
              margin: EdgeInsets.only(right: 4),
            ),
            AppActionButton(
              onPressed: () {
                if (stackTitleController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              backgroundColor: Theme.of(context).backgroundColor,
              label: 'Submit',
              textStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.zero,
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (submit) {
        final res = await InboxRepository.groupTasks(
          List<Task>.from(selectedInboxItems),
          stackTitle: stackTitleController.text,
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
