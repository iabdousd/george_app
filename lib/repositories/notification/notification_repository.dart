import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/goal.dart';
import 'package:stackedtasks/constants/models/notification.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/InvitationNotification.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/notification/notification.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import "package:async/async.dart" show StreamZip;

class NotificationRepository {
  static Stream<List<NotificationModel>> streamNotifications() {
    return FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .where(
          NOTIFICATION_RECIEVER_KEY,
          isEqualTo: getCurrentUser().uid,
        )
        .where(
          NOTIFICATION_STATUS_KEY,
          isNotEqualTo: -1,
        )
        .orderBy(NOTIFICATION_STATUS_KEY)
        .orderBy(
          'creationDate',
          descending: true,
        )
        .snapshots()
        .asyncMap(
      (event) async {
        List<NotificationModel> notifications = [];
        for (final notificationRaw in event.docs) {
          if (notificationRaw.data()['action'] == 'GOAL_PARTNER_INVITATION') {
            GoalInvitationNotification notification =
                GoalInvitationNotification.fromMap(
              notificationRaw.data(),
            );

            await notification.fetchUserModels();

            notifications.add(notification);
          } else if (notificationRaw.data()['action'] ==
              'TASK_PARTNER_INVITATION') {
            TaskInvitationNotification notification =
                TaskInvitationNotification.fromMap(
              notificationRaw.data(),
            );

            await notification.fetchUserModels();

            notifications.add(notification);
          } else if (notificationRaw.data()['action'] ==
              'STACK_PARTNER_INVITATION') {
            TasksStackInvitationNotification notification =
                TasksStackInvitationNotification.fromMap(
              notificationRaw.data(),
            );

            await notification.fetchUserModels();

            notifications.add(notification);
          } else {
            NotificationModel notification = NotificationModel.fromMap(
              notificationRaw.data(),
            );
            await notification.fetchUserModels();
            notifications.add(notification);
          }
        }
        return notifications;
      },
    );
  }

