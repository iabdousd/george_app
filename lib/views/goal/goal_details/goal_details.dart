import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/views/stack/stacks_list_view.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

import 'goal_details_header.dart';

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
  bool isEmpty = false;
  Goal goal;

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        context: context,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_ios),
          color: Theme.of(context).backgroundColor,
        ),
        customTitle: Text(goal.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoalDetailsHeader(
                goal: goal,
                updateGoal: (newGoal) => setState(
                  () => goal = newGoal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 8.0,
                ),
                child: Text(
                  'Project Stacks',
                  style: TextStyle(
                    color: Color(0xFFB2B5C3),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              StacksListView(
                goal: goal,
                updateIsEmpty: (_) => setState(
                  () => isEmpty = _,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                right: 16.0,
              ),
              child: SvgPicture.asset(
                'assets/images/curved_arrow.svg',
              ),
            ),
          FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              builder: (context) => SaveStackPage(
                goalRef: goal.id,
                goalColor: goal.color,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
