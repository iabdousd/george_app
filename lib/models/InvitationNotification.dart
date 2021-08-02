import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/UserModel.dart';

import 'notification/notification.dart';

abstract class InvitationNotification extends NotificationModel {
  InvitationNotification({
    String uid,
    String userID,
    String senderID,
    DateTime creationDate,
    int status,
    String title,
    String body,
    String icon,
    String action,
    dynamic data,
    UserModel sender,
    UserModel reciever,
  }) : super(
          uid: uid,
          userID: userID,
          senderID: senderID,
          creationDate: creationDate,
          status: status,
          title: title,
          body: body,
          icon: icon,
          action: action,
          data: data,
          sender: sender,
          reciever: reciever,
        );
}

class GoalInvitationNotification extends InvitationNotification {
  String goalRef;

  GoalInvitationNotification({
    String uid,
    String senderID,
    String title,
    String body,
    String userID,
    UserModel sender,
    UserModel reciever,
    DateTime creationDate,
    dynamic data,
    String icon,
    int status,
  })  : this.goalRef = data,
        super(
          uid: uid,
          action: 'GOAL_PARTNER_INVITATION',
          senderID: senderID,
          userID: userID,
          status: status,
          title: title,
          body: body,
          creationDate: creationDate,
          data: data,
          icon: icon,
          sender: sender,
          reciever: reciever,
        );

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'data': goalRef,
    };
  }

  factory GoalInvitationNotification.fromMap(Map<String, dynamic> map) {
    return GoalInvitationNotification(
      uid: map['uid'],
      userID: map['userID'],
      senderID: map['senderID'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      status: map['status'],
      title: map['title'],
      body: map['body'],
      icon: map['icon'],
      data: map['data'],
    );
  }
}

class TasksStackInvitationNotification extends InvitationNotification {
  String stackRef;

  TasksStackInvitationNotification({
    String uid,
    String senderID,
    String title,
    String body,
    String userID,
    UserModel sender,
    UserModel reciever,
    DateTime creationDate,
    dynamic data,
    String icon,
    int status,
  })  : this.stackRef = data,
        super(
          uid: uid,
          action: 'STACK_PARTNER_INVITATION',
          senderID: senderID,
          userID: userID,
          status: status,
          title: title,
          body: body,
          creationDate: creationDate,
          data: data,
          icon: icon,
          sender: sender,
          reciever: reciever,
        );

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'data': data,
    };
  }

  factory TasksStackInvitationNotification.fromMap(Map<String, dynamic> map) {
    return TasksStackInvitationNotification(
      uid: map['uid'],
      userID: map['userID'],
      senderID: map['senderID'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      status: map['status'],
      title: map['title'],
      body: map['body'],
      icon: map['icon'],
      data: map['data'],
    );
  }
}

class TaskInvitationNotification extends InvitationNotification {
  String taskRef;

  TaskInvitationNotification({
    String uid,
    String senderID,
    String title,
    String body,
    String userID,
    UserModel sender,
    UserModel reciever,
    DateTime creationDate,
    String data,
    String icon,
    int status,
  })  : this.taskRef = data,
        super(
          uid: uid,
          action: 'TASK_PARTNER_INVITATION',
          senderID: senderID,
          userID: userID,
          status: status,
          title: title,
          body: body,
          creationDate: creationDate,
          data: data,
          icon: icon,
          sender: sender,
          reciever: reciever,
        );

  Map<String, dynamic> toMap({String taskID}) {
    return {
      ...super.toMap(),
      'data': data,
    };
  }

  factory TaskInvitationNotification.fromMap(Map<String, dynamic> map) {
    return TaskInvitationNotification(
      uid: map['uid'],
      userID: map['userID'],
      senderID: map['senderID'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      status: map['status'],
      title: map['title'],
      body: map['body'],
      icon: map['icon'],
      data: map['data'],
    );
  }
}
