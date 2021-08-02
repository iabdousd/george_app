import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/goal_summary.dart';
import 'package:stackedtasks/services/shared/sharing/sharing_task.dart';

import 'shared/task_feed_header.dart';

class GoalSummaryWidget extends StatelessWidget {
  final GoalSummary goal;
  final String name, profilePicture;
  const GoalSummaryWidget({
    Key key,
    @required this.goal,
    @required this.name,
    @required this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenshotKey = GlobalKey();
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              0,
              0,
              0,
              .12,
            ),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: RepaintBoundary(
          key: screenshotKey,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              border: Border(
                left: BorderSide(
                  width: 8,
                  color: HexColor.fromHex(goal.color),
                ),
                bottom: BorderSide(width: 0),
                right: BorderSide(width: 0),
                top: BorderSide(width: 0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TaskFeedHeader(
                        userID: goal.userID,
                        name: name,
                        profilePicture: profilePicture,
                        creationDate: goal.creationDate,
                      ),
                    ),
                    InkWell(
                      onTap: () => shareGoal(goal, screenshotKey),
                      child: Container(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/share.svg',
                              width: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          color: Color(0xFF3B404A),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 8,
                        ),
                        child: Text(
                          'Time allocated: ${goal.allocatedTime.inHours.toStringAsFixed(0)} hours ${(goal.allocatedTime.inMinutes % 60).toStringAsFixed(0)} minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF767C8D),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  height: 20,
                                  width: constraints.maxWidth,
                                  color: Color.fromRGBO(
                                    178,
                                    181,
                                    195,
                                    0.1,
                                  ),
                                ),
                                Container(
                                  width: goal.completionPercentage *
                                      constraints.maxWidth,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).accentColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '${(goal.completionPercentage * 100).toStringAsFixed(0)}% completion',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: goal.completionPercentage >= .5
                                          ? Theme.of(
                                              context,
                                            ).backgroundColor
                                          : Color(
                                              0xFFB2B5C3,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (goal.stacksSummaries != null &&
                          goal.stacksSummaries.length > 0)
                        Container(
                          padding: EdgeInsets.only(top: 8),
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.top,
                            children: goal.stacksSummaries.map(
                              (stack) {
                                return TableRow(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            stack.title,
                                            style: TextStyle(
                                              color: Color(0xFF3B404A),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5.0,
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              '${stack.allocatedTime.inHours.toStringAsFixed(0)} hours ${(stack.allocatedTime.inMinutes % 60).toStringAsFixed(0)} minutes  |  ${stack.tasksTotal} tasks',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF767C8D),
                                              ),
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          constraints.maxWidth,
                                                      color: Color.fromRGBO(
                                                        178,
                                                        181,
                                                        195,
                                                        0.1,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: stack
                                                              .completionPercentage *
                                                          constraints.maxWidth,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor,
                                                            Theme.of(context)
                                                                .accentColor,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        '${(stack.completionPercentage * 100).toStringAsFixed(0)}% completion',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: stack.completionPercentage >=
                                                                  .5
                                                              ? Theme.of(
                                                                  context,
                                                                ).backgroundColor
                                                              : Color(
                                                                  0xFFB2B5C3,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            ).toList(),
                          ),
                        )
                      else
                        SizedBox(
                          height: 20,
                        ),
                    ],
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
