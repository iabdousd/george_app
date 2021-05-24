import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:stackedtasks/views/goal/save_goal.dart';
import 'package:stackedtasks/widgets/home/app_bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../stack/save_stack.dart';
import '../task/save_task.dart';
import 'activity_feed_view.dart';
import 'home_view.dart';
import 'notification-views/notifications-view.dart';
import 'time_tracking_views.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showTutorial();
        await preferences.setBool('hasEnteredBefore', true);
      });
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
    return WillPopScope(
      onWillPop: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Are you sure you want to quit the application?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Quit'),
                  ),
                ],
              )),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              HomeView(
                pageIndexStreamController: pageIndexStreamController,
              ),
              TimeTrackingViews(),
              NotificationsView(),
              ActivityFeedView(),
            ],
          ),
        ),
        floatingActionButton: StreamBuilder<int>(
          stream: pageIndexStreamController.stream,
          builder: (context, snapshot) {
            int index = snapshot.data ?? 0;
            if (index == 0)
              return FadeInUp(
                duration: Duration(milliseconds: 300),
                child: SpeedDial(
                  marginEnd: 18,
                  marginBottom: 20,
                  icon: Icons.add,
                  activeIcon: Icons.close,
                  buttonSize: 64.0,
                  visible: true,
                  closeManually: false,
                  renderOverlay: false,
                  curve: Curves.bounceIn,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.5,
                  tooltip: 'Create',
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).backgroundColor,
                  elevation: 8.0,
                  shape: CircleBorder(),
                  children: [
                    SpeedDialChild(
                      child: Center(
                        child: Image.asset(
                          'assets/images/icons/goal.png',
                          width: 32.0,
                          fit: BoxFit.cover,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      label: 'Create Goal',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () => Get.to(() => SaveGoalPage()),
                    ),
                    SpeedDialChild(
                      child: Center(
                        child: Image.asset(
                          'assets/images/icons/tasks_stack.png',
                          width: 32.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      label: 'Create Inbox Stack',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () => Get.to(
                        () => SaveStackPage(
                          goalRef: 'inbox',
                          goalColor: Theme.of(context)
                              .primaryColor
                              .value
                              .toRadixString(16),
                        ),
                      ),
                    ),
                    SpeedDialChild(
                      child: Center(
                        child: Image.asset(
                          'assets/images/icons/task.png',
                          width: 32.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      label: 'Create Inbox Task',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () => Get.to(
                        () => SaveTaskPage(
                          goalRef: 'inbox',
                          stackRef: 'inbox',
                          goalTitle: 'Inbox',
                          stackTitle: '',
                          stackColor: Theme.of(context)
                              .primaryColor
                              .value
                              .toRadixString(16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            return SizedBox();
          },
        ),
        bottomNavigationBar: StreamBuilder<int>(
          stream: pageIndexStreamController.stream,
          builder: (context, snapshot) {
            int index = 0;
            /**
             * -1 is used to show the bottom menu when selecting inbox tasks.
             */
            if (snapshot.hasData)
              index = snapshot.data == -1 ? 0 : snapshot.data;

            return AppBottomNavigationBar(
              index: index,
              keys: _bottomBarKeys,
              changePage: _changePage,
            );
          },
        ),
      ),
    );
  }
}
