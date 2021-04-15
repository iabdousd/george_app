import 'package:flutter/material.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/views/task/stack_body_view.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_appbar.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/Stack.dart' as stack_model;

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
                InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 4.0),
                    child: Hero(
                      tag: widget.stack.goalRef,
                      child: Text(
                        widget.stack.goalTitle.toUpperCase() + ' >',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Hero(
                        tag: widget.stack.id,
                        child: Text(
                          widget.stack.title.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.headline5.copyWith(),
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
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
