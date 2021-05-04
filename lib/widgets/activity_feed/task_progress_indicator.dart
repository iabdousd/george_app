import 'dart:math';

import 'package:flutter/material.dart';

class TaskProgressIndicator extends StatelessWidget {
  final List<DateTime> dueDates;
  final List<DateTime> donesHistory;
  const TaskProgressIndicator(
      {Key key, @required this.dueDates, @required this.donesHistory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int currentDone = 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double itemWidth = 0;
        double margin = min(4, maxWidth / (3 * 30));
        if (dueDates.length <= 30) {
          // OLD CONDITION: (maxWidth - margin * (total - 1)) / total > maxWidth / 30 - maxWidth / (3 * 30)
          itemWidth =
              (maxWidth - margin * (dueDates.length - 1)) / dueDates.length;
        } else {
          itemWidth = maxWidth / 30 - maxWidth / (3 * 30);
        }
        final items = <Widget>[];
        for (int i = 0; i < dueDates.length; i++) {
          items.add(Container(
            width: itemWidth,
            height: 20,
            margin: i == dueDates.length - 1
                ? EdgeInsets.only(bottom: 4)
                : EdgeInsets.only(right: margin, bottom: 4),
            decoration: BoxDecoration(
              color: currentDone < donesHistory.length &&
                      dueDates[i] == donesHistory[currentDone]
                  ? Theme.of(context).primaryColor
                  : Color(0x01000000),
              borderRadius: BorderRadius.circular(2.0),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
          ));
          if (currentDone < donesHistory.length &&
              dueDates[i] == donesHistory[currentDone]) currentDone++;
        }

        return Container(
          width: maxWidth,
          child: Wrap(
            alignment: WrapAlignment.start,
            children: items,
          ),
        );
      },
    );
  }
}
