import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/forms/time_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:george_project/constants/models/task.dart' as task_constants;
import 'package:intl/intl.dart';

class SaveTaskPage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final String stackColor;
  final Task task;
  SaveTaskPage(
      {Key key,
      @required this.goalRef,
      @required this.stackRef,
      @required this.stackColor,
      this.task})
      : super(key: key);

  @override
  _SaveTaskPageState createState() => _SaveTaskPageState();
}

class _SaveTaskPageState extends State<SaveTaskPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _weeksCountController = TextEditingController();
  TextEditingController _dayInMonthController = TextEditingController();
  TextEditingController _monthsCountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<int> selectedWeekDays = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(hours: 2));
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
    0: 'Mon',
    1: 'Tue',
    2: 'Wed',
    3: 'Thu',
    4: 'Fri',
    5: 'Sat',
    6: 'Sun',
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
    if (DateTime(endDate.year, endDate.month, endDate.day, endTime.hour,
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
    Task task = Task(
      goalRef: widget.goalRef,
      repetition: TaskRepetition(
        type: repetition,
        weeksCount: int.tryParse(_weeksCountController.text),
        selectedWeekDays: (selectedWeekDays ?? [])..sort(),
        monthsCount: int.tryParse(_monthsCountController.text),
        dayNumber: int.tryParse(_dayInMonthController.text),
      ),
      stackRef: widget.stackRef,
      id: widget.task?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      creationDate: DateTime.now(),
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      startTime: startTime,
      endTime: endTime,
      status: 0,
      anyTime: anyTime,
      stackColor: widget.stackColor,
      donesHistory: widget.task?.donesHistory ?? [],
      taskNotes: widget.task?.taskNotes ?? [],
    );
    await task.save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
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
    if (widget.task != null) {
      _titleController.text = widget.task.title ?? '';
      _descriptionController.text = widget.task.description ?? '';
      startDate = DateTime(
        widget.task.startDate.year,
        widget.task.startDate.month,
        widget.task.startDate.day,
        0,
        0,
      );
      endDate = DateTime(
        widget.task.endDate.year,
        widget.task.endDate.month,
        widget.task.endDate.day,
        0,
        0,
      );
      startTime = DateTime(
        1970,
        1,
        1,
        widget.task.startTime.hour,
        widget.task.startTime.minute,
      );
      endTime = DateTime(
        1970,
        1,
        1,
        widget.task.endTime.hour,
        widget.task.endTime.minute,
      );

      anyTime = widget.task.anyTime;
      if (widget.task.repetition != null) {
        repetition = widget.task.repetition.type ?? repetition;
        _weeksCountController.text =
            (widget.task.repetition.weeksCount ?? '').toString();
        selectedWeekDays = widget.task.repetition.selectedWeekDays ?? [];
        _dayInMonthController.text =
            (widget.task.repetition.dayNumber ?? '').toString();
        _monthsCountController.text =
            (widget.task.repetition.monthsCount ?? '').toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.task != null ? 'Task details' : 'New Task',
        actions: [
          TextButton(
            onPressed: _submitTask,
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task title',
                    hintText: 'The title of the task',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  validator: (t) {
                    if (t.isEmpty) return 'The task title is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Task description',
                    hintText: 'The description of the task',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  minLines: 5,
                  maxLines: 7,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Any time:',
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 18.0,
                          color: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .color
                              .withOpacity(.75),
                        ),
                  ),
                  Switch(
                    value: anyTime,
                    onChanged: (value) => setState(() => anyTime = value),
                    activeColor: HexColor.fromHex(widget.stackColor),
                  ),
                ],
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
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DatePickerWidget(
                      title: 'Start date',
                      color: widget.stackColor,
                      onSubmit: _pickStartDateOnly,
                      initialDate: DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      endDate: DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                      ),
                      dateFormat: 'dd MMMM yyyy',
                    ),
                  ),
                  if (repetition != 'No repetition')
                    Expanded(
                      child: DatePickerWidget(
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
                        initialDate: DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        ),
                        dateFormat: 'dd MMMM yyyy',
                        margin: EdgeInsets.only(top: 8.0),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: DropdownButtonFormField(
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      repetition = value;
                    });
                  },
                  value: repetition,
                  decoration: InputDecoration(
                    labelText: 'Task repetition:',
                    prefixIcon: Icon(
                      repetition == 'No repetition'
                          ? Icons.repeat_one
                          : Icons.repeat,
                      size: 24,
                      color: HexColor.fromHex(widget.stackColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Evey  ',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                validator: (t) => t.isEmpty ? '' : null,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
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
                                controller: _weeksCountController,
                                maxLength: 1,
                              ),
                            ),
                            Text(
                              '  weeks on',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        padding: EdgeInsets.all(8.0),
                        children: weekDays.keys
                            .map((key) => Container(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                          value: selectedWeekDays.contains(key),
                                          onChanged: (value) => setState(() =>
                                              value
                                                  ? selectedWeekDays.add(key)
                                                  : selectedWeekDays
                                                      .remove(key))),
                                      Text(weekDays[key]),
                                    ],
                                  ),
                                ))
                            .toList(),
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
      ),
    );
  }
}
