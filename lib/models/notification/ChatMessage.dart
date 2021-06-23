import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stackedtasks/models/UserModel.dart';

class ChatMessage {
  String uid;
  String senderID;
  String content;
  int status;

  bool viewed;
  DateTime sendDate;
  DateTime viewDate;

  UserModel sender;

  ChatMessage({
    this.uid,
    this.senderID,
    this.content,
    this.status,
    this.viewed: false,
    this.sendDate,
    this.viewDate,
    this.sender,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'senderID': senderID,
      'content': content,
      'status': status,
      'viewed': viewed,
      'sendDate': sendDate,
      'viewDate': viewDate,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      uid: map['uid'],
      senderID: map['senderID'],
      content: map['content'],
      status: map['status'],
      viewed: map['viewed'],
      sendDate: (map['sendDate'] as Timestamp).toDate().toLocal(),
      viewDate: (map['viewDate'] as Timestamp)?.toDate()?.toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source));

  ChatMessage copyWith({
    String uid,
    String senderID,
    String content,
    int status,
    bool viewed,
    DateTime sendDate,
    DateTime viewDate,
    UserModel sender,
  }) {
    return ChatMessage(
      uid: uid ?? this.uid,
      senderID: senderID ?? this.senderID,
      content: content ?? this.content,
      status: status ?? this.status,
      viewed: viewed ?? this.viewed,
      sendDate: sendDate ?? this.sendDate,
      viewDate: viewDate ?? this.viewDate,
      sender: sender ?? this.sender,
    );
  }
}
