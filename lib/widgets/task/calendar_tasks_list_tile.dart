import 'dart:async';

import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarTaskListTileWidget extends StatefulWidget {
  final Task task;
  final String stackColor;
  final DateTime enforcedDate;
  final double width, height;

  const CalendarTaskListTileWidget({
    Key key,
    @required this.task,
    @required this.stackColor,
    this.enforcedDate,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _CalendarTaskListTileWidgetState createState() =>
      _CalendarTaskListTileWidgetState();
}

class _CalendarTaskListTileWidgetState
    extends State<CalendarTaskListTileWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editTask(context) {
    Get.to(
      () => SaveTaskPage(
        task: widget.task,
        stackRef: widget.task.stackRef,
        goalRef: widget.task.goalRef,
        stackColor: widget.task.stackColor,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: () => _editTask(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: EdgeInsets.only(right: 0),
        width: widget.width.abs(),
        height: widget.height.abs(),
        constraints: BoxConstraints(minHeight: 72),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: HexColor.fromHex(widget.stackColor),
          ),
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                widget.task.title,
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: widget.task.isDone(date: widget.enforcedDate)
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontStyle: widget.task.isDone(date: widget.enforcedDate)
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                overflow: TextOverflow.clip,
                // maxLines: 2,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.only(right: 4.0),
            //       child: Icon(
            //         Icons.calendar_today_outlined,
            //         color: inSchedule
            //             ? HexColor.fromHex(widget.stackColor)
            //             : Color(0x88000000),
            //         size: 16,
            //       ),
            //     ),
            //     Container(
            //       padding: const EdgeInsets.only(
            //         right: 8.0,
            //         left: 4,
            //       ),
            //       child: Icon(
            //         Icons.repeat,
            //         color: widget.task.repetition != null
            //             ? HexColor.fromHex(widget.stackColor)
            //             : Color(0x88000000),
            //         size: 16,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
