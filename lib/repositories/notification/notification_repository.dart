import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/notification.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Notification.dart';
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
          TaskInvitationNotification notification =
              TaskInvitationNotification.fromMap(
            notificationRaw.data(),
          );
          notification.sender =
              await UserService.getUser(notification.senderID);
          notifications.add(notification);
        }
        return notifications;
      },
    );
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
              type: 'TASK_INVITATION',
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

  static Future<bool> acceptTaskNotification(
      TaskInvitationNotification notification) async {
    try {
      final taskRaw = await FirebaseFirestore.instance
          .collection(TASKS_KEY)
          .doc(notification.taskRef)
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
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> declineTaskNotification(String notificationID) async {
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
