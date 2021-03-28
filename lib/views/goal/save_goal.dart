import 'dart:math';

import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/shared/color.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';

class SaveGoalPage extends StatefulWidget {
  final Goal goal;
  SaveGoalPage({Key key, this.goal}) : super(key: key);

  @override
  _SaveGoalPageState createState() => _SaveGoalPageState();
}

class _SaveGoalPageState extends State<SaveGoalPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));

  String selectedColor =
      availableColors[Random().nextInt(availableColors.length - 1)];

  _submitGoal() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await Goal(
      id: widget.goal?.id,
      title: _titleController.text,
      color: selectedColor,
      creationDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      status: 0,
    ).save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Goal added successfully!',
      message: 'You can now see your goal in goals list.',
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
    if (widget.goal != null) {
      _titleController.text = widget.goal.title;
      startDate = widget.goal.startDate;
      endDate = widget.goal.endDate;
      selectedColor = widget.goal.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.goal != null ? 'Goal details' : 'New Goal',
        actions: [
          TextButton(
            onPressed: _submitGoal,
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
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal title',
                      hintText: 'The title of the goal',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    autofocus: true,
                    validator: (t) =>
                        t.isEmpty ? 'Please enter the goal\'s title' : null,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.goal == null)
                        InkWell(
                          onTap: () => pickColor(
                            (e) => setState(() {
                              selectedColor = e;
                            }),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(0x07000000),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.brightness_1,
                              color: HexColor.fromHex(selectedColor),
                              size: 32,
                            ),
                          ),
                        ),
                      if (widget.goal == null)
                        SizedBox(
                          width: 8,
                        ),
                      Expanded(
                        child: DatePickerWidget(
                          title: 'Start:',
                          color: selectedColor,
                          endDate: endDate,
                          onSubmit: _pickStartDate,
                          initialDate: startDate,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: DatePickerWidget(
                          title: 'End:',
                          color: selectedColor,
                          onSubmit: _pickEndDate,
                          startDate: startDate,
                          initialDate: endDate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
