import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/notification_chat.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class NotificationChat {
  String chatUID;
  List<String> usersIDs;
  int status;
  Map<String, int> newMessages;
  String lastMessage;
  DateTime lastMessageDate;

  List<UserModel> users;

  int newMessagesForUser(String userID) =>
      newMessages != null && newMessages[userID] != null
          ? newMessages[userID]
          : 0;

  NotificationChat({
    this.chatUID,
    this.usersIDs,
    this.status: 1,
    this.newMessages,
    this.lastMessage,
    this.lastMessageDate,
    this.users,
  });

  Map<String, dynamic> toMap() {
    return {
      CHAT_UID_KEY: chatUID,
      CHAT_USERS_IDS_KEY: usersIDs,
      CHAT_STATUS_KEY: status,
      CHAT_NEW_MESSAGES_KEY: newMessages,
      CHAT_LAST_MESSAGE_KEY: lastMessage,
      CHAT_LAST_MESSAGE_DATE_KEY: lastMessageDate,
    };
  }

  factory NotificationChat.fromMap(Map<String, dynamic> map) {
    return NotificationChat(
      chatUID: map[CHAT_UID_KEY],
      usersIDs: List<String>.from(map[CHAT_USERS_IDS_KEY] ?? [])[0] ==
              getCurrentUser().uid
          ? List<String>.from(map[CHAT_USERS_IDS_KEY] ?? []).reversed.toList()
          : List<String>.from(map[CHAT_USERS_IDS_KEY] ?? []),
      status: map[CHAT_STATUS_KEY],
      newMessages: Map<String, int>.from(map[CHAT_NEW_MESSAGES_KEY] ?? {}),
      lastMessage: map[CHAT_LAST_MESSAGE_KEY],
      lastMessageDate: map[CHAT_LAST_MESSAGE_DATE_KEY] is Timestamp
          ? map[CHAT_LAST_MESSAGE_DATE_KEY]?.toDate()?.toLocal()
          : DateTime.fromMillisecondsSinceEpoch(
              map[CHAT_LAST_MESSAGE_DATE_KEY],
            ),
    );
  }
}
