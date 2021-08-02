import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/actiivity/task_activities_view/task_activities_view.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackedtasks/widgets/shared/app_expansion_tile.dart';

import 'task_note_input.dart';
import 'task_tile_timer.dart';

class TaskListTileWidget extends StatefulWidget {
  final Task task;
  final String stackColor;
  final DateTime enforcedDate;
  final bool showTimer,
      showNoteInput,
      showDescription,
      showHirachy,
      showPartners,
      selected,
      showDragIndicator;
  final VoidCallback onLongPress;
  final VoidCallback onClickEvent;
  final VoidCallback onAccomplishmentEvent;

  const TaskListTileWidget({
    Key key,
    @required this.task,
    @required this.stackColor,
    this.enforcedDate,
    this.showTimer: false,
    this.showNoteInput: false,
    this.showHirachy: false,
    this.showPartners: false,
    this.selected: false,
    this.showDescription: false,
    this.onLongPress,
    this.onClickEvent,
    this.onAccomplishmentEvent,
    this.showDragIndicator: true,
  }) : super(key: key);

  @override
  _TaskListTileWidgetState createState() => _TaskListTileWidgetState();
}

class _TaskListTileWidgetState extends State<TaskListTileWidget> {
  bool loadingPartners = true;

  List<UserModel> partners = [];
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
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveTaskPage(
        task: widget.task,
        goalRef: widget.task.goalRef,
        stackRef: widget.task.stackRef,
        goalTitle: widget.task.goalTitle,
        stackTitle: widget.task.stackTitle,
        stackColor: widget.task.stackColor,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _realTimeUpdateTimer.add(0);
    });
    _init();
  }

  void _init() async {
    if (widget.showPartners) {
      if (widget.task.partnersIDs.isNotEmpty) {
        dynamic partnersRef = FirebaseFirestore.instance.collection(USERS_KEY);
        if (widget.task.partnersIDs.isNotEmpty) {
          partnersRef = partnersRef.where(
            USER_UID_KEY,
            whereIn: widget.task.partnersIDs,
          );
        }

        final partnersQuery = await partnersRef.get();
        partners = List<UserModel>.from(partnersQuery.docs.map(
          (e) => UserModel.fromMap(e.data()),
        ));
      }
    }
    setState(() {
      loadingPartners = false;
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

    return Container(
      padding: EdgeInsets.only(
        top: widget.showTimer ? 11 : 6.0,
        bottom: widget.showTimer ? 16 : 6.0,
        left: widget.showTimer ? 16 : 0.0,
        right: widget.showTimer ? 16 : 0.0,
      ),
      decoration: widget.showTimer
          ? BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.12),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          if (widget.showTimer)
            TaskTileTimer(
              task: widget.task,
              editTask: () => _editTask(context),
              deleteTask: () => _deleteTask(context),
              taskEndedCallback: widget.onAccomplishmentEvent,
            ),
          if (widget.showNoteInput)
            TaskNoteInput(
              task: widget.task,
            ),
          if (widget.showHirachy)
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedImageProvider(getCurrentUser().photoURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      getCurrentUser().displayName,
                      style: TextStyle(
                        color: Color(0xFF3B404A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.showHirachy)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 15.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.goalTitle + ' > ' + widget.task.stackTitle,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  IconButton(
                    onPressed: _showActivities,
                    icon: SvgPicture.asset('assets/images/icons/activity2.svg'),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.12),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: widget.onClickEvent ?? () => _editTask(context),
              onLongPress: widget.onLongPress,
              child: Slidable(
                actionPane: SlidableScrollActionPane(),
                enabled: !widget.showTimer,
                actionExtentRatio: 0.25,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? Color.lerp(
                            Theme.of(context).primaryColor,
                            Theme.of(context).backgroundColor,
                            .5,
                          )
                        : Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.task
                                    .accomplish(
                                      customDate: widget.enforcedDate,
                                      unChecking: widget.task
                                          .isDone(date: widget.enforcedDate),
                                    )
                                    .then(
                                      (value) =>
                                          widget.onAccomplishmentEvent != null
                                              ? widget.onAccomplishmentEvent()
                                              : null,
                                    );
                              },
                              child: Container(
                                width: 32.0,
                                height: 32.0,
                                margin: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 14,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 18.0,
                                        height: 18.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: widget.task.nextDueDate() ==
                                                    null
                                                ? Color(0xFF3B404A).withOpacity(
                                                    .28,
                                                  )
                                                : widget.task.isDone(
                                                    date: widget.enforcedDate,
                                                  )
                                                    ? HexColor.fromHex(
                                                        widget.stackColor,
                                                      )
                                                    : Color(0xFFB2B5C3),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                      ),
                                    ),
                                    if (widget.task
                                        .isDone(date: widget.enforcedDate))
                                      Center(
                                        child: SvgPicture.asset(
                                          'assets/images/icons/done.svg',
                                          color: widget.task.nextDueDate() ==
                                                  null
                                              ? Color(0xFF3B404A).withOpacity(
                                                  .28,
                                                )
                                              : HexColor.fromHex(
                                                  widget.stackColor,
                                                ),
                                          width: 9.5,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 16,
                                  right: 10,
                                  bottom: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                      color: widget.task
                                                                  .nextDueDate() ==
                                                              null
                                                          ? Color(0xFF3B404A)
                                                              .withOpacity(
                                                              .28,
                                                            )
                                                          : Color(0xff3B404A),
                                                    ),
                                              ),
                                            ),
                                            if (!widget.showTimer &&
                                                widget.showDragIndicator)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 16,
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/images/icons/drag_indicator.svg',
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
                                      AppExpansionTile(
                                        title: Text(
                                          'Task details',
                                        ),
                                        expandedCrossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            widget.task.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13,
                                                ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ],
                                      ),
                                    if (widget.showDescription &&
                                        widget.task.description.isNotEmpty)
                                      SizedBox(
                                        height: 8,
                                      ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          // widget.task.repetition?.type != null ?
                                          MainAxisAlignment.spaceBetween
                                      // : MainAxisAlignment.start
                                      ,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            widget.task.anyTime
                                                ? 'Any time'
                                                : (DateFormat('hh a').format(
                                                      DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day,
                                                        widget.task.startTime
                                                            .hour,
                                                        widget.task.startTime
                                                            .minute,
                                                      ),
                                                    ) +
                                                    ' - ' +
                                                    DateFormat('hh a').format(
                                                      DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day,
                                                        widget
                                                            .task.endTime.hour,
                                                        widget.task.endTime
                                                            .minute,
                                                      ),
                                                    )),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  widget.task.nextDueDate() ==
                                                          null
                                                      ? Color(0xFF3B404A)
                                                          .withOpacity(
                                                          .28,
                                                        )
                                                      : Color(0xff3B404A),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/icons/repeat.svg',
                                                color: widget.task
                                                            .nextDueDate() ==
                                                        null
                                                    ? Color(0xFF3B404A)
                                                        .withOpacity(
                                                        .28,
                                                      )
                                                    : widget.task.repetition !=
                                                            null
                                                        ? HexColor.fromHex(
                                                            widget.stackColor,
                                                          )
                                                        : Color(0xFFB2B5C3),
                                                width: 20,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 4.0,
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/images/icons/calendar.svg',
                                                  color: inSchedule
                                                      ? HexColor.fromHex(
                                                          widget.stackColor,
                                                        )
                                                      : Color(
                                                          0xFFB2B5C3,
                                                        ),
                                                  width: 20,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('${widget.task.repetition == null ? 'EEE, ' : ''}d MMM')
                                                        .format(
                                                      DateTime(
                                                        widget.task.startDate
                                                            .year,
                                                        widget.task.startDate
                                                            .month,
                                                        widget
                                                            .task.startDate.day,
                                                      ),
                                                    ) +
                                                    (widget.task.repetition ==
                                                            null
                                                        ? ''
                                                        : ' - ' +
                                                            DateFormat('d MMM')
                                                                .format(
                                                              DateTime(
                                                                widget
                                                                    .task
                                                                    .endDate
                                                                    .year,
                                                                widget
                                                                    .task
                                                                    .endDate
                                                                    .month,
                                                                widget
                                                                    .task
                                                                    .endDate
                                                                    .day,
                                                              ),
                                                            )),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                    .copyWith(
                                                      fontSize: 13,
                                                      color: widget.task
                                                                  .nextDueDate() ==
                                                              null
                                                          ? Color(0xFF3B404A)
                                                              .withOpacity(
                                                              .28,
                                                            )
                                                          : Color(0xff3B404A),
                                                      fontWeight:
                                                          FontWeight.w300,
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
                      ],
                    ),
                  ),
                ),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    onTap: () => _editTask(context),
                    iconWidget: LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth - 24,
                        height: constraints.maxWidth - 24,
                        margin: EdgeInsets.only(
                          left: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
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
                          width: constraints.maxWidth - 24,
                          height: constraints.maxWidth - 24,
                          margin: EdgeInsets.only(
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6.0,
                                offset: Offset(0, 3),
                              )
                            ],
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
          ),
        ],
      ),
    );
  }

  void _showActivities() {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActivitiesView(
        task: widget.task,
      ),
    );
  }
}
