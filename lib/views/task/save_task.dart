import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/forms/date_picker.dart';
import 'package:stackedtasks/widgets/forms/time_picker.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/widgets/shared/app_checkbox.dart';
import 'package:stackedtasks/widgets/shared/bottom_sheet_head.dart';

import 'task_partners.dart';

class SaveTaskPage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final String goalTitle;
  final String stackTitle;

  final String stackColor;
  final Task task;
  final bool addingPartner;
  final List<String> stackPartners;

  SaveTaskPage({
    Key key,
    @required this.goalRef,
    @required this.stackRef,
    @required this.goalTitle,
    @required this.stackTitle,
    @required this.stackColor,
    this.addingPartner: false,
    this.task,
    this.stackPartners,
  }) : super(key: key);

  @override
  _SaveTaskPageState createState() => _SaveTaskPageState();
}

class _SaveTaskPageState extends State<SaveTaskPage> {
  Task task;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _weeksCountController;
  TextEditingController _dayInMonthController = TextEditingController();
  TextEditingController _monthsCountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<int> selectedWeekDays = [];
  List<UserModel> toBeInvited = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  DateTime startTime = DateTime(
    1970,
    1,
    1,
    DateTime.now().hour,
    DateTime.now().minute,
  );
  DateTime endTime = DateTime(
    1970,
    1,
    1,
    DateTime.now().hour + 1,
    DateTime.now().minute,
  );
  Map<int, String> weekDays = {
    0: 'Monday',
    1: 'Tuesday',
    2: 'Wednesday',
    3: 'Thursday',
    4: 'Friday',
    5: 'Saturday',
    6: 'Sunday',
  };

  bool anyTime = false;
  String repetition = 'No repetition';

  _submitTask() async {
    if (!_formKey.currentState.validate()) return;
    if (repetition == 'weekly' && (selectedWeekDays ?? []).length == 0) {
      await showFlushBar(
        title: 'Required field',
        message: 'Please select the days of week first.',
        success: false,
      );
      return;
    }
    toggleLoading(state: true);
    if (repetition == 'No repetition') {
      endDate = startDate;
      if (DateTime(endDate.year, endDate.month, endDate.day, endTime.hour,
              endTime.minute)
          .isBefore(DateTime(startDate.year, startDate.month, startDate.day,
              startTime.hour, startTime.minute))) {
        endDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + 1,
        );
      }
    }
    if (!anyTime &&
        DateTime(endDate.year, endDate.month, endDate.day, endTime.hour,
                endTime.minute)
            .isBefore(DateTime.now())) {
      await toggleLoading(state: false);
      await showFlushBar(
        title: 'Malformat dates',
        message:
            'With the selected dates this date won\'t occurred once! Please make sure you entered the correct dates/times',
        success: false,
      );
      return;
    }

