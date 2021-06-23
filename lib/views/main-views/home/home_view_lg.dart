import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/views/main-views/inbox-views/inbox_main_view.dart';

import 'lg_views/goal_list.dart';
import 'lg_views/stack_list.dart';
import 'lg_views/task_list.dart';

class HomeViewLG extends StatefulWidget {
  final StreamController<int> pageIndexStreamController;
  HomeViewLG({Key key, this.pageIndexStreamController}) : super(key: key);

  @override
  _HomeViewLGState createState() => _HomeViewLGState();
}

class _HomeViewLGState extends State<HomeViewLG> {
  Goal selectedGoal;
  TasksStack selectedStack;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(
              'Stackedtasks',
              style: Theme.of(context).textTheme.headline4.copyWith(
                    fontFamily: 'logo',
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 54),
            child: Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 0.0,
              ),
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Inbox',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Goals',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    InboxMainView(
                      pageIndexStreamController:
                          widget.pageIndexStreamController,
                    ),
                    Row(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
