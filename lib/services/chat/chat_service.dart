import 'package:flutter/material.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/chat/chat_messages_view.dart';

class ChatService {
  static void openChatByUser(BuildContext context, UserModel user) async {
    toggleLoading(state: true);
    final chat = await MessageRepository.getChatByUsers(
      [
        user.uid,
        getCurrentUser().uid,
      ],
    );
    await toggleLoading(state: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatMessagesView(
          chat: chat ??
              NotificationChat(
                usersIDs: [
                  user.uid,
                  getCurrentUser().uid,
                ],
              ),
        ),
      ),
    );
  }
}
