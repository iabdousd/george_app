import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:george_project/widgets/shared/dashed_divider.dart';

class WeekProgress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WeekProgressState();
}

class WeekProgressState extends State<WeekProgress> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0 + 20.0),
          margin: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Weekly Progress",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 32),
          width: size.width,
          height: size.width / 1.7,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.7,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  color: Theme.of(context).backgroundColor,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 1,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          if (value == 0)
                            return FlLine(
                                strokeWidth: 1, color: Color(0x22000000));
                          else if (value == 0.5)
                            return FlLine(
                                strokeWidth: 1, color: Color(0x22000000));
                          else if (value == 1)
                            return FlLine(
                                strokeWidth: 1, color: Color(0x22000000));
                          return FlLine(
                              strokeWidth: 0, color: Colors.transparent);
                        },
                        horizontalInterval: .5,
                        checkToShowHorizontalLine: (value) {
                          if (value == 0)
                            return true;
                          else if (value == 0.5)
                            return true;
                          else if (value == 1) return true;
                          return false;
                        },
                        drawVerticalLine: false,
                      ),
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.transparent,
                          tooltipPadding: const EdgeInsets.all(0),
                          tooltipMargin: 8,
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            return BarTooltipItem(
                              rod.y.round().toString(),
                              TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) =>
                              Theme.of(context).textTheme.subtitle2,
                          margin: 20,
                          getTitles: (double value) {
                            switch (value.toInt()) {
                              case 0:
                                return 'Mn';
                              case 1:
                                return 'Te';
                              case 2:
                                return 'Wd';
                              case 3:
                                return 'Tu';
                              case 4:
                                return 'Fr';
                              case 5:
                                return 'St';
                              case 6:
                                return 'Sn';
                              default:
                                return '';
                            }
                          },
                        ),
                        leftTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(
                          getTitles: (value) {
                            if (value == 0) {
                              return '0%';
                            } else if (value == .5) {
                              return '50%';
                            } else if (value == 1) {
                              return '100%';
                            } else {
                              return '';
                            }
                          },
                          showTitles: true,
                          getTextStyles: (value) =>
                              Theme.of(context).textTheme.subtitle2,
                          reservedSize: 32,
                          margin: 4,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(y: .8, colors: [
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(y: 1.0, colors: [
                              Colors.lightBlueAccent,
                              Colors.greenAccent
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(y: .8, colors: [
                              Colors.lightBlueAccent,
                              Colors.greenAccent
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(y: .5, colors: [
                              Colors.lightBlueAccent,
                              Colors.greenAccent
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(y: .6, colors: [
                              Colors.lightBlueAccent,
                              Colors.greenAccent
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(y: .10, colors: [
                              Colors.lightBlueAccent,
                              Colors.greenAccent
                            ])
                          ],
                          showingTooltipIndicators: [0],
                        ),
                      ],
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
}
