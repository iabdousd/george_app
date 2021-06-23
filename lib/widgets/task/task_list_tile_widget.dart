import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackedtasks/widgets/note/task_notes_thread.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_expansion_tile.dart';

class TaskListTileWidget extends StatefulWidget {
  final Task task;
  final String stackColor;
  final DateTime enforcedDate;
  final bool showTimer,
      showNoteInput,
      showDescription,
      showHirachy,
      showLastNotes,
      showPartners,
      selected;
  final VoidCallback onLongPress;
  final VoidCallback onClickEvent;

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
    this.showPartners: false,
    this.selected: false,
    this.onLongPress,
    this.onClickEvent,
  }) : super(key: key);

  @override
  _TaskListTileWidgetState createState() => _TaskListTileWidgetState();
}

class _TaskListTileWidgetState extends State<TaskListTileWidget> {
  bool loading = false;
  bool loadingPartners = true;
  bool privateNotes = false;
  List<PickedFile> images = [];
  List<UserModel> partners = [];
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
                  enabled: !loading,
                  decoration: InputDecoration(
                    labelText: 'Task Notes',
                    hintText: 'The content of the note',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    alignLabelWithHint: false,
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 10,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final image in images)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image.path),
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              child: InkWell(
                                  onTap: () => setState(
                                        () => images.remove(image),
                                      ),
                                  child: Icon(Icons.close)),
                              top: 4,
                              right: 4,
                            ),
                          ],
                        ),
                      ),
                  ],
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: addAttachment,
                          icon: Icon(Icons.attach_file),
                        ),
                        Switch(
                          value: privateNotes,
                          onChanged: (val) => setState(
                            () => privateNotes = val,
                          ),
                        ),
                        Text('Private'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_contentController.text
                                .replaceAll('\n', '')
                                .trim() ==
                            '') return;
                        setState(() => loading = true);
                        Note note = Note(
                          userID: getCurrentUser().uid,
                          status: privateNotes ? 1 : 0,
                          content: _contentController.text.trim(),
                          goalRef: widget.task.goalRef,
                          stackRef: widget.task.stackRef,
                          taskRef: widget.task.id,
                          feedArticleID: widget.task.id,
                          taskTitle: widget.task.title,
                          creationDate: DateTime.now(),
                        );
                        await note.save();
                        if (images.isNotEmpty)
                          await note.addAttachments(images);

                        if (!privateNotes) {
                          final articleDocument = await FirebaseFirestore
                              .instance
                              .collection(TASKS_KEY)
                              .doc(widget.task.taskID)
                              .get();

                          await articleDocument.reference.update({
                            COMMENTS_COUNT_KEY:
                                (articleDocument.data()[COMMENTS_COUNT_KEY] ??
                                        0) +
                                    1,
                          });
                        }
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
            onTap: widget.onClickEvent ?? () => _editTask(context),
            onLongPress: widget.onLongPress,
            child: Slidable(
              actionPane: SlidableScrollActionPane(),
              enabled: !widget.showLastNotes,
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
                      : widget.task.isDone(date: widget.enforcedDate)
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
                          if (widget.showPartners)
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
                                  if (loadingPartners)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEEEEEE),
                                        shape: BoxShape.circle,
                                      ),
                                      width: 28,
                                      height: 28,
                                      padding: EdgeInsets.all(4),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation(
                                            HexColor.fromHex(
                                              widget.task.stackColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ...partners.map(
                                      (e) => Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          child: e.photoURL == null
                                              ? Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .color
                                                        .withOpacity(.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      e.fullName[0]
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .backgroundColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Image(
                                                  image: CachedImageProvider(
                                                    e.photoURL,
                                                  ),
                                                  width: 28,
                                                  height: 28,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () => Get.to(
                                      () => SaveTaskPage(
                                        task: widget.task,
                                        goalRef: widget.task.goalRef,
                                        stackRef: widget.task.stackRef,
                                        goalTitle: widget.task.goalTitle,
                                        stackTitle: widget.task.stackTitle,
                                        stackColor: widget.task.stackColor,
                                        addingPartner: true,
                                      ),
                                      popGesture: true,
                                      transition:
                                          Transition.rightToLeftWithFade,
                                    ),
                                    child: Container(
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
                                  ),
                                ],
                              ),
                            ),
                          if (widget.showLastNotes)
                            TaskNotesThread(
                              task: widget.task,
                              allTaskNotes: true,
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

  addAttachment() {
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: false,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppActionButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icons.image_outlined,
                label: 'Photos',
                backgroundColor: Theme.of(context).backgroundColor,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 0, top: 4),
                iconSize: 28,
              ),
              AppActionButton(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                backgroundColor: Theme.of(context).backgroundColor,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 4, top: 0),
                iconSize: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickImage(ImageSource imageSource) async {
    PickedFile image;

    try {
      image = await ImagePicker().getImage(
        imageQuality: 80,
        source: imageSource,
      );
    } on Exception catch (e) {
      print(e);
      if (imageSource != ImageSource.gallery)
        _pickImage(ImageSource.gallery);
      else
        showFlushBar(
          title: 'Error',
          message: 'Unknown error happened while importing your images.',
          success: false,
        );
    }
    if (image != null)
      setState(() {
        images.add(image);
      });
  }
}
