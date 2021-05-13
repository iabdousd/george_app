import 'package:flutter/material.dart';
import 'package:stackedtasks/views/main-views/calendar_view.dart';
import 'package:stackedtasks/views/main-views/timer_view.dart';

class TimeTrackingViews extends StatefulWidget {
  TimeTrackingViews({Key key}) : super(key: key);

  @override
  _TimeTrackingViewsState createState() => _TimeTrackingViewsState();
}

class _TimeTrackingViewsState extends State<TimeTrackingViews>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 80),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Container(
              color: Color.fromRGBO(
                231,
                242,
                254,
                1,
              ),
              child: TabBar(
                labelColor: Theme.of(context).backgroundColor,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                unselectedLabelColor:
                    Theme.of(context).textTheme.headline6.color,
                tabs: [
                  Tab(
                    text: 'TIME TRACKER',
                  ),
                  Tab(
                    text: 'CALENDAR',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              TimerView(),
              CalendarView(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
