import 'dart:math';

import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Stack.dart' as stack_model;
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/shared/color.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';

class SaveStackPage extends StatefulWidget {
  final String goalRef;
  final stack_model.Stack stack;
  SaveStackPage({Key key, @required this.goalRef, this.stack})
      : super(key: key);

  @override
  _SaveStackPageState createState() => _SaveStackPageState();
}

class _SaveStackPageState extends State<SaveStackPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  String selectedColor =
      availableColors[Random().nextInt(availableColors.length - 1)];

  _submitStack() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await stack_model.Stack(
      goalRef: widget.goalRef,
      id: widget.stack?.id,
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
      title: 'Stack added successfully!',
      message: 'You can now see your stack in stacks list.',
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
    if (widget.stack != null) {
      _titleController.text = widget.stack.title;
      startDate = widget.stack.startDate;
      endDate = widget.stack.endDate;
      selectedColor = widget.stack.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.stack != null ? 'Stack details' : 'New Stack',
        actions: [
          TextButton(
            onPressed: _submitStack,
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
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => pickColor(
                        (e) => setState(() {
                          selectedColor = e;
                        }),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
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
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Stack title',
                            hintText: 'The title of the stack',
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
                          validator: (t) => t.isEmpty
                              ? 'Please enter the stack\'s title'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
