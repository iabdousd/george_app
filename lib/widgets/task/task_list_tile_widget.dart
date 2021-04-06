import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskListTileWidget extends StatefulWidget {
  final Task task;
  final String stackColor;
  final DateTime enforcedDate;
  final bool showTimer;
  final bool showDescription;

  const TaskListTileWidget({
    Key key,
    @required this.task,
    @required this.stackColor,
    this.enforcedDate,
    this.showTimer: false,
    this.showDescription: false,
  }) : super(key: key);

  @override
  _TaskListTileWidgetState createState() => _TaskListTileWidgetState();
}

class _TaskListTileWidgetState extends State<TaskListTileWidget> {
  final StreamController _realTimeUpdateTimer = StreamController.broadcast();
  Timer updateTimer;

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
              'Would you really like to delete \'${widget.task.title.toUpperCase()}\' ?'),
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
                await widget.task.delete();
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
        task: widget.task,
        goalRef: widget.task.goalRef,
        stackRef: widget.task.stackRef,
        goalTitle: widget.task.goalTitle,
        stackTitle: widget.task.stackTitle,
        stackColor: widget.task.stackColor,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  @override
  void initState() {
    super.initState();
    updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _realTimeUpdateTimer.add(0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _realTimeUpdateTimer.close();
    updateTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // print('${widget.task.title}: ${widget.task.dueDates}');
    bool inSchedule = DateTime(
          widget.task.startDate.year,
          widget.task.startDate.month,
          widget.task.startDate.day,
          widget.task.startTime.hour,
          widget.task.startTime.minute,
        ).isBefore(DateTime.now()) &&
        DateTime(
          widget.task.endDate.year,
          widget.task.endDate.month,
          widget.task.endDate.day,
          widget.task.endTime.hour,
          widget.task.endTime.minute,
        ).isAfter(DateTime.now());

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
      // height: 64.0 + 20,
      child: GestureDetector(
        onTap: () => _editTask(context),
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: widget.task.isDone(date: widget.enforcedDate)
                  ? Theme.of(context).backgroundColor.withOpacity(.8)
                  : Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () => widget.task.accomplish(
                            customDate: widget.enforcedDate,
                            unChecking:
                                widget.task.isDone(date: widget.enforcedDate),
                          ),
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            HexColor.fromHex(widget.stackColor),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                  ),
                                ),
                                if (widget.task
                                    .isDone(date: widget.enforcedDate))
                                  Center(
                                    child: SvgPicture.asset(
                                      'assets/images/icons/done.svg',
                                      color:
                                          HexColor.fromHex(widget.stackColor),
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
                          margin: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 10,
                          ),
                          height: widget.showTimer
                              ? MediaQuery.of(context).size.width / 2
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.task.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            decoration: widget.task.isDone(
                                                    date: widget.enforcedDate)
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            fontStyle: widget.task.isDone(
                                                    date: widget.enforcedDate)
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          DateFormat('hh:mm a').format(
                                            DateTime(
                                              1970,
                                              1,
                                              1,
                                              widget.task.startTime.hour,
                                              widget.task.startTime.minute,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              if (widget.showDescription &&
                                  widget.task.description.isNotEmpty)
                                Text(
                                  widget.task.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                      ),
                                  textAlign: TextAlign.justify,
                                ),
                              if (widget.showDescription &&
                                  widget.task.description.isNotEmpty)
                                SizedBox(
                                  height: 8,
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    // widget.task.repetition?.type != null ?
                                    MainAxisAlignment.spaceBetween
                                // : MainAxisAlignment.start
                                ,
                                children: [
                                  Container(
                                    // padding: const EdgeInsets.only(
                                    //   right: 16.0,
                                    // ),
                                    child: Icon(
                                      Icons.repeat,
                                      color: widget.task.repetition != null
                                          ? HexColor.fromHex(widget.stackColor)
                                          : Color(0x88000000),
                                      size: 16,
                                    ),
                                  ),
                                  if (widget.task.repetition?.type != null)
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                            right: 4.0,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/images/icons/completion.svg',
                                            color: HexColor.fromHex(
                                                widget.stackColor),
                                            height: 16,
                                            width: 16,
                                          ),
                                        ),
                                        Text(
                                          widget.task.completionRate + "%",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                                fontWeight: FontWeight.w300,
                                              ),
                                        ),
                                      ],
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.calendar_today_outlined,
                                            color: inSchedule
                                                ? HexColor.fromHex(
                                                    widget.stackColor)
                                                : Color(0x88000000),
                                            size: 16,
                                          ),
                                        ),
                                        Text(
                                          // (widget.task.isDone(
                                          //                 date: widget
                                          //                     .enforcedDate) &&
                                          //             widget.task.hasNext &&
                                          //             widget.enforcedDate == null
                                          //         ? 'Next: '
                                          //         : '') +
                                          (widget.task.nextDueDate() == null
                                              ? 'Task completed'
                                              : (DateFormat('EEE, dd MMM')
                                                  .format(
                                                  widget.enforcedDate != null
                                                      ? DateTime(
                                                          widget.enforcedDate
                                                              .year,
                                                          widget.enforcedDate
                                                              .month,
                                                          widget
                                                              .enforcedDate.day,
                                                        )
                                                      : DateTime(
                                                          widget.task
                                                              .nextDueDate()
                                                              .year,
                                                          widget.task
                                                              .nextDueDate()
                                                              .month,
                                                          widget.task
                                                              .nextDueDate()
                                                              .day,
                                                        ),
                                                ))),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                                fontWeight: FontWeight.w300,
                                              ),
                                        ),
                                      ],
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
                if (widget.showTimer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: StreamBuilder<Object>(
                        stream: _realTimeUpdateTimer.stream,
                        builder: (context, snapshot) {
                          return Container(
                            color: HexColor.fromHex(widget.task.stackColor),
                            height: 2,
                            width: ((DateTime.now().hour +
                                            DateTime.now().minute / 60 +
                                            DateTime.now().second / (60 * 60) -
                                            widget.task.startTime.hour -
                                            widget.task.startTime.minute / 60) /
                                        (widget.task.endTime.hour +
                                            widget.task.endTime.minute / 60 -
                                            widget.task.startTime.hour -
                                            widget.task.startTime.minute / 60))
                                    .abs() *
                                MediaQuery.of(context).size.width,
                          );
                        }),
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
