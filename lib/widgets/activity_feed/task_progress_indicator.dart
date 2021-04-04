import 'dart:math';

import 'package:flutter/material.dart';

class TaskProgressIndicator extends StatelessWidget {
  final int total, done;
  const TaskProgressIndicator(
      {Key key, @required this.total, @required this.done})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double itemWidth = 0;
        double margin = min(4, maxWidth / (3 * 30));
        if (total <= 30) {
          // OLD CONDITION: (maxWidth - margin * (total - 1)) / total > maxWidth / 30 - maxWidth / (3 * 30)
          itemWidth = (maxWidth - margin * (total - 1)) / total;
        } else {
          itemWidth = maxWidth / 30 - maxWidth / (3 * 30);
        }

        return Container(
          width: maxWidth,
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < total; i++)
                Container(
                  width: itemWidth,
                  height: 20,
                  margin: i == total - 1
                      ? EdgeInsets.only(bottom: 4)
                      : EdgeInsets.only(right: margin, bottom: 4),
                  decoration: BoxDecoration(
                    color: i < done
                        ? Theme.of(context).primaryColor
                        : Color(0x01000000),
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
