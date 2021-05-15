import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/models/note.dart' as note_constants;
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackedtasks/widgets/shared/app_expansion_tile.dart';

class TaskListTileWidget extends StatefulWidget {
  final Task task;
  final String stackColor;
  final DateTime enforcedDate;
  final bool showTimer,
      showNoteInput,
      showDescription,
      showHirachy,
      showLastNotes;

  const TaskListTileWidget({
    Key key,
    @required this.task,
    @required this.stackColor,
    this.enforcedDate,
    this.showTimer: false,
    this.showDescription: false,
    this.showNoteInput: false,
    this.showHirachy: false,
    this.showLastNotes: false,
  }) : super(key: key);

  @override
  _TaskListTileWidgetState createState() => _TaskListTileWidgetState();
}

class _TaskListTileWidgetState extends State<TaskListTileWidget> {
  bool loading = false;
  final StreamController _realTimeUpdateTimer = StreamController.broadcast();
  TextEditingController _contentController = TextEditingController();
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

    return Column(
      children: [
        if (widget.showNoteInput)
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey[400],
                  ),
                ),
                margin: EdgeInsets.only(
                  top: 24.0,
                  left: 34.0,
                  right: 34.0,
                ),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Task Notes',
                    hintText: 'The content of the note',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 5,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 8.0,
                  left: 24.0,
                  right: 34.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        //
                      },
                      icon: Icon(Icons.attach_file),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_contentController.text
                                .replaceAll('\n', '')
                                .trim() ==
                            '') return;
                        setState(() => loading = true);
                        Note note = Note(
                          content: _contentController.text.trim(),
                          goalRef: widget.task.goalRef,
                          stackRef: widget.task.stackRef,
                          taskRef: widget.task.id,
                          taskTitle: widget.task.title,
                          creationDate: DateTime.now(),
                        );
                        await note.save();
                        await widget.task.addNote(note);
                        _contentController.text = '';
                        setState(() => loading = false);
                        showFlushBar(
                          title: 'Note added successfully!',
                          message: 'You can now see your note in notes list.',
                        );
                      },
                      child: loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).backgroundColor,
                                ),
                                strokeWidth: 1,
                              ))
                          : Text('Post'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 16.0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Center(
                                child: GestureDetector(
                                  onTap: () => widget.task.accomplish(
                                    customDate: widget.enforcedDate,
                                    unChecking: widget.task
                                        .isDone(date: widget.enforcedDate),
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
                                                color: HexColor.fromHex(
                                                    widget.stackColor),
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
                                              color: HexColor.fromHex(
                                                  widget.stackColor),
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
                                  margin: EdgeInsets.only(
                                    top: 16,
                                    left: 10,
                                    right: 10,
                                    bottom: widget.showNoteInput ? 0 : 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.showHirachy)
                                            Text(
                                              widget.task.goalTitle +
                                                  ' > ' +
                                                  widget.task.stackTitle,
                                              style: TextStyle(
                                                color: Color(0xFF555555),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
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
                                                        fontSize: 17,
                                                        decoration: widget.task
                                                                .isDone(
                                                                    date: widget
                                                                        .enforcedDate)
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        fontStyle: widget.task
                                                                .isDone(
                                                                    date: widget
                                                                        .enforcedDate)
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              widget.task.anyTime
                                                  ? 'Any time'
                                                  : (DateFormat(
                                                              'hh:mm a, dd MMM')
                                                          .format(
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
                                                      DateFormat('hh:mm a')
                                                          .format(
                                                        DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day,
                                                          widget.task.endTime
                                                              .hour,
                                                          widget.task.endTime
                                                              .minute,
                                                        ),
                                                      )),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
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
                                            // padding: const EdgeInsets.only(
                                            //   right: 16.0,
                                            // ),
                                            child: Icon(
                                              Icons.repeat,
                                              color:
                                                  widget.task.repetition != null
                                                      ? HexColor.fromHex(
                                                          widget.stackColor,
                                                        )
                                                      : Color(0x44000000),
                                              size: 16,
                                            ),
                                          ),
                                          if (widget.task.repetition?.type !=
                                              null)
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  widget.task.completionRate +
                                                      "%",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w300,
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
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Icon(
                                                    Icons
                                                        .calendar_today_outlined,
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
                                                  (widget.task.nextDueDate() ==
                                                          null
                                                      ? 'Task completed'
                                                      : (DateFormat(
                                                              'EEE, dd MMM')
                                                          .format(
                                                          widget.enforcedDate !=
                                                                  null
                                                              ? DateTime(
                                                                  widget
                                                                      .enforcedDate
                                                                      .year,
                                                                  widget
                                                                      .enforcedDate
                                                                      .month,
                                                                  widget
                                                                      .enforcedDate
                                                                      .day,
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
                          SizedBox(height: 12),
                          if (widget.showDescription)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black26,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black26,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.network(
                                      'https://monteluke.com.au/wp-content/gallery/linkedin-profile-pictures/1.jpg',
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: Image.network(
                                        'https://monteluke.com.au/wp-content/gallery/linkedin-profile-pictures/1.jpg',
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      shape: BoxShape.circle,
                                    ),
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.showLastNotes)
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(USERS_KEY)
                                  .doc(getCurrentUser().uid)
                                  .collection(NOTES_KEY)
                                  .where(
                                    note_constants.TASK_REF_KEY,
                                    isEqualTo: widget.task.id,
                                  )
                                  .orderBy(
                                    note_constants.CREATION_DATE_KEY,
                                    descending: true,
                                  )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                print(snapshot.error);

                                if (!snapshot.hasData) {
                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    height: 64,
                                    child: Center(
                                      child: LoadingWidget(),
                                    ),
                                  );
                                }
                                bool showAll = false;

                                return StatefulBuilder(
                                    builder: (context, notesSetState) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: showAll
                                            ? snapshot.data.docs.length + 1
                                            : min(
                                                snapshot.data.docs.length,
                                                (showAll
                                                    ? snapshot.data.docs.length
                                                    : 4)),
                                        itemBuilder: (context, index) {
                                          if ((showAll &&
                                                  index ==
                                                      snapshot
                                                          .data.docs.length) ||
                                              (!showAll &&
                                                  index == 3 &&
                                                  snapshot.data.docs.length >
                                                      3))
                                            return TextButton(
                                              onPressed: () => notesSetState(
                                                () => showAll = !showAll,
                                              ),
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                  EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                showAll
                                                    ? 'Hide notes'
                                                    : 'Show all notes',
                                              ),
                                            );

                                          final note = Note.fromJson(
                                            snapshot.data.docs[index].data(),
                                            id: snapshot.data.docs[index].id,
                                          );
                                          return FadeIn(
                                            duration:
                                                Duration(milliseconds: 350),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  // border: index == 0
                                                  //     ? null
                                                  //     : Border(
                                                  //         top: BorderSide(
                                                  //           color: Colors.black26,
                                                  //         ),
                                                  //       ),
                                                  ),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 4.0,
                                                            bottom: 4.0,
                                                            left: 12.0,
                                                            right: 12.0,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        52),
                                                            child: Image(
                                                              image:
                                                                  CachedImageProvider(
                                                                'https://monteluke.com.au/wp-content/gallery/linkedin-profile-pictures/1.jpg',
                                                              ),
                                                              width: 52,
                                                              height: 52,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        if (index !=
                                                                snapshot
                                                                        .data
                                                                        .docs
                                                                        .length -
                                                                    1 &&
                                                            (showAll ||
                                                                (!showAll &&
                                                                    index !=
                                                                        2)))
                                                          Expanded(
                                                            child: Container(
                                                              width: 1.5,
                                                              color: Color(
                                                                  0xFFAAAAAA),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      .displayName
                                                                      .split(
                                                                          ' ')
                                                                      .first,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  ' - Task Notes ' +
                                                                      DateFormat(
                                                                              'EEE, dd MMM')
                                                                          .format(
                                                                        note.creationDate,
                                                                      ),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                top: 4,
                                                                bottom: 32,
                                                              ),
                                                              child: Text(
                                                                note.content,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  );
                                });
                              },
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
                                                DateTime.now().second /
                                                    (60 * 60) -
                                                widget.task.startTime.hour -
                                                widget.task.startTime.minute /
                                                    60) /
                                            (widget.task.endTime.hour +
                                                widget.task.endTime.minute /
                                                    60 -
                                                widget.task.startTime.hour -
                                                widget.task.startTime.minute /
                                                    60))
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
        ),
      ],
    );
  }
}
