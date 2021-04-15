import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackedtasks/views/goal/save_goal.dart';
import 'package:stackedtasks/widgets/home/app_bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'activity_feed_view.dart';
import 'calendar_view.dart';
import 'home_view.dart';
import 'timer_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final pageIndexStreamController = StreamController<int>.broadcast();
  final List<GlobalKey> _bottomBarKeys =
      List.generate(4, (index) => GlobalKey());
  TabController _tabController;

  void _init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool hasEnteredBefore = preferences.getBool('hasEnteredBefore') ?? false;
    if (!hasEnteredBefore) {
      showTutorial();
      await preferences.setBool('hasEnteredBefore', true);
    }
  }

  showTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: 0,
        keyTarget: _bottomBarKeys[0],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "The Homepage",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      """It is where you plan your goals. Set an overall date by when you want to achieve your goal and break it down into manageable parts called stacks.
Each stack contains a list of tasks and notes to help you along the way.
To make sure that you prioritize effectively, you can map your tasks to blocks of time on your calendar. These can be one time, recurring or just assigned to a day without specifying the time.
A pro tip is to add maintaining your task management system itself as one of your goals to clear backlog and keep everything current""",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 2,
        keyTarget: _bottomBarKeys[2],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Execution",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Once you have your tasks lined up for the day, the timer page helps you stay on track. It notifies you about what is currently scheduled and what is coming up. For each activity, you could also provide some feedback which gets added to your notes",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 3,
        keyTarget: _bottomBarKeys[3],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Review",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Finally, once things are moving, you get a summarised view of your productivity by day, a feed of your activity by task and a more high level progress summary for each of your goals.\nYou can celebrate your wins by sharing with your friends and identify patterns where you tend to be less effective and surgically fix it.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Theme.of(context).primaryColor,
      alignSkip: Alignment.topRight,
      textSkip: "Skip",
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        if (target.identify == 0)
          _changePage(2);
        else if (target.identify == 2)
          _changePage(3);
        else
          _changePage(0);
      },
      onSkip: () {
        print("skip");
      },
    ).show();
  }

  @override
  void initState() {
    _init();
    pageIndexStreamController.add(0);
    _tabController = _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  void _changePage(int index) {
    pageIndexStreamController.add(index);
    _tabController.animateTo(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageIndexStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            HomeView(),
            CalendarView(),
            TimerView(),
            ActivityFeedView(),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<int>(
          stream: pageIndexStreamController.stream,
          builder: (context, snapshot) {
            int index = snapshot.data ?? 0;
            if (index == 0)
              return FloatingActionButton(
                onPressed: () => Get.to(() => SaveGoalPage()),
                child: Icon(
                  Icons.add,
                  size: 32.0,
                  color: Theme.of(context).backgroundColor,
                ),
                backgroundColor: Theme.of(context).primaryColor,
              );
            return Container();
          }),
      bottomNavigationBar: StreamBuilder<int>(
        stream: pageIndexStreamController.stream,
        builder: (context, snapshot) {
          int index = 0;
          if (snapshot.hasData) index = snapshot.data;

          return AppBottomNavigationBar(
            index: index,
            keys: _bottomBarKeys,
            changePage: _changePage,
          );
        },
      ),
    );
  }
}
