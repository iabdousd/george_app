import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _dayViewTanController;
  CalendarController _calendarController;
  DateTime selectedDay;
  String currentCalendarView = 'month';
  List<Widget> tabChildren;
  int daysInMonth;

  initDaysInMonth(DateTime date) {
    daysInMonth = DateUtil().daysInMonth(date.month, date.year);
  }

  @override
  void initState() {
    super.initState();

    selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    initDaysInMonth(selectedDay);

    _dayViewTanController = TabController(
      vsync: this,
      length: daysInMonth,
      initialIndex: selectedDay.day - 1,
    );

    tabChildren = List<Widget>.generate(
      daysInMonth,
      (index) => TasksListByDay(
        day: DateTime(
          selectedDay.year,
          selectedDay.month,
          index + 1,
        ),
        fullScreen: true,
      ),
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
          _dayViewTanController = TabController(
            vsync: this,
            length: daysInMonth,
            initialIndex: selectedDay.day - 1,
          );

          tabChildren = List<Widget>.generate(
            daysInMonth,
            (index) => TasksListByDay(
              day: DateTime(
                selectedDay.year,
                selectedDay.month,
                index + 1,
              ),
              fullScreen: true,
            ),
          );
          _dayViewTanController.addListener(() {
            selectedDay = DateTime(
              selectedDay.year,
              selectedDay.month,
              _dayViewTanController.index + 1,
            );
          });
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
      physics:
          currentCalendarView == 'day' ? NeverScrollableScrollPhysics() : null,
      child: Column(
        children: [
          Container(
            padding:
                //  currentCalendarView == 'day'
                //     ? EdgeInsets.zero
                //     :
                EdgeInsets.symmetric(
              horizontal: currentCalendarView == 'day' ? 0 : 16.0,
              vertical: 24.0,
            ),
            child: Stack(
              children: [
                if (currentCalendarView == 'day')
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 116,
                    margin: EdgeInsets.only(bottom: 116),
                    child: TabBarView(
                      controller: _dayViewTanController,
                      children: tabChildren,
                    ),
                  )
                else if (currentCalendarView == 'week')
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 116,
                    margin: EdgeInsets.only(bottom: 116),
                    child: TasksListByWeek(
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
                    top: 0,
                    right: 64,
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
          if (currentCalendarView == 'month')
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
