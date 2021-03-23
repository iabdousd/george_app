import 'package:flutter/material.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/views/stack/save_stack.dart';
import 'package:george_project/views/task/stack_body_view.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:george_project/widgets/shared/app_date_view.dart';
import 'package:get/get.dart';
import 'package:george_project/models/Stack.dart' as stack_model;

class StackDetailsPage extends StatefulWidget {
  final stack_model.Stack stack;

  StackDetailsPage({
    Key key,
    @required this.stack,
  }) : super(key: key);

  @override
  _StackDetailsPageState createState() => _StackDetailsPageState();
}

class _StackDetailsPageState extends State<StackDetailsPage> {
  _editStack() {
    Get.to(
      () => SaveStackPage(
        stack: widget.stack,
        goalRef: widget.stack.goalRef,
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
    return Scaffold(
      appBar: appAppBar(
        title: '',
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  child: Text(
                    widget.stack.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppDateView(
                          label: 'From:',
                          date: widget.stack.startDate,
                          format: 'dd MMM yyyy',
                        ),
                      ),
                      Expanded(
                        child: AppDateView(
                          label: 'To:',
                          date: widget.stack.endDate,
                          format: 'dd MMM yyyy',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppActionButton(
                          icon: Icons.edit,
                          label: 'EDIT',
                          onPressed: _editStack,
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      ),
                      Expanded(
                        child: AppActionButton(
                          icon: Icons.delete,
                          label: 'DELETE',
                          onPressed: _deleteStack,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: StackBodyView(
                stack: widget.stack,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
