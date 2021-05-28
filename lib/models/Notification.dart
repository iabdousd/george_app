import 'dart:convert';

import 'package:stackedtasks/constants/models/notification.dart';
import 'package:stackedtasks/models/UserModel.dart';

abstract class Notification {
  String id;
  String type;
  String senderID;
  String recieverID;
  UserModel sender;
  int status;

  Notification({
    this.id,
    this.type,
    this.senderID,
    this.recieverID,
    this.status,
  });
}

class GoalInvitationNotification extends Notification {
  String goalRef;
  String goalTitle;

  GoalInvitationNotification({
    String id,
    String type,
    String senderID,
    String recieverID,
    UserModel sender,
    int status,
    this.goalRef,
    this.goalTitle,
  }) : super(
          id: id,
          type: 'GOAL_PARTNER_INVITATION',
          senderID: senderID,
          recieverID: recieverID,
          status: status,
        );

  Map<String, dynamic> toMap() {
    return {
      NOTIFICATION_ID_KEY: id,
      'type': type,
      'senderID': senderID,
      NOTIFICATION_RECIEVER_KEY: recieverID,
      NOTIFICATION_STATUS_KEY: status,
      'goalRef': goalRef,
      'goalTitle': goalTitle,
    };
  }

  factory GoalInvitationNotification.fromMap(Map<String, dynamic> map) {
    return GoalInvitationNotification(
      id: map[NOTIFICATION_ID_KEY],
      type: map['type'],
      senderID: map['senderID'],
      recieverID: map[NOTIFICATION_RECIEVER_KEY],
      status: map[NOTIFICATION_STATUS_KEY],
      goalRef: map['goalRef'],
      goalTitle: map['goalTitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalInvitationNotification.fromJson(String source) =>
      GoalInvitationNotification.fromMap(json.decode(source));
}

class TasksStackInvitationNotification extends Notification {
  String stackRef;
  String stackTitle;

  TasksStackInvitationNotification({
    String id,
    String type,
    String senderID,
    String recieverID,
    UserModel sender,
    int status,
    this.stackRef,
    this.stackTitle,
  }) : super(
          id: id,
          type: 'STACK_PARTNER_INVITATION',
          senderID: senderID,
          recieverID: recieverID,
          status: status,
        );

  Map<String, dynamic> toMap() {
    return {
      NOTIFICATION_ID_KEY: id,
      'type': type,
      'senderID': senderID,
      NOTIFICATION_RECIEVER_KEY: recieverID,
      NOTIFICATION_STATUS_KEY: status,
      'stackRef': stackRef,
      'stackTitle': stackTitle,
    };
  }

  factory TasksStackInvitationNotification.fromMap(Map<String, dynamic> map) {
    return TasksStackInvitationNotification(
      id: map[NOTIFICATION_ID_KEY],
      type: map['type'],
      senderID: map['senderID'],
      recieverID: map[NOTIFICATION_RECIEVER_KEY],
      status: map[NOTIFICATION_STATUS_KEY],
      stackRef: map['stackRef'],
      stackTitle: map['stackTitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TasksStackInvitationNotification.fromJson(String source) =>
      TasksStackInvitationNotification.fromMap(json.decode(source));
}

class TaskInvitationNotification extends Notification {
  String taskRef;
  String taskTitle;

  TaskInvitationNotification({
    String id,
    String type,
    String senderID,
    String recieverID,
    UserModel sender,
    int status,
    this.taskRef,
    this.taskTitle,
  }) : super(
          id: id,
          type: 'TASK_PARTNER_INVITATION',
          senderID: senderID,
          recieverID: recieverID,
          status: status,
        );

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
