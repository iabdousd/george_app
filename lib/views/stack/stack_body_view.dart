import 'package:flutter/material.dart';

import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/views/task/task_list_view.dart';

class StackBodyView extends StatefulWidget {
  final stack_model.TasksStack stack;
  const StackBodyView({Key key, @required this.stack}) : super(key: key);

  @override
  _StackBodyViewState createState() => _StackBodyViewState();
}

class _StackBodyViewState extends State<StackBodyView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TaskListView(
      stack: widget.stack,
    );
  }
}
