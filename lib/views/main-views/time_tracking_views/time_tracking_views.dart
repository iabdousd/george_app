import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/views/main-views/time_tracking_views/calendar_view/calendar_view.dart';
import 'package:stackedtasks/views/main-views/time_tracking_views/timer_view.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

class TimeTrackingViews extends StatefulWidget {
  TimeTrackingViews({Key key}) : super(key: key);

  @override
  _TimeTrackingViewsState createState() => _TimeTrackingViewsState();
}

class _TimeTrackingViewsState extends State<TimeTrackingViews>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final tabLabelStyle = (int index) => TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: _tabController.index == index
              ? Theme.of(context).backgroundColor
              : Theme.of(context).backgroundColor.withOpacity(.5),
        );

    super.build(context);
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
                      'assets/images/icons/time.svg',
                      width: 22,
                      height: 22,
                      color: _tabController.index == 0
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).backgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'TIME TRACK',
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
                      'assets/images/icons/calendar2.svg',
                      width: 22,
                      height: 22,
                      color: _tabController.index == 1
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).backgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'CALENDAR',
                        style: tabLabelStyle(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            TimerView(),
            CalendarView(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
