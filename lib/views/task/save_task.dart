import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:george_project/constants/models/task.dart' as task_constants;

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
  TextEditingController _descriptionController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(hours: 1));
  String repetition = 'No repetition';

  _submitTask() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await Task(
      goalRef: widget.goalRef,
      repetition: repetition,
      stackRef: widget.stackRef,
      id: widget.task?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      creationDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      status: 0,
      stackColor: widget.stackColor,
      donesHistory: widget.task.donesHistory ?? [],
    ).save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Task added successfully!',
      message: 'You can now see your task in tasks list.',
    );
  }

  _pickStartDate(DateTime picked) async {
    setState(() {
      startDate = picked;
    });
  }

  _pickEndDate(DateTime picked) async {
    setState(() {
      endDate = picked;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task.title ?? '';
      _descriptionController.text = widget.task.description ?? '';
      repetition = widget.task?.repetition ?? repetition;
      startDate = widget.task.startDate;
      endDate = widget.task.endDate;
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
                  minLines: 2,
                  maxLines: 5,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
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
              Row(
                children: [
                  Expanded(
                    child: DatePickerWidget(
                      title: 'Start:',
                      color: widget.stackColor,
                      onSubmit: _pickStartDate,
                      initialDate: startDate,
                      dateFormat: 'hh:mm a, dd MMM',
                      withTime: true,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: DatePickerWidget(
                      title: 'End',
                      color: widget.stackColor,
                      startDate: startDate,
                      onSubmit: _pickEndDate,
                      initialDate: endDate,
                      dateFormat: 'hh:mm a, dd MMM',
                      withTime: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
