import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';
import 'package:stackedtasks/widgets/task/tasks_list_by_day.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/widgets/task/tasks_list_by_week.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  CalendarView({Key key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with AutomaticKeepAliveClientMixin {
  StreamController<DateTime> viewPointDate =
      StreamController<DateTime>.broadcast();
  PageController _dayViewPageController;
  DateTime selectedDay;
  String currentCalendarView = 'week';

  @override
  void initState() {
    super.initState();

    selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    viewPointDate.add(selectedDay);
    _dayViewPageController = PageController(
      initialPage: selectedDay.day - 1,
    );
  }

  _changeCalendarView(String view) {
    if (view == 'day') {
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   changeDayViewPage(selectedDay.day - 1.0);
      // });
      _dayViewPageController = PageController(
        initialPage: selectedDay.day - 1,
      );
    }
    setState(() {
      currentCalendarView = view;
    });
  }

  @override
  void dispose() {
    super.dispose();
    viewPointDate.close();
  }

  void changeDayViewPage(double newPage) {
    _dayViewPageController.animateTo(
      newPage,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: CaledarTypeSwitcher(
          //     selectedCalendarView: currentCalendarView,
          //     changeCalendarView: _changeCalendarView,
          //   ),
          // ),
          if (currentCalendarView == 'day')
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 9.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => setState(
                            () => selectedDay = selectedDay.subtract(
                              Duration(days: 1),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Color(0xFFB2B6C3),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              DateFormat('d MMMM').format(selectedDay),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3B404A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(
                            () => selectedDay = selectedDay.add(
                              Duration(days: 1),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Color(0xFFB2B6C3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TasksDayView(
                      day: selectedDay,
                      fullScreen: true,
                      updateDay: (day) => setState(
                        () => selectedDay = DateTime(
                          day.year,
                          day.month,
                          day.day,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  TableCalendar(
                    focusedDay: selectedDay,
                    firstDay: DateTime.now().subtract(
                      Duration(days: 5 * 365),
                    ),
                    lastDay: DateTime.now().add(
                      Duration(days: 5 * 365),
                    ),
                    selectedDayPredicate: (_) =>
                        _.year == selectedDay.year &&
                        _.month == selectedDay.month &&
                        _.day == selectedDay.day,
                    calendarFormat: currentCalendarView == 'month'
                        ? CalendarFormat.month
                        : CalendarFormat.week,
                    calendarStyle: CalendarStyle(
                      canMarkersOverflow: true,
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleTextFormatter: (date, locale) {
                        viewPointDate.add(date);
                        return '';
                      },
                      titleTextStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).accentColor,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Color(0xFFB2B6C3),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Color(0xFFB2B6C3),
                      ),
                      leftChevronPadding: EdgeInsets.symmetric(vertical: 12),
                      rightChevronPadding: EdgeInsets.symmetric(vertical: 12),
                      titleCentered: true,
                      headerPadding: EdgeInsets.all(8),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextFormatter: (date, d) =>
                          DateFormat('E').format(date).substring(0, 1),
                      weekdayStyle: TextStyle(
                        color: Color(0xFF767C8D),
                        fontSize: 12,
                      ),
                      weekendStyle: TextStyle(
                        color: Color(0xFF767C8D),
                        fontSize: 12,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, events) => Container(
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B404A),
                          ),
                        ),
                      ),
                      selectedBuilder: (context, date, events) => Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                        ),
                      ),
                      todayBuilder: (context, date, events) => Container(
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      outsideBuilder: (context, date, events) => Container(
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Color(0xFFB2B5C3),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      disabledBuilder: (context, date, events) => Container(
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Color(0xFFB2B5C3),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    onDaySelected: (day, end) => setState(
                      () {
                        selectedDay = day;
                      },
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: StreamBuilder<DateTime>(
                        initialData: selectedDay,
                        stream: viewPointDate.stream,
                        builder: (context, snapshot) {
                          final date = snapshot.data;

                          return CircularActionButton(
                            onClick: () => currentCalendarView == 'month'
                                ? _changeCalendarView('week')
                                : _changeCalendarView('month'),
                            title: DateFormat('MMMM yyyy').format(date),
                            backgroundColor: currentCalendarView == 'month'
                                ? Theme.of(context).accentColor
                                : Color.fromRGBO(118, 124, 141, 0.12),
                            titleStyle: TextStyle(
                              fontSize: 14,
                              color: currentCalendarView != 'month'
                                  ? Color(0xFF767C8D)
                                  : Theme.of(context).backgroundColor,
                            ),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.only(right: 8),
                            width: 132,
                            height: 32.0,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (currentCalendarView == 'week')
            Expanded(
              child: TasksDayView(
                day: selectedDay,
                fullScreen: true,
                updateDay: (day) => setState(
                  () => selectedDay = DateTime(
                    day.year,
                    day.month,
                    day.day,
                  ),
                ),
              ),
            )
          else if (currentCalendarView == 'month')
            Expanded(
              child: TasksListByDay(
                day: selectedDay,
              ),
            )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
