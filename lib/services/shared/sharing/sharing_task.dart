import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/goal_summary.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

shareTask(Task task, GlobalKey screenshotKey) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File screenshot = File(tempPath + '/${task.id}.jpg');
  if (!screenshot.existsSync()) screenshot.createSync();

  RenderRepaintBoundary boundary =
      screenshotKey.currentContext.findRenderObject();
  final boundaryImage = await boundary.toImage(
    pixelRatio: 2.0,
  );
  var capture = await boundaryImage.toByteData(
    format: ui.ImageByteFormat.png,
  );

  screenshot.writeAsBytesSync(capture.buffer.asUint8List());

  await Share.shareFiles(
    [screenshot.path],
    text: task.repetition != null
        ? 'I have just reached ${task.completionRate}% of my task ${task.title}!'
        : 'I just completed my task ${task.title}. Check it out!',
  );
}

shareGoal(
    GoalSummary goalSummary, ScreenshotController screenshotController) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File screenshot = File(tempPath + '/${goalSummary.id}.jpg');
  if (!screenshot.existsSync()) screenshot.createSync();

  screenshot.writeAsBytesSync(
      (await screenshotController.capture()).buffer.asUint8List());

  await Share.shareFiles(
    [screenshot.path],
    text:
        'I have just reached ${(goalSummary.completionPercentage * 100).toStringAsFixed(0)}% of my goal ${goalSummary.title}!',
  );
}
