import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/repositories/feed/statistics.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/constants/feed.dart' as feed_constants;
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class WeekProgress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WeekProgressState();
}

class WeekProgressState extends State<WeekProgress> {
  final now = DateTime.now();
  int selectedWeek = 11;
  int maxTasks = 1;
  List<DateTime> weeks = [];
  List<double> weeksValues = [];

  @override
  void initState() {
    super.initState();
    DateTime start = now.subtract(Duration(days: now.weekday - 1));
    weeks.add(DateTime(
      start.year,
      start.month,
      start.day,
    ));
    weeksValues.add(0);
    for (var i = 1; i < 12; i++) {
      weeks.insert(
        0,
        DateTime(
          start.subtract(Duration(days: 7 * i)).year,
          start.subtract(Duration(days: 7 * i)).month,
          start.subtract(Duration(days: 7 * i)).day,
        ),
      );
      weeksValues.add(0);
    }
  }

  final weeklyAccsStream = getWeeklyAccomlishements();

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Theme.of(context).accentColor,
      Theme.of(context).accentColor,
    ];

    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: weeklyAccsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return AppErrorWidget();
        }
        if (snapshot.hasData) {
          for (var item in snapshot.data.docs) {
            if (weeks.contains(item
                .data()[feed_constants.WEEK_START_DATE_KEY]
                .toDate()
                .toLocal())) {
              int cIndex = weeks.indexOf(item
                  .data()[feed_constants.WEEK_START_DATE_KEY]
                  .toDate()
                  .toLocal());
              weeksValues[cIndex] =
                  item.data()[feed_constants.ACCOMPLISHED_TASKS_KEY] is int
                      ? item
                          .data()[feed_constants.ACCOMPLISHED_TASKS_KEY]
                          .toDouble()
                      : item.data()[feed_constants.ACCOMPLISHED_TASKS_KEY];
              if (weeksValues[cIndex] >= maxTasks) {
                maxTasks = weeksValues[cIndex].toInt() + 1;
              }
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last 12 weeks",
                  style: TextStyle(
                    color: Color(0xFFB2B5C3),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  width: size.width,
                  height: kIsWeb ? null : size.width / 2,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.70,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            ),
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: LineChart(
                            LineChartData(
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  if (weeksValues
                                      .where((element) => element > 0)
                                      .isEmpty)
                                    HorizontalLine(
                                      y: 1,
                                      color: const Color.fromRGBO(
                                        178,
                                        181,
                                        195,
                                        0.2,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                ],
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                checkToShowHorizontalLine: (_) => true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: const Color.fromRGBO(
                                      178,
                                      181,
                                      195,
                                      0.2,
                                    ),
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color.fromRGBO(
                                      0,
                                      21,
                                      51,
                                      0.5,
                                    ),
                                    fontSize: 14,
                                  ),
                                  getTitles: (value) {
                                    if (weeks[value.toInt()].day <= 7) {
                                      return DateFormat('MMM')
                                          .format(weeks[value.toInt()])
                                          .toUpperCase();
                                    }
                                    return '';
                                  },
                                  margin: 12,
                                ),
                                leftTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color.fromRGBO(
                                      0,
                                      21,
                                      51,
                                      0.5,
                                    ),
                                    fontSize: 14,
                                  ),
                                  getTitles: (value) {
                                    return value.toStringAsFixed(0);
                                  },
                                  reservedSize: 20,
                                  margin: 12,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              minX: 0,
                              maxX: 11,
                              minY: 0,
                              maxY: maxTasks.toDouble(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: weeks
                                      .map(
                                        (e) => FlSpot(
                                          weeks.indexOf(e).toDouble(),
                                          weeksValues[weeks.indexOf(e)],
                                        ),
                                      )
                                      .toList(),
                                  isCurved: true,
                                  colors: gradientColors,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, value, data, index) {
                                      return FlDotCirclePainter(
                                        radius: 5,
                                        color: Color.lerp(
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).accentColor,
                                          index.toDouble() / 11,
                                        ),
                                        strokeWidth: 0,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: false,
                                    colors: gradientColors
                                        .map((color) => color.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (items) => items
                                      .map(
                                        (e) => LineTooltipItem(
                                          DateFormat('dd, MMM')
                                              .format(weeks[e.x.toInt()]),
                                          Theme.of(context).textTheme.subtitle1,
                                        ),
                                      )
                                      .toList(),
                                ),
                                touchCallback: (response) {
                                  if ((response.lineBarSpots ?? [null])
                                          .first
                                          ?.spotIndex !=
                                      null)
                                    setState(() {
                                      selectedWeek =
                                          response.lineBarSpots.first.spotIndex;
                                    });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
