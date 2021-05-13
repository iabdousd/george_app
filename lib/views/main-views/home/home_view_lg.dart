import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Stack.dart';

import 'lg_views/goal_list.dart';
import 'lg_views/stack_list.dart';
import 'lg_views/task_list.dart';

class HomeViewLG extends StatefulWidget {
  HomeViewLG({Key key}) : super(key: key);

  @override
  _HomeViewLGState createState() => _HomeViewLGState();
}

class _HomeViewLGState extends State<HomeViewLG> {
  Goal selectedGoal;
  TasksStack selectedStack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 20.0,
                bottom: 12.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Stackedtasks',
                    style: Theme.of(context).textTheme.headline4.copyWith(
                          fontFamily: 'logo',
                          color: Theme.of(context).backgroundColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomeLGGoalList(
                      selectedGoal: selectedGoal,
                      selectGoal: (goal) => selectedGoal?.id == goal.id
                          ? null
                          : setState(
                              () {
                                selectedGoal = goal;
                                selectedStack = null;
                              },
                            ),
                    ),
                  ),
                  Expanded(
                    child: selectedGoal == null
                        ? Center(
                            child: Text('No Goal is selected.'),
                          )
                        : HomeLGStackListView(
                            goal: selectedGoal,
                            selectedStack: selectedStack,
                            onSelectStack: (stack) =>
                                selectedStack?.id == stack.id
                                    ? null
                                    : setState(
                                        () => selectedStack = stack,
                                      ),
                          ),
                  ),
                  Expanded(
                    child: selectedStack == null
                        ? Center(
                            child: Text('No Stack is selected.'),
                          )
                        : HomeLGTaskList(
                            stack: selectedStack,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
