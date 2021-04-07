import 'dart:math';

import 'package:plandoraslist/constants/models/stack_summary.dart'
    as stack_summary_constants;

class StackSummary {
  String id;
  String title;
  Duration allocatedTime;
  int tasksTotal;
  int tasksAccomlished;

  StackSummary({
    this.id,
    this.title,
    this.tasksTotal,
    this.tasksAccomlished,
    this.allocatedTime,
  });

  get completionPercentage => tasksAccomlished / max(1, tasksTotal);

  StackSummary.fromJson(jsonObject) {
    this.id = jsonObject[stack_summary_constants.ID_KEY];
    this.title = jsonObject[stack_summary_constants.TITLE_KEY];
    this.tasksTotal = jsonObject[stack_summary_constants.TASKS_TOTAL_KEY];
    this.tasksAccomlished =
        jsonObject[stack_summary_constants.TASKS_ACCOMPLISHED_KEY];
    this.allocatedTime = Duration(
        milliseconds: jsonObject[stack_summary_constants.ALLOCATED_TIME_KEY]);
  }

  Map toJson() {
    return {
      stack_summary_constants.ID_KEY: id,
      stack_summary_constants.TITLE_KEY: title,
      stack_summary_constants.TASKS_TOTAL_KEY: tasksTotal,
      stack_summary_constants.TASKS_ACCOMPLISHED_KEY: tasksAccomlished,
      stack_summary_constants.ALLOCATED_TIME_KEY: allocatedTime.inMilliseconds,
    };
  }
}
