import 'package:flutter/material.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';
import 'package:george_project/widgets/task/tasks_list_by_day.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  CalendarView({Key key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with AutomaticKeepAliveClientMixin {
  CalendarController _calendarController;
  DateTime selectedDay;
  String currentCalendarView = 'month';

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    _calendarController = CalendarController();
  }

  _changeCalendarView(String view) {
    currentCalendarView = view;
    switch (view) {
      case 'week':
        {
          _calendarController.setCalendarFormat(CalendarFormat.week);
          break;
        }
      case 'month':
        {
          _calendarController.setCalendarFormat(CalendarFormat.month);
          break;
        }
      case 'day':
        {
          break;
        }
    }
    setState(() {});
  }

  _switchCalendarView() {
    if (currentCalendarView == 'month')
      _changeCalendarView('week');
    else if (currentCalendarView == 'week')
      _changeCalendarView('day');
    else
      _changeCalendarView('month');
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: currentCalendarView == 'day'
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
            child: Stack(
              children: [
                if (currentCalendarView == 'day')
                  TasksListByDay(
                    day: selectedDay,
                    fullScreen: true,
                  )
                else
                  TableCalendar(
                    calendarController: _calendarController,
                    initialSelectedDay: selectedDay,
                    calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      // formatButtonDecoration: BoxDecoration(
                      //   color: Theme.of(context).primaryColor,
                      //   borderRadius: BorderRadius.circular(8.0),
                      // ),
                      // centerHeaderTitle: true,
                      formatButtonVisible: false,
                      titleTextStyle: Theme.of(context).textTheme.headline6,
                      // formatButtonTextStyle: TextStyle(color: Colors.white),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextBuilder: (date, d) =>
                          DateFormat('E').format(date).substring(0, 1),
                      weekdayStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .color
                                    .withOpacity(.5),
                              ),
                      weekendStyle:
                          Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .color
                                    .withOpacity(.5),
                              ),
                    ),
                    builders: CalendarBuilders(
                      dayBuilder: (context, date, events) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(0.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              date.day.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              DateFormat('EEE').format(date).toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      outsideDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .color
                                  .withOpacity(.5)),
                        ),
                      ),
                      outsideWeekendDayBuilder: (context, date, events) =>
                          Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .color
                                  .withOpacity(.5)),
                        ),
                      ),
                    ),
                    onDaySelected: (day, l1, l2) => setState(() {
                      selectedDay = day;
                    }),
                  ),
                if (currentCalendarView == 'day')
                  Positioned(
                    top: 4,
                    right: 4,
                    child: AppActionButton(
                      onPressed: _switchCalendarView,
                      icon: Icons.calendar_today_outlined,
                      label: currentCalendarView.toUpperCase(),
                      backgroundColor: Theme.of(context).primaryColor,
                      iconSize: 18,
                      textStyle: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                    ),
                  )
                else
                  Positioned(
                    top: 0,
                    right: 50,
                    child: AppActionButton(
                      onPressed: _switchCalendarView,
                      icon: Icons.calendar_today_outlined,
                      label: currentCalendarView.toUpperCase(),
                      backgroundColor: Theme.of(context).primaryColor,
                      iconSize: 18,
                      textStyle: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (currentCalendarView != 'day')
            TasksListByDay(
              day: selectedDay,
              fullScreen: false,
            )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
