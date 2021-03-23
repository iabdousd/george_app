import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';

class SaveTaskPage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final Task task;
  SaveTaskPage(
      {Key key, @required this.goalRef, @required this.stackRef, this.task})
      : super(key: key);

  @override
  _SaveTaskPageState createState() => _SaveTaskPageState();
}

class _SaveTaskPageState extends State<SaveTaskPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<String> availableColors = [
    '#f7f13b',
    '#ed5858',
    '#70f065',
    '#eba373',
    '#eb73d7',
    '#4b9ede',
  ];
  String selectedColor = '#ed5858';

  pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'The color of your task item',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(8.0),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: availableColors
                  .map(
                    (e) => Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = e;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.brightness_1,
                            color: HexColor.fromHex(e),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  _submitTask() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await Task(
      goalRef: widget.goalRef,
      stackRef: widget.stackRef,
      id: widget.task?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      creationDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      status: 0,
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
              DatePickerWidget(
                title: 'I want to start this task on',
                color: selectedColor,
                onSubmit: _pickStartDate,
                initialDate: startDate,
                dateFormat: 'hh:mm a, dd MMM',
                withTime: true,
              ),
              DatePickerWidget(
                title: 'I want to end this task on',
                color: selectedColor,
                onSubmit: _pickEndDate,
                initialDate: endDate,
                dateFormat: 'hh:mm a, dd MMM',
                withTime: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
