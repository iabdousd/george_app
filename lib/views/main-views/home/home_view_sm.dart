import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/views/goal/goals_list.dart';
import 'package:stackedtasks/views/main-views/inbox-views/inbox_main_view.dart';

import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

class HomeViewSM extends StatefulWidget {
  final StreamController<int> pageIndexStreamController;

  const HomeViewSM({Key key, this.pageIndexStreamController}) : super(key: key);

  @override
  _HomeViewSMState createState() => _HomeViewSMState();
}

class _HomeViewSMState extends State<HomeViewSM>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tabLabelStyle = (int index) => TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _tabController.index == index
              ? Theme.of(context).backgroundColor
              : Theme.of(context).backgroundColor.withOpacity(.5),
        );

    return Scaffold(
      appBar: AppAppBar(
        context: context,
        preferredSize: Size.fromHeight(104),
        bottom: Container(
          child: TabBar(
            indicatorColor: Theme.of(context).backgroundColor,
            indicatorWeight: 2,
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/tasks.svg',
                      width: 20,
                      height: 20,
                      color: _tabController.index == 0
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).backgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'TASKS',
                        style: tabLabelStyle(0),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/stacks.svg',
                      width: 20,
                      height: 20,
                      color: _tabController.index == 1
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).backgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'STACKS',
                        style: tabLabelStyle(1),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/projects.svg',
                      width: 22,
                      height: 22,
                      color: _tabController.index == 2
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).backgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'PROJECTS',
                        style: tabLabelStyle(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InboxMainView(
                  pageIndexStreamController: widget.pageIndexStreamController,
                  type: 'task',
                ),
                InboxMainView(
                  pageIndexStreamController: widget.pageIndexStreamController,
                  type: 'stack',
                ),
                GoalsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
