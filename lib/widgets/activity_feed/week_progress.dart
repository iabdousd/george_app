import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:george_project/repositories/feed/statistics.dart';
import 'package:intl/intl.dart';
import 'package:george_project/constants/feed.dart' as feed_constants;

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
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor,
    ];

    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: weeklyAccsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (var item in snapshot.data.docs) {
            if (weeks.contains(
                item.data()[feed_constants.WEEK_START_DATE_KEY].toDate())) {
              int cIndex = weeks.indexOf(
                  item.data()[feed_constants.WEEK_START_DATE_KEY].toDate());
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                margin: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Last 12 weeks",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                ),
              ),
              Container(
                width: size.width,
                height: size.width / 1.7,
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
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 18.0,
                            left: 12.0,
                            top: 24,
                            bottom: 12,
                          ),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: false,
                                drawVerticalLine: true,
                                getDrawingVerticalLine: (value) {
                                  if (value.toInt() == selectedWeek)
                                    return FlLine(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 2,
                                    );
                                  return FlLine(
                                    color: const Color(0x30000000),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  getTitles: (value) {
                                    if (value.toInt() == selectedWeek) {
                                      return '${weeksValues[value.toInt()].toStringAsFixed(0)} tasks';
                                    }
                                    return '';
                                  },
                                  margin: 8,
                                ),
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.w500,
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
                                  margin: 8,
                                ),
                                leftTitles: SideTitles(
                                  showTitles: false,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color(0xff67727d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  getTitles: (value) {
                                    return value.toStringAsFixed(0);
                                  },
                                  reservedSize: 28,
                                  margin: 12,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0x30000000),
                                  width: 1,
                                ),
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
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, value, data, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: index == selectedWeek
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).backgroundColor,
                                        strokeColor: index == selectedWeek
                                            ? Theme.of(context)
                                                .primaryColor
                                                .withOpacity(.5)
                                            : Theme.of(context).primaryColor,
                                        strokeWidth:
                                            index == selectedWeek ? 5 : 3,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
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
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:george_project/widgets/shared/dashed_divider.dart';

// class WeekProgress extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => WeekProgressState();
// }

// class WeekProgressState extends State<WeekProgress> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0 + 20.0),
//           margin: const EdgeInsets.only(top: 16.0),
//           child: Text(
//             "Weekly Progress",
//             style: Theme.of(context)
//                 .textTheme
//                 .headline6
//                 .copyWith(fontWeight: FontWeight.w900),
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 32),
//           width: size.width,
//           height: size.width / 1.7,
//           child: Stack(
//             children: [
//               AspectRatio(
//                 aspectRatio: 1.7,
//                 child: Card(
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   color: Theme.of(context).backgroundColor,
//                   child: BarChart(
//                     BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       maxY: 1,
//                       minY: 0,
//                       gridData: FlGridData(
//                         show: true,
//                         drawHorizontalLine: true,
//                         getDrawingHorizontalLine: (value) {
//                           if (value == 0)
//                             return FlLine(
//                                 strokeWidth: 1, color: Color(0x22000000));
//                           else if (value == 0.5)
//                             return FlLine(
//                                 strokeWidth: 1, color: Color(0x22000000));
//                           else if (value == 1)
//                             return FlLine(
//                                 strokeWidth: 1, color: Color(0x22000000));
//                           return FlLine(
//                               strokeWidth: 0, color: Colors.transparent);
//                         },
//                         horizontalInterval: .5,
//                         checkToShowHorizontalLine: (value) {
//                           if (value == 0)
//                             return true;
//                           else if (value == 0.5)
//                             return true;
//                           else if (value == 1) return true;
//                           return false;
//                         },
//                         drawVerticalLine: false,
//                       ),
//                       barTouchData: BarTouchData(
//                         enabled: false,
//                         touchTooltipData: BarTouchTooltipData(
//                           tooltipBgColor: Colors.transparent,
//                           tooltipPadding: const EdgeInsets.all(0),
//                           tooltipMargin: 8,
//                           getTooltipItem: (
//                             BarChartGroupData group,
//                             int groupIndex,
//                             BarChartRodData rod,
//                             int rodIndex,
//                           ) {
//                             return BarTooltipItem(
//                               rod.y.round().toString(),
//                               TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         show: true,
//                         bottomTitles: SideTitles(
//                           showTitles: true,
//                           getTextStyles: (value) =>
//                               Theme.of(context).textTheme.subtitle2,
//                           margin: 20,
//                           getTitles: (double value) {
//                             switch (value.toInt()) {
//                               case 0:
//                                 return 'Mn';
//                               case 1:
//                                 return 'Te';
//                               case 2:
//                                 return 'Wd';
//                               case 3:
//                                 return 'Tu';
//                               case 4:
//                                 return 'Fr';
//                               case 5:
//                                 return 'St';
//                               case 6:
//                                 return 'Sn';
//                               default:
//                                 return '';
//                             }
//                           },
//                         ),
//                         leftTitles: SideTitles(showTitles: false),
//                         rightTitles: SideTitles(
//                           getTitles: (value) {
//                             if (value == 0) {
//                               return '0%';
//                             } else if (value == .5) {
//                               return '50%';
//                             } else if (value == 1) {
//                               return '100%';
//                             } else {
//                               return '';
//                             }
//                           },
//                           showTitles: true,
//                           getTextStyles: (value) =>
//                               Theme.of(context).textTheme.subtitle2,
//                           reservedSize: 32,
//                           margin: 4,
//                         ),
//                       ),
//                       borderData: FlBorderData(
//                         show: false,
//                       ),
//                       barGroups: [
//                         BarChartGroupData(
//                           x: 3,
//                           barRods: [
//                             BarChartRodData(
//                               y: .6,
//                               colors: [
//                                 Theme.of(context).primaryColor,
//                                 Colors.greenAccent
//                               ],
//                             )
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                         BarChartGroupData(
//                           x: 1,
//                           barRods: [
//                             BarChartRodData(
//                               y: 1.0,
//                               colors: [
//                                 Theme.of(context).primaryColor,
//                                 Colors.greenAccent
//                               ],
//                             )
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                         BarChartGroupData(
//                           x: 2,
//                           barRods: [
//                             BarChartRodData(y: .8, colors: [
//                               Theme.of(context).primaryColor,
//                               Colors.greenAccent
//                             ])
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                         BarChartGroupData(
//                           x: 3,
//                           barRods: [
//                             BarChartRodData(y: .5, colors: [
//                               Theme.of(context).primaryColor,
//                               Colors.greenAccent
//                             ])
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                         BarChartGroupData(
//                           x: 3,
//                           barRods: [
//                             BarChartRodData(y: .6, colors: [
//                               Theme.of(context).primaryColor,
//                               Colors.greenAccent
//                             ])
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                         BarChartGroupData(
//                           x: 3,
//                           barRods: [
//                             BarChartRodData(y: .10, colors: [
//                               Theme.of(context).primaryColor,
//                               Colors.greenAccent
//                             ])
//                           ],
//                           showingTooltipIndicators: [0],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
