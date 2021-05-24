import 'dart:convert';

import 'package:stackedtasks/constants/models/notification.dart';
import 'package:stackedtasks/models/UserModel.dart';

abstract class Notification {}

class TaskInvitationNotification extends Notification {
  String id;
  String type;
  String senderID;
  String recieverID;
  String taskRef;
  String taskTitle;
  UserModel sender;
  int status;

  TaskInvitationNotification({
    this.id,
    this.type,
    this.senderID,
    this.recieverID,
    this.taskRef,
    this.taskTitle,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      NOTIFICATION_ID_KEY: id,
      'type': type,
      'senderID': senderID,
      NOTIFICATION_RECIEVER_KEY: recieverID,
      NOTIFICATION_STATUS_KEY: status,
      'taskRef': taskRef,
      'taskTitle': taskTitle,
    };
  }

  factory TaskInvitationNotification.fromMap(Map<String, dynamic> map) {
    return TaskInvitationNotification(
      id: map[NOTIFICATION_ID_KEY],
      type: map['type'],
      senderID: map['senderID'],
      recieverID: map[NOTIFICATION_RECIEVER_KEY],
      status: map[NOTIFICATION_STATUS_KEY],
      taskRef: map['taskRef'],
      taskTitle: map['taskTitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskInvitationNotification.fromJson(String source) =>
      TaskInvitationNotification.fromMap(json.decode(source));
}
