import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskLog {
  String uid;
  String log;
  DateTime creationDateTime;
  int status;
  String taskID;

  TaskLog({
    this.uid,
    this.log,
    this.creationDateTime,
    this.status,
    this.taskID,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'log': log,
      'creationDateTime': creationDateTime,
      'status': status,
      'taskID': taskID,
    };
  }

  factory TaskLog.fromMap(Map<String, dynamic> map) {
    return TaskLog(
      uid: map['uid'],
      log: map['log'],
      creationDateTime: (map['creationDateTime'] as Timestamp).toDate(),
      status: map['status'],
      taskID: map['taskID'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskLog.fromJson(String source) =>
      TaskLog.fromMap(json.decode(source));
}
