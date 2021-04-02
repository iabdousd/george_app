import 'package:flutter/material.dart';

class TaskProgressIndicator extends StatelessWidget {
  final int total, done;
  const TaskProgressIndicator(
      {Key key, @required this.total, @required this.done})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double itemWidth = (maxWidth - 4 * (total - 1)) / total;

      return Container(
        width: maxWidth,
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < total; i++)
              Container(
                width: itemWidth,
                margin: i == total - 1
                    ? EdgeInsets.zero
                    : EdgeInsets.only(right: 4),
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
    });
  }
}
