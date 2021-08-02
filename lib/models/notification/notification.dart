import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class NotificationModel {
  String uid;
  String userID;
  String senderID;
  DateTime creationDate;
  int status;
  String title;
  String body;
  String icon;
  String action;
  dynamic data;

  UserModel sender, reciever;

  NotificationModel({
    this.uid,
    this.userID,
    this.senderID,
    this.creationDate,
    this.status,
    this.title,
    this.body,
    this.icon,
    this.action,
    this.data,
    this.sender,
    this.reciever,
  });

  Future<void> fetchUserModels() async {
    this.reciever = await UserService.getUser(userID);
    if (senderID != null && senderID.isNotEmpty)
      this.sender = await UserService.getUser(senderID);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userID': userID,
      'senderID': senderID,
      'creationDate': creationDate,
      'status': status,
      'title': title,
      'body': body,
      'icon': icon,
      'action': action,
      'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      uid: map['uid'],
      userID: map['userID'],
      senderID: map['senderID'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      status: map['status'],
      title: map['title'],
      body: map['body'],
      icon: map['icon'],
      action: map['action'],
      data: map['data'],
    );
  }
}
