import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Goal.dart';

class LGGoalTile extends StatelessWidget {
  final Goal goal;
  final bool selected;
  final VoidCallback onSelected;
  const LGGoalTile({
    Key key,
    @required this.goal,
    this.selected: false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? HexColor.fromHex(goal.color).darken()
            : Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      margin: EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 12.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).backgroundColor
                        : HexColor.fromHex(goal.color).darken(),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          goal.title.toUpperCase(),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          DateFormat('MMM yyyy').format(goal.startDate) +
                              ' - ' +
                              DateFormat('MMM yyyy').format(goal.endDate),
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .color,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
