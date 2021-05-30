import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/goal.dart';
import 'package:stackedtasks/constants/models/notification.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Notification.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class NotificationRepository {
  static Stream<List<Notification>> streamNotifications() {
    return FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: getCurrentUser().uid)
        .where(NOTIFICATION_STATUS_KEY, isNotEqualTo: -1)
        .snapshots()
        .asyncMap(
      (event) async {
        List<Notification> notifications = [];
        for (final notificationRaw in event.docs) {
          if (notificationRaw.data()['type'] == 'GOAL_PARTNER_INVITATION') {
            GoalInvitationNotification notification =
                GoalInvitationNotification.fromMap(
              notificationRaw.data(),
            );
            notification.sender =
                await UserService.getUser(notification.senderID);
            notifications.add(notification);
          } else if (notificationRaw.data()['type'] ==
              'TASK_PARTNER_INVITATION') {
            TaskInvitationNotification notification =
                TaskInvitationNotification.fromMap(
              notificationRaw.data(),
            );
            notification.sender =
                await UserService.getUser(notification.senderID);
            notifications.add(notification);
          } else if (notificationRaw.data()['type'] ==
              'STACK_PARTNER_INVITATION') {
            TasksStackInvitationNotification notification =
                TasksStackInvitationNotification.fromMap(
              notificationRaw.data(),
            );
            notification.sender =
                await UserService.getUser(notification.senderID);
            notifications.add(notification);
          }
        }
        return notifications;
      },
    );
  }

  static Stream<int> countNotifications() {
    return FirebaseFirestore.instance
        .collection(NOTIFICATIONS_COLLECTION)
        .where(NOTIFICATION_RECIEVER_KEY, isEqualTo: getCurrentUser().uid)
        .where(NOTIFICATION_STATUS_KEY, isNotEqualTo: -1)
        .snapshots()
        .map(
          (event) => event.size,
        );
  }

  static Future<bool> addGoalNotification(Goal goal, String invitedID) async {
    try {
      final res = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .add(
            GoalInvitationNotification(
              senderID: goal.userID,
              recieverID: invitedID,
              status: 0,
              goalRef: goal.id,
              goalTitle: goal.title,
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

  static Future<bool> addStackNotification(
      TasksStack stack, String invitedID) async {
    try {
      final res = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .add(
            TasksStackInvitationNotification(
              senderID: stack.userID,
              recieverID: invitedID,
              status: 0,
              stackRef: stack.id,
              stackTitle: stack.title,
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
      final res = await FirebaseFirestore.instance
          .collection(NOTIFICATIONS_COLLECTION)
          .add(
            TaskInvitationNotification(
              senderID: task.userID,
              recieverID: invitedID,
              status: 0,
              taskRef: task.id,
              taskTitle: task.title,
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

  static Future<bool> acceptInvitationNotification(
    Notification notification,
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
        goal.partnersIDs.add(getCurrentUser().uid);
        await goal.save();
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.id)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
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
        stack.partnersIDs.add(getCurrentUser().uid);
        await stack.save(
          updateSummaries: false,
        );
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.id)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
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
        task.partnersIDs.add(getCurrentUser().uid);
        await task.save(
          updateSummaries: false,
        );
        await FirebaseFirestore.instance
            .collection(NOTIFICATIONS_COLLECTION)
            .doc(notification.id)
            .update({
          NOTIFICATION_STATUS_KEY: -1,
        });
      }
      return true;
    } catch (e) {
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
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
