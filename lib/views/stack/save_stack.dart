import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/app_appbar.dart';

class SaveStackPage extends StatefulWidget {
  final String goalRef;
  final String goalColor;
  final stack_model.TasksStack stack;
  SaveStackPage({
    Key key,
    @required this.goalRef,
    this.stack,
    @required this.goalColor,
  }) : super(key: key);

  @override
  _SaveStackPageState createState() => _SaveStackPageState();
}

class _SaveStackPageState extends State<SaveStackPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  _submitStack() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await stack_model.TasksStack(
      goalRef: widget.goalRef,
      id: widget.stack?.id,
      title: _titleController.text,
      color: widget.goalColor,
      creationDate: DateTime.now(),
      status: 0,
    ).save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Stack added successfully!',
      message: 'You can now see your stack in stacks list.',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.stack != null) {
      _titleController.text = widget.stack.title;
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
                    // InkWell(
                    //   onTap: () => pickColor(
                    //     (e) => setState(() {
                    //       selectedColor = e;
                    //     }),
                    //   ),
                    //   child: Container(
                    //     padding: const EdgeInsets.all(16.0),
                    //     decoration: BoxDecoration(
                    //       color: Color(0x07000000),
                    //       borderRadius: BorderRadius.circular(8.0),
                    //     ),
                    //     child: Icon(
                    //       Icons.brightness_1,
                    //       color: HexColor.fromHex(selectedColor),
                    //       size: 32,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 8,
                    // ),
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