    task = Task(
      id: task?.id,
      userID: getCurrentUser().uid,
      partnersIDs: [
        ...(widget.stackPartners ?? []),
        ...(task?.partnersIDs ?? []),
      ],
      goalRef: widget.goalRef,
      stackRef: widget.stackRef,
      goalTitle: widget.goalTitle,
      stackTitle: widget.stackTitle,
      repetition: TaskRepetition(
        type: repetition,
        weeksCount: int.tryParse(_weeksCountController.text),
        selectedWeekDays: (selectedWeekDays ?? [])..sort(),
        monthsCount: int.tryParse(_monthsCountController.text),
        dayNumber: int.tryParse(_dayInMonthController.text),
      ),
      title: _titleController.text,
      description: _descriptionController.text,
      creationDate: DateTime.now(),
      startDate: DateTime.utc(startDate.year, startDate.month, startDate.day),
      endDate: DateTime.utc(endDate.year, endDate.month, endDate.day),
      startTime: startTime,
      endTime: endTime,
      status: task?.status ?? 0,
      anyTime: anyTime,
      stackColor: widget.stackColor,
      donesHistory: task?.donesHistory ?? [],
      oldDueDatesCount: task?.dueDates?.length ?? 0,
      oldDuration:
          task != null ? task.endTime.difference(task.startTime) : Duration(),
    );
    await task.save(
      updateSummaries: true,
    );
    if (toBeInvited.isNotEmpty) {
      for (final foundUser in toBeInvited) {
        await NotificationRepository.addTaskNotification(
          task,
          foundUser.uid,
        );
      }
    }
    if (widget.goalRef == 'inbox' && widget.stackRef == 'inbox') {
      final res = await InboxRepository.saveInboxItem(
        INBOX_TASK_ITEM_TYPE,
        reference: task.id,
      );
      if (!res.status) {
        await toggleLoading(state: false);
        await showFlushBar(
          title: 'Error',
          message:
              'An error occurred while adding your task to the inbox. Please try again later.',
          success: false,
        );
        return;
      }
    }
    toggleLoading(state: false);
    Navigator.of(context).pop(true);
    showFlushBar(
      title: 'Task added successfully!',
      message: 'You can now see your task in tasks list.',
    );
  }

  _pickStartTime(DateTime pickedTime) async {
    setState(() {
      startTime = pickedTime;
    });
  }

  _pickEndTime(DateTime pickedTime) async {
    setState(() {
      endTime = pickedTime;
    });
  }

  _pickStartDateOnly(DateTime pickedDate) async {
    setState(() {
      startDate = pickedDate;
      if (pickedDate.isAfter(endDate))
        endDate = pickedDate.add(Duration(days: 1));
    });
  }

  _pickEndDateOnly(DateTime pickedDate) async {
    setState(() {
      endDate = pickedDate;
    });
  }

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _weeksCountController = TextEditingController(
      text: widget.task?.repetition?.weeksCount != null
          ? max(1, widget.task.repetition.weeksCount).toString()
          : '1',
    );

    anyTime = widget.goalRef == 'inbox';
    if (task != null) {
      _titleController.text = task.title ?? '';
      _descriptionController.text = task.description ?? '';
      startDate = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day,
        0,
        0,
      );
      endDate = DateTime(
        task.endDate.year,
        task.endDate.month,
        task.endDate.day,
        0,
        0,
      );
      startTime = DateTime(
        1970,
        1,
        1,
        task.startTime.hour,
        task.startTime.minute,
      );
      endTime = DateTime(
        1970,
        1,
        1,
        task.endTime.hour,
        task.endTime.minute,
      );

      anyTime = task.anyTime;
      if (task.repetition != null) {
        repetition = task.repetition.type ?? repetition;

        selectedWeekDays = task.repetition.selectedWeekDays ?? [];
        _dayInMonthController.text =
            (task.repetition.dayNumber ?? '').toString();
        _monthsCountController.text =
            (task.repetition.monthsCount ?? '').toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).backgroundColor,
      ),
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
      margin: EdgeInsets.only(
        top: 50,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BottomSheetHead(
              title: task?.id != null ? 'Task Details' : 'New Task',
              onSubmit: _submitTask,
            ),

            // PARTNERS
            TaskPartners(
              task: task,
              deletePartner: (UserModel partner) =>
                  task.partnersIDs.removeWhere(
                (element) => element == partner.uid,
              ),
              invitePartner: (_) => toBeInvited.add(_),
            ),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task title',
                hintText: 'The title of the task',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
              ),
              validator: (t) {
                if (t.isEmpty) return 'The task title is required';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            // if (widget.goalRef != 'inbox')
            //   Container(
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).backgroundColor,
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     margin: EdgeInsets.symmetric(vertical: 8.0),
            //     child: TextFormField(
            //       controller: _descriptionController,
            //       decoration: InputDecoration(
            //         labelText: 'Task description',
            //         hintText: 'The description of the task',
            //         contentPadding: const EdgeInsets.symmetric(
            //           vertical: 20.0,
            //           horizontal: 20.0,
            //         ),
            //         alignLabelWithHint: true,
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8.0),
            //           borderSide: BorderSide(width: 1),
            //         ),
            //       ),
            //       minLines: 5,
            //       maxLines: 7,
            //     ),
            //   ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Any time',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF3B404A),
                    ),
                  ),
                  FlutterSwitch(
                    width: 52.0,
                    height: 32.0,
                    toggleSize: 32.0,
                    padding: 0,
                    value: anyTime,
                    onToggle: (value) => setState(() => anyTime = value),
                    activeColor: HexColor.fromHex(widget.stackColor),
                    inactiveColor: Colors.transparent,
                    switchBorder: Border.all(
                      width: 2,
                      color: Color(0xFFE5E5EA),
                    ),
                    inactiveToggleBorder: Border.all(
                      width: 2,
                      color: Color(0xFFE5E5EA),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TimePickerWidget(
                    title: 'Start time',
                    active: !anyTime,
                    initialTime: DateTime(
                      1970,
                      1,
                      1,
                      startTime.hour,
                      startTime.minute,
                    ),
                    color: widget.stackColor,
                    onSubmit: _pickStartTime,
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      right: 8.0,
                    ),
                  ),
                ),
                Expanded(
                  child: TimePickerWidget(
                    title: 'End time',
                    active: !anyTime,
                    initialTime: DateTime(
                      1970,
                      1,
                      1,
                      endTime.hour,
                      endTime.minute,
                    ),
                    color: widget.stackColor,
                    onSubmit: _pickEndTime,
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      left: 8.0,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DatePickerWidget(
                    key: const Key('start_date'),
                    title: 'Start date',
                    color: widget.stackColor,
                    onSubmit: _pickStartDateOnly,
                    selectedDate: DateTime(
                      startDate.year,
                      startDate.month,
                      startDate.day,
                      startTime.hour,
                      startTime.minute,
                    ),
                    endDate: DateTime.now().add(Duration(days: 365)),
                    dateFormat: 'dd MMMM yyyy',
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      right: 8.0,
                    ),
                  ),
                ),
                if (repetition != 'No repetition')
                  Expanded(
                    child: DatePickerWidget(
                      key: const Key('end_date'),
                      title: 'End date',
                      color: widget.stackColor,
                      startDate: DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      onSubmit: _pickEndDateOnly,
                      selectedDate: DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                      ),
                      dateFormat: 'dd MMMM yyyy',
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        left: 8.0,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 11,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.0),
              child: DropdownButtonFormField(
                onChanged: (value) {
                  setState(() {
                    repetition = value;
                  });
                },
                value: repetition,
                decoration: InputDecoration(
                  labelText: 'Task repetition',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                ),
                items: ['No repetition', ...task_constants.REPETITION_OPTIONS]
                    .map(
                      (e) => DropdownMenuItem(
                        child: Text(
                            e.substring(0, 1).toUpperCase() + e.substring(1)),
                        value: e == 'none' ? null : e,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (repetition == 'weekly')
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.0),
                      child: DropdownButtonFormField(
                        onChanged: (value) {
                          _weeksCountController.text = value;
                        },
                        value: _weeksCountController.text,
                        decoration: InputDecoration(
                          labelText: 'Repeat every',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                        items: List<Map<String, String>>.generate(
                          5,
                          (index) => {
                            'value': '${index + 1}',
                            'label': '${index + 1} Weeks',
                          },
                        )
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text(
                                  e['label'],
                                ),
                                value: e['value'],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 32.0,
                        top: 24,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Repeat on',
                            style: TextStyle(
                              color: Color(0xFFB2B5C3),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.custom(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 56,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8.0),
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            child: Row(
                              children: [
                                AppCheckbox(
                                    width: 18,
                                    height: 18,
                                    value: selectedWeekDays.contains(
                                        weekDays.keys.elementAt(index)),
                                    onChanged: (value) => setState(() => value
                                        ? selectedWeekDays
                                            .add(weekDays.keys.elementAt(index))
                                        : selectedWeekDays.remove(
                                            weekDays.keys.elementAt(index)))),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    weekDays.values.elementAt(index),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: weekDays.length,
                      ),
                    ),
                  ],
                ),
              )
            else if (repetition == 'monthly')
              Container(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day:  ',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      child: TextFormField(
                        validator: (t) =>
                            t.isEmpty ? 'This field is required' : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 4.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(width: 1),
                          ),
                          errorStyle: TextStyle(height: 0),
                          counterText: '',
                        ),
                        scrollPadding: EdgeInsets.zero,
                        textAlign: TextAlign.center,
                        controller: _dayInMonthController,
                        maxLength: 2,
                      ),
                    ),
                    Text(
                      '  of every:  ',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      child: TextFormField(
                        validator: (t) =>
                            t.isEmpty ? 'This field is required' : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 4.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(width: 1),
                          ),
                          errorStyle: TextStyle(height: 0),
                          counterText: '',
                        ),
                        scrollPadding: EdgeInsets.zero,
                        textAlign: TextAlign.center,
                        controller: _monthsCountController,
                        maxLength: 2,
                      ),
                    ),
                    Text(
                      '  months',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
