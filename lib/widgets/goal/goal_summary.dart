import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plandoraslist/config/extensions/hex_color.dart';
import 'package:plandoraslist/models/goal_summary.dart';
import 'package:plandoraslist/providers/cache/cached_image_provider.dart';
import 'package:plandoraslist/services/shared/sharing/sharing_task.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

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
    final screenshotController = ScreenshotController();
    return Screenshot(
      controller: screenshotController,
      child: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(42.0),
                          child: profilePicture != null
                              ? Image(
                                  image: CachedImageProvider(profilePicture),
                                  fit: BoxFit.cover,
                                  width: 42,
                                  height: 42,
                                )
                              : SvgPicture.asset(
                                  'assets/images/profile.svg',
                                  fit: BoxFit.cover,
                                  width: 42,
                                  height: 42,
                                ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              DateFormat('EEE, dd MMM')
                                  .format(goal.creationDate),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => shareGoal(goal, screenshotController),
                    child: Container(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: Colors.black38,
                          ),
                          Text(
                            ' Share',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF535353),
                        ),
                  ),
                  Text(
                    'Time allocated: ${goal.allocatedTime.inHours.toStringAsFixed(0)} hours ${(goal.allocatedTime.inMinutes % 60).toStringAsFixed(0)} minutes',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF868686),
                        ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 14.0, bottom: 0.0),
                    child: Text(
                      '${(goal.completionPercentage * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headline4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                            height: 1,
                          ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: LinearProgressIndicator(
                      value: goal.completionPercentage,
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        HexColor.fromHex(goal.color),
                      ),
                      backgroundColor: Color(0xFFE3E3E3),
                    ),
                  ),
                  if (goal.stacksSummaries != null &&
                      goal.stacksSummaries.length > 0)
                    Container(
                      padding: EdgeInsets.only(top: 16, bottom: 20),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: Color(0xFF535353),
                                            ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${stack.allocatedTime.inHours.toStringAsFixed(0)} hours ${(stack.allocatedTime.inMinutes % 60).toStringAsFixed(0)} minutes  |  ${stack.tasksTotal} tasks',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF757575),
                                                ),
                                          ),
                                          Text(
                                            '${(stack.completionPercentage * 100).toStringAsFixed(0)}%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 4.0, bottom: 0.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          child: LinearProgressIndicator(
                                            value: stack.completionPercentage,
                                            minHeight: 6,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              HexColor.fromHex(goal.color),
                                            ),
                                            backgroundColor: Color(0xFFE3E3E3),
                                          ),
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
    );
  }
}