  static Stream<int> countNotifications() {
    return StreamZip([
      FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: getCurrentUser().uid)
          .where(NOTIFICATION_STATUS_KEY, isEqualTo: 0)
          .snapshots()
          .map(
            (event) => event.size,
          ),
    ]).map(
      (counts) => counts[0],
    );
  }

  static Future<void> deleteNotification(NotificationModel notification) async {
    await FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .doc(notification.uid)
        .delete();
  }

  static Future<bool> addGoalNotification(Goal goal, String invitedID) async {
    // try {
    if (goal.userID == invitedID) {
      await showFlushBar(
        title: 'Hmmm...',
        message: 'Unfortunately, you cannot invite your self !',
        success: false,
      );
    }

    final alreadyNotification = await FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .where('senderID', isEqualTo: goal.userID)
        .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: invitedID)
        .where('data', isEqualTo: goal.id)
        .where(NOTIFICATION_STATUS_KEY, isEqualTo: 0)
        .get();

    if (alreadyNotification.size > 0) {
      print('Already invited');
      showFlushBar(
        title: 'Already Invited',
        message: 'This user has been already invited to this task',
        success: false,
      );
      return false;
    }

    final res = await FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .add(
          GoalInvitationNotification(
            senderID: goal.userID,
            userID: invitedID,
            status: 0,
            creationDate: DateTime.now(),
            title: getCurrentUser().displayName,
            body: 'Invited you to goal "${goal.title}"',
            icon: getCurrentUser().photoURL,
            data: goal.id,
          ).toMap(),
        );

    res.update({
      NOTIFICATION_ID_KEY: res.id,
    });
    return true;
    // } catch (e) {
    // return false;
    // }
  }

  static Future<bool> addStackNotification(
      TasksStack stack, String invitedID) async {
    try {
      if (stack.userID == invitedID) {
        await showFlushBar(
          title: 'Hmmm...',
          message: 'Unfortunately, you cannot invite your self !',
          success: false,
        );
      }

      final alreadyNotification = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .where('senderID', isEqualTo: stack.userID)
          .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: invitedID)
          .where('data', isEqualTo: stack.id)
          .where(NOTIFICATION_STATUS_KEY, isEqualTo: 0)
          .get();

      if (alreadyNotification.size > 0) {
        showFlushBar(
          title: 'Already Invited',
          message: 'This user has been already invited to this task',
          success: false,
        );
        return false;
      }

      final res = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .add(
            TasksStackInvitationNotification(
              senderID: stack.userID,
              userID: invitedID,
              status: 0,
              creationDate: DateTime.now(),
              title: getCurrentUser().displayName,
              body: 'Invited you to stack "${stack.title}"',
              icon: getCurrentUser().photoURL,
              data: stack.id,
            ).toMap(),
          );
      res.update({
        NOTIFICATION_ID_KEY: res.id,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addTaskNotification(Task task, String invitedID) async {
    try {
      if (task.userID == invitedID) {
        await showFlushBar(
          title: 'Hmmm...',
          message: 'Unfortunately, you cannot invite your self !',
          success: false,
        );
      }

      final alreadyNotification = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .where('senderID', isEqualTo: task.userID)
          .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: invitedID)
          .where('data', isEqualTo: task.id)
          .where(NOTIFICATION_STATUS_KEY, isEqualTo: 0)
          .get();

      if (alreadyNotification.size > 0) {
        showFlushBar(
          title: 'Already Invited',
          message: 'This user has been already invited to this task',
          success: false,
        );
        return false;
      }

      final res = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .add(
            TaskInvitationNotification(
              senderID: task.userID,
              userID: invitedID,
              status: 0,
              creationDate: DateTime.now(),
              title: getCurrentUser().displayName,
              body: 'Invited you to task "${task.title}"',
              icon: getCurrentUser().photoURL,
              data: task.id,
            ).toMap(taskID: task.id),
          );
      res.update({
        NOTIFICATION_ID_KEY: res.id,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> acceptInvitationNotification(
    NotificationModel notification,
    String type,
  ) async {
    try {
      if (type == 'GOAL_PARTNER_INVITATION') {
        final goalRaw = await FirebaseFirestore.instance
            .collection(GOALS_KEY)
            .doc((notification as GoalInvitationNotification).goalRef)
            .get();
        Goal goal = Goal.fromJson(
          goalRaw.data(),
          id: goalRaw.id,
        );
        if (!goal.partnersIDs.contains(getCurrentUser().uid)) {
          goal.partnersIDs.add(getCurrentUser().uid);
          await goal.save();
        } else {
          showFlushBar(
            title: 'Already Partner',
            message: 'You are already partnering in that Goal !',
            success: false,
          );
          return null;
        }
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.uid)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
          ACCEPTED_KEY: true,
        });
      } else if (type == 'STACK_PARTNER_INVITATION') {
        final stackRaw = await FirebaseFirestore.instance
            .collection(STACKS_KEY)
            .doc((notification as TasksStackInvitationNotification).stackRef)
            .get();
        TasksStack stack = TasksStack.fromJson(
          stackRaw.data(),
          id: stackRaw.id,
        );
        if (!stack.partnersIDs.contains(getCurrentUser().uid)) {
          stack.partnersIDs.add(getCurrentUser().uid);
          await stack.save(
            updateSummaries: false,
          );
        } else {
          showFlushBar(
            title: 'Already Partner',
            message: 'You are already partnering in that Stack !',
            success: false,
          );
          return null;
        }
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.uid)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
          ACCEPTED_KEY: true,
        });
      } else if (type == 'TASK_PARTNER_INVITATION') {
        final taskRaw = await FirebaseFirestore.instance
            .collection(TASKS_KEY)
            .doc((notification as TaskInvitationNotification).taskRef)
            .get();

        Task task = Task.fromJson(
          taskRaw.data(),
          id: taskRaw.id,
        );
        if (!task.partnersIDs.contains(getCurrentUser().uid)) {
          task.partnersIDs.add(getCurrentUser().uid);
          await task.save(
            updateSummaries: false,
          );
        } else {
          showFlushBar(
            title: 'Already Partner',
            message: 'You are already partnering in that Task !',
            success: false,
          );
          return null;
        }
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.uid)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
          ACCEPTED_KEY: true,
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> declineInviteNotification(String notificationID) async {
    try {
      await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .doc(notificationID)
          .update({
        NOTIFICATION_STATUS_KEY: -1,
        ACCEPTED_KEY: false,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
