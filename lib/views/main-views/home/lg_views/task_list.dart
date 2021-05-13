import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/views/stack/stack_body_view.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class HomeLGTaskList extends StatefulWidget {
  final TasksStack stack;

  HomeLGTaskList({
    Key key,
    this.stack,
  }) : super(key: key);

  @override
  _HomeLGTaskListState createState() => _HomeLGTaskListState();
}

class _HomeLGTaskListState extends State<HomeLGTaskList> {
  _editStack() {
    Get.to(
      () => SaveStackPage(
        stack: widget.stack,
        goalRef: widget.stack.goalRef,
        goalColor: widget.stack.color,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  _deleteStack() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Stack',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${widget.stack.title.toUpperCase()}\' ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await toggleLoading(state: true);
                await widget.stack.delete();
                await toggleLoading(state: false);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: Hero(
                    tag: widget.stack.id,
                    child: Text(
                      widget.stack.title.toUpperCase(),
                      style: Theme.of(context).textTheme.headline5.copyWith(),
                    ),
                  ),
                ),
                AppActionButton(
                  icon: Icons.edit,
                  onPressed: _editStack,
                  backgroundColor: Theme.of(context).accentColor,
                  margin: EdgeInsets.only(left: 8, right: 4),
                ),
                AppActionButton(
                  icon: Icons.delete,
                  onPressed: _deleteStack,
                  backgroundColor: Colors.red,
                  margin: EdgeInsets.only(left: 4),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
        Expanded(
          child: StackBodyView(
            stack: widget.stack,
          ),
        ),
      ],
    );
  }
}
