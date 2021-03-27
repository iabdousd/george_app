import 'package:flutter/material.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/views/goal/save_goal.dart';
import 'package:george_project/views/stack/stacks_list_view.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:george_project/widgets/shared/app_date_view.dart';
import 'package:get/get.dart';

class GoalDetailsPage extends StatefulWidget {
  final Goal goal;

  GoalDetailsPage({
    Key key,
    @required this.goal,
  }) : super(key: key);

  @override
  _GoalDetailsPageState createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends State<GoalDetailsPage> {
  _editGoal() {
    Get.to(
      () => SaveGoalPage(goal: widget.goal),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Goal',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${widget.goal.title.toUpperCase()}\' ?'),
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
                toggleLoading(state: true);
                await widget.goal.delete();
                toggleLoading(state: false);
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

  int limit = 10;
  int elementsCount = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          elementsCount == limit)
        setState(() {
          limit += 10;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: '',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          controller: _scrollController,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.goal.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppDateView(
                      label: 'From:',
                      date: widget.goal.startDate,
                    ),
                  ),
                  Expanded(
                    child: AppDateView(
                      label: 'To:',
                      date: widget.goal.endDate,
                    ),
                  ),
                  AppActionButton(
                    icon: Icons.edit,
                    onPressed: _editGoal,
                    backgroundColor: Theme.of(context).accentColor,
                    margin: EdgeInsets.only(left: 8, right: 4),
                  ),
                  AppActionButton(
                    icon: Icons.delete,
                    onPressed: _deleteGoal,
                    backgroundColor: Colors.red,
                    margin: EdgeInsets.only(left: 4),
                  ),
                ],
              ),
            ),
            StacksListView(
              goal: widget.goal,
              limit: limit,
              updateCount: (e) => elementsCount = e,
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
