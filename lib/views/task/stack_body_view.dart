import 'package:flutter/material.dart';

import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/views/note/note_list_view.dart';
import 'package:stackedtasks/views/task/task_list_view.dart';

class StackBodyView extends StatefulWidget {
  final stack_model.TasksStack stack;
  const StackBodyView({Key key, @required this.stack}) : super(key: key);

  @override
  _StackBodyViewState createState() => _StackBodyViewState();
}

class _StackBodyViewState extends State<StackBodyView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x13000000),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
              ),
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'TASKS',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'NOTES',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // constraints: BoxConstraints(
            //   maxWidth: MediaQuery.of(context).size.width,
            //   maxHeight: MediaQuery.of(context).size.height,
            // ),
            child: TabBarView(
              controller: _tabController,
              children: [
                TaskListView(
                  stack: widget.stack,
                ),
                NoteListView(
                  stack: widget.stack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
