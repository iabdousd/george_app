import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/goal/goal_details/goal_details.dart';
import 'package:stackedtasks/views/goal/save_goal/save_goal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';

class GoalListTileWidget extends StatelessWidget {
  final Goal goal;

  const GoalListTileWidget({Key key, @required this.goal}) : super(key: key);

  _deleteGoal(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Goal',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${goal.title.toUpperCase()}\' ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                toggleLoading(state: true);
                await goal.delete();
                toggleLoading(state: false);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  _editGoal(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SaveGoalPage(goal: goal),
    );
  }

  void _openGoalDetailsPage() => Get.to(
        () => GoalDetailsPage(
          goal: goal,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 16.0),
      child: GestureDetector(
        onTap: _openGoalDetailsPage,
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 8.0,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: HexColor.fromHex(goal.color),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                      ),
                    ),
                    // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal.title,
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18.0,
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              DateFormat('MMM yyyy').format(goal.startDate) +
                                  ' - ' +
                                  DateFormat('MMM yyyy').format(goal.endDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => SaveStackPage(
                        goalRef: goal.id,
                        goalColor: goal.color,
                        goalPartnerIDs: goal.partnersIDs,
                      ),
                    ).then((value) =>
                        value != null && value ? _openGoalDetailsPage() : null),
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: SvgPicture.asset(
                        'assets/images/icons/add.svg',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SvgPicture.asset(
                      'assets/images/icons/drag_indicator.svg',
                    ),
                  ),
                ],
              ),
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              onTap: () => _editGoal(context),
              iconWidget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth - 24,
                  height: constraints.maxWidth - 24,
                  margin: EdgeInsets.only(
                    left: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6.0,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).backgroundColor,
                    size: 32.0,
                  ),
                );
              }),
              closeOnTap: true,
            ),
            IconSlideAction(
              iconWidget: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth - 24,
                    height: constraints.maxWidth - 24,
                    margin: EdgeInsets.only(
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 6.0,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).backgroundColor,
                      size: 32.0,
                    ),
                  );
                },
              ),
              closeOnTap: true,
              onTap: () => _deleteGoal(context),
            ),
          ],
        ),
      ),
    );
  }
}
