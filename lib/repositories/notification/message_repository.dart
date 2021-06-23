import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/notification_chat.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/ChatMessage.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class MessageRepository {
  static Future<String> createChat(NotificationChat chat) async {
    print('CHAT: ${chat.toMap()}');
    final ref =
        await FirebaseFirestore.instance.collection(CHAT_COLLECTION).add(
              chat.toMap(),
            );
    await ref.update({
      CHAT_UID_KEY: ref.id,
    });

    return ref.id;
  }

  static Stream<List<NotificationChat>> getChats() {
    return FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .where(
          CHAT_USERS_IDS_KEY,
          arrayContains: getCurrentUser().uid,
        )
        .orderBy(CHAT_LAST_MESSAGE_DATE_KEY, descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<NotificationChat> chats = [];

      for (QueryDocumentSnapshot chatRaw in event.docs) {
        try {
          final NotificationChat chat =
              NotificationChat.fromMap(chatRaw.data());
          final otherUserUID = chat.usersIDs
              .where(
                (element) => element != getCurrentUser().uid,
              )
              .first;

          final otherUser = await UserService.getUser(
            otherUserUID,
          );

          chat.users = [
            otherUser,
            UserModel(
              uid: getCurrentUser().uid,
              fullName: getCurrentUser().displayName,
              email: getCurrentUser().email,
              phoneNumber: getCurrentUser().phoneNumber,
              photoURL: getCurrentUser().photoURL,
            )
          ];

          chats.add(chat);
        } catch (e) {
          print(e);
        }
      }

      return chats;
    });
  }

  static Future<NotificationChat> getChatByUsers(List<String> users) async {
    QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .where(
          CHAT_USERS_IDS_KEY,
          isEqualTo: users,
        )
        .get();

    if (chatSnapshot.size == 0) {
      chatSnapshot = await FirebaseFirestore.instance
          .collection(CHAT_COLLECTION)
          .where(
            CHAT_USERS_IDS_KEY,
            isEqualTo: users.reversed.toList(),
          )
          .get();
    }
    if (chatSnapshot.size > 0) {
      NotificationChat chat = NotificationChat.fromMap(
        chatSnapshot.docs.first.data(),
      );

      final otherUserUID = chat.usersIDs
          .where(
            (element) => element != getCurrentUser().uid,
          )
          .first;

      final otherUser = await UserService.getUser(
        otherUserUID,
      );

      chat.users = [
        otherUser,
        UserModel(
          uid: getCurrentUser().uid,
          fullName: getCurrentUser().displayName,
          email: getCurrentUser().email,
          phoneNumber: getCurrentUser().phoneNumber,
          photoURL: getCurrentUser().photoURL,
        )
      ];

      return chat;
    }
    return null;
  }

  static Future<Map<String, dynamic>> getChatMessages(
    NotificationChat chat, [
    DocumentSnapshot<Map<String, dynamic>> beforeDocument,
  ]) async {
    Query query = FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .doc(chat.chatUID)
        .collection(CHAT_MESSAGES_COLLECTION)
        .orderBy('sendDate', descending: true);

    if (beforeDocument != null) {
      query = query
          .where(
            'sendDate',
            isLessThan: beforeDocument.data()['sendDate'],
          )
          .limit(16);
    } else {
      query = query.limit(16);
    }

    final queryData = await query.get();

    FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .doc(chat.chatUID)
        .update({
      CHAT_NEW_MESSAGES_KEY: {
        ...(chat.newMessages ?? {}),
        getCurrentUser().uid: 0,
      },
    });

    return {
      'firstDocument': queryData.docs.isEmpty ? null : queryData.docs.first,
      'lastDocument': queryData.docs.isEmpty ? null : queryData.docs.last,
      'messages': queryData.docs
          .map(
            (e) => ChatMessage.fromMap(
              e.data(),
            ),
          )
          .toList()
    };
  }

  static Stream<Map> streamNewMessages(
      NotificationChat chat, DocumentSnapshot<Map> lastMessageDocument) {
    Query query = FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .doc(chat.chatUID)
        .collection(CHAT_MESSAGES_COLLECTION)
        .orderBy('sendDate', descending: true);

    if (lastMessageDocument != null)
      query = query.where(
        'sendDate',
        isGreaterThan: lastMessageDocument.data()['sendDate'],
      );
    return query.snapshots().asyncMap((event) async {
      List<ChatMessage> newMessages = [];
      for (final doc in event.docs) {
        ChatMessage message = ChatMessage.fromMap(
          doc.data(),
        );
        message.sender = await UserService.getUser(message.senderID);
        newMessages.add(message);
      }

      if (newMessages.isNotEmpty) {
        final realChat = await FirebaseFirestore.instance
            .collection(CHAT_COLLECTION)
            .doc(chat.chatUID)
            .get();

        FirebaseFirestore.instance
            .collection(CHAT_COLLECTION)
            .doc(chat.chatUID)
            .update({
          CHAT_NEW_MESSAGES_KEY: {
            ...(realChat.data()[CHAT_NEW_MESSAGES_KEY] ?? {}),
            getCurrentUser().uid: 0,
          },
        });
      }

      return {
        'firstDocument': event.docs.isEmpty ? null : event.docs.first,
        'newMessages': newMessages,
      };
    });
  }

  static Future<String> sendMessage(
      NotificationChat chat, ChatMessage message) async {
    final docRef = await FirebaseFirestore.instance
        .collection(CHAT_COLLECTION)
        .doc(chat.chatUID)
        .collection(CHAT_MESSAGES_COLLECTION)
        .add(
          message.toMap(),
        );
    await docRef.update({
      'uid': docRef.id,
    });

    // await FirebaseFirestore.instance
    //     .collection(CHAT_COLLECTION)
    //     .doc(chat.chatUID)
    //     .update({
    //   CHAT_LAST_MESSAGE_KEY: message.content,
    //   CHAT_LAST_MESSAGE_DATE_KEY: DateTime.now(),
    //   CHAT_NEW_MESSAGES_KEY: {
    //     ...(chat.newMessages ?? {}),
    //     chat.usersIDs.first: (chat.newMessages[chat.usersIDs.first] ?? 0) + 1,
    //   },
    // });

    return docRef.id;
  }
}
