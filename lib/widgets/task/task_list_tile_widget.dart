import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskListTileWidget extends StatelessWidget {
  final Task task;
  final String stackColor;

  const TaskListTileWidget(
      {Key key, @required this.task, @required this.stackColor})
      : super(key: key);

  _deleteTask(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Task',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${task.title.toUpperCase()}\' ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                toggleLoading(state: true);
                await task.delete();
                toggleLoading(state: false);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  _editTask(context) {
    Get.to(
      () => SaveTaskPage(
        task: task,
        stackRef: task.stackRef,
        goalRef: task.goalRef,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      margin: EdgeInsets.only(top: 16.0),
      height: 64.0 + 20,
      child: GestureDetector(
        onTap: () => task.status == 0
            ? (task..status = 1).save()
            : (task..status = 0).save(),
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: HexColor.fromHex(stackColor),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        ),
                        if (task.status == 1)
                          Center(
                            child: Icon(
                              Icons.done_rounded,
                              size: 30.0,
                              color: HexColor.fromHex(stackColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.status == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontStyle: task.status == 1
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(task.startDate) +
                              ' - ' +
                              DateFormat('dd MMM yyyy').format(task.endDate),
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.w300,
                                decoration: task.status == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontStyle: task.status == 1
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              onTap: () => _editTask(context),
              iconWidget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).backgroundColor,
                    size: 32.0,
                  ),
                );
              }),
              closeOnTap: true,
            ),
            IconSlideAction(
              iconWidget: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).backgroundColor,
                      size: 32.0,
                    ),
                  );
                },
              ),
              closeOnTap: true,
              onTap: () => _deleteTask(context),
            ),
          ],
        ),
      ),
    );
  }
}
