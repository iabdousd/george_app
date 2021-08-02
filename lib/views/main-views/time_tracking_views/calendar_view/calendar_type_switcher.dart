import 'package:flutter/material.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';

class CaledarTypeSwitcher extends StatelessWidget {
  final String selectedCalendarView;
  final Function(String) changeCalendarView;
  const CaledarTypeSwitcher({
    Key key,
    @required this.selectedCalendarView,
    @required this.changeCalendarView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarTypes = [
      'month',
      'week',
      'day',
    ];

    return Row(
      children: [
        for (final type in calendarTypes)
          CircularActionButton(
            onClick: () => changeCalendarView(type),
            title: type.substring(0, 1).toUpperCase() + type.substring(1),
            backgroundColor: type == selectedCalendarView
                ? Theme.of(context).accentColor
                : Color.fromRGBO(118, 124, 141, 0.12),
            titleStyle: TextStyle(
              fontSize: 14,
              color: type == selectedCalendarView
                  ? Theme.of(context).backgroundColor
                  : Color(0xFF767C8D),
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.only(right: 8),
            width: 82.0,
            height: 32.0,
          ),
      ],
    );
  }
}
