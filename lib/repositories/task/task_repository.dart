import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/task.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/TaskLog.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class TaskRepository {
  static Future<UserModel> inviteTaskPartnerByPhone(
      Task task, String phoneNumber) async {
    final user = await UserService.getUserByPhone(
      phoneNumber.replaceAll(' ', ''),
    );
    if (user != null) {
      return user;
    } else {
      await showDialog(
        context: Get.context,
        builder: (context) {
          return AlertDialog(
            title: Text('User not found'),
            content: Text(
                'The selected contact doesn\'t have an account associated to it, would you like to invite them ?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.red[400],
                  ),
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Share.share(
                    'Hey. I\'m using the Stacked Tasks app to get more done. Could you please help me out by being my accountability buddy? stackedtasks.com',
                  );
                },
                child: Text('Invite'),
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  static Future<bool> addTaskPostPhoto(task, photoURL) async {
    try {
      await FirebaseFirestore.instance
          .collection(FEED_KEY)
          .doc(task.id)
          .update({
        TASK_PHOTO_KEY: photoURL,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> changeTaskOrder(Task task, int newIndex) async {
    if (task.stackRef == 'inbox') {
      await FirebaseFirestore.instance
          .collection(INBOX_COLLECTION)
          .doc(task.id)
          .update({
        INDEX_KEY: newIndex,
      });
    } else {
      await FirebaseFirestore.instance
          .collection(stack_constants.TASKS_KEY)
          .doc(task.id)
          .update({
        INDEX_KEY: newIndex,
      });
    }
  }

  static List<TaskLog> getTaskLogs(Task task) {
    List<TaskLog> taskLogs = [];
    taskLogs.add(
      TaskLog(
        uid: 'creation_log',
        creationDateTime: task.creationDate,
        log: '"${task.title}" created',
        status: 1,
        taskID: task.id,
      ),
    );
    if (task.repetition != null) {
      taskLogs.add(
        TaskLog(
          uid: 'frequency_log',
          creationDateTime: task.creationDate,
          log: 'Frequency - ${task.frequency}',
          status: 1,
          taskID: task.id,
        ),
      );
    }
    if (task.donesHistory != null && task.donesHistory.isNotEmpty) {
      taskLogs.add(
        TaskLog(
          uid: 'recent_instance_log',
          creationDateTime: task.donesHistory.last,
          log: 'Most recent instance',
          status: 2,
          taskID: task.id,
        ),
      );
    } else {
      taskLogs.add(
        TaskLog(
          uid: 'recent_instance_log',
          creationDateTime: task.nextDueDate() ?? task.dueDates.last,
          log: 'Most recent instance',
          status: 1,
          taskID: task.id,
        ),
      );
    }
    if (task.nextDueDate() != null) {
      taskLogs.add(
        TaskLog(
          uid: 'upcoming_instance_log',
          creationDateTime: task.nextDueDate(),
          log: 'Upcoming instance',
          status: 1,
          taskID: task.id,
        ),
      );
    }
    return taskLogs;
  }
}
