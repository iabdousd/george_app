import 'dart:async';

import 'package:flutter/material.dart';
import 'package:george_project/views/goal/save_goal.dart';
import 'package:george_project/widgets/home/app_bottom_navigation_bar.dart';
import 'package:get/get.dart';

import 'main-views/calendar_view.dart';
import 'main-views/home_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final pageIndexStreamController = StreamController<int>.broadcast();
  TabController _tabController;

  @override
  void initState() {
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
            Container(),
            Container(),
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
            changePage: _changePage,
          );
        },
      ),
    );
  }
}
