import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/shared/color.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/forms/date_picker.dart';

import 'goal_partners.dart';

class SaveGoalPage extends StatefulWidget {
  final Goal goal;
  SaveGoalPage({Key key, this.goal}) : super(key: key);

  @override
  _SaveGoalPageState createState() => _SaveGoalPageState();
}

class _SaveGoalPageState extends State<SaveGoalPage> {
  Goal goal;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));

  String selectedColor =
      availableColors[Random().nextInt(availableColors.length - 1)];

  _submitGoal() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    goal = Goal(
      id: goal?.id,
      userID: getCurrentUser().uid,
      partnersIDs: goal?.partnersIDs ?? [],
      title: _titleController.text,
      color: selectedColor,
      creationDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      status: 0,
    );
    await goal.save();
    toggleLoading(state: false);
    Navigator.of(context).pop(goal);
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
    goal = widget.goal;
    if (goal != null) {
      _titleController.text = goal.title;
      startDate = goal.startDate;
      endDate = goal.endDate;
      selectedColor = goal.color;
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                color: Color(0xFFB2B6C3),
                width: 28,
                height: 3,
                margin: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFFB2B6C3),
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    goal?.id == null ? 'New Project' : 'Project Details',
                    style: TextStyle(
                      color: Color(0xFF767C8D),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _submitGoal,
                  child: Text(
                    'DONE',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Goal title',
                hintText: 'The title of the goal',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                alignLabelWithHint: false,
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(width: 1),
                ),
              ),
              validator: (t) =>
                  t.isEmpty ? 'Please enter the goal\'s title' : null,
            ),
            if (goal?.id != null)
              GoalPartners(
                goal: goal,
                deletePartner: (UserModel partner) =>
                    goal.partnersIDs.removeWhere(
                  (element) => element == partner.uid,
                ),
              ),
            Container(
              margin: EdgeInsets.only(
                bottom: 8.0,
                top: goal?.id != null ? 0.0 : 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DatePickerWidget(
                      title: 'Start Date:',
                      color: selectedColor,
                      endDate: endDate,
                      onSubmit: _pickStartDate,
                      selectedDate: startDate,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DatePickerWidget(
                      title: 'End Date:',
                      color: selectedColor,
                      onSubmit: _pickEndDate,
                      startDate: startDate,
                      selectedDate: endDate,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () => pickColor(
                (e) => setState(() {
                  selectedColor = e;
                }),
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Choose color',
                        style: TextStyle(
                          color: Color(0xFFB2B5C3),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.brightness_1,
                      color: HexColor.fromHex(selectedColor),
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
