import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final DateTime enforcedDate;

  const TaskListTileWidget({
    Key key,
    @required this.task,
    @required this.stackColor,
    this.enforcedDate,
  }) : super(key: key);

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
        stackColor: task.stackColor,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
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
        onTap: () => _editTask(context),
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: task.isDone(date: enforcedDate)
                  ? Theme.of(context).backgroundColor.withOpacity(.8)
                  : Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => task.accomplish(customDate: enforcedDate),
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                          if (task.isDone(date: enforcedDate))
                            Center(
                              child: SvgPicture.asset(
                                'assets/images/icons/done.svg',
                                color: HexColor.fromHex(stackColor),
                                height: 24.0,
                                width: 24.0,
                              ),
                            ),
                        ],
                      ),
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
                                decoration: task.isDone(date: enforcedDate)
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontStyle: task.isDone(date: enforcedDate)
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: (task.startDate
                                            .isBefore(DateTime.now()) &&
                                        task.endDate.isAfter(DateTime.now()))
                                    ? HexColor.fromHex(stackColor)
                                    : Color(0x88000000),
                                size: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.repeat,
                                color: task.repetition != null
                                    ? HexColor.fromHex(stackColor)
                                    : Color(0x88000000),
                                size: 20,
                              ),
                            ),
                            Text(
                              (task.isDone(date: enforcedDate) &&
                                          task.hasNext &&
                                          enforcedDate == null
                                      ? 'Next: '
                                      : '') +
                                  DateFormat('hh:mm a, dd MMM yyyy').format(
                                    enforcedDate != null
                                        ? DateTime(
                                            enforcedDate.year,
                                            enforcedDate.month,
                                            enforcedDate.day,
                                            task.startDate.hour,
                                            task.startDate.minute,
                                          )
                                        : task.nextDueDate(),
                                  ),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                          ],
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
