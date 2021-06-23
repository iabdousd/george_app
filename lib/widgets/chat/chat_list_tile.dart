import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/chat/chat_messages_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';

class ChatListTile extends StatelessWidget {
  final NotificationChat chat;
  final bool popFirst;
  const ChatListTile({
    Key key,
    @required this.chat,
    this.popFirst: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUser = chat.users.first;

    return GestureDetector(
      onTap: clickEvent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(128),
                    child: Image(
                      image: CachedImageProvider(
                        otherUser.photoURL,
                      ),
                      fit: BoxFit.cover,
                      width: chat.lastMessage != null ? 64 : 40,
                      height: chat.lastMessage != null ? 64 : 40,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: chat.lastMessage != null ? 0 : 6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUser.fullName,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                if (chat.lastMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 24.0,
                                    ),
                                    child: Text(
                                      chat.lastMessage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(fontSize: 12),
                                      maxLines: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (chat.newMessages != null &&
                            chat.newMessagesForUser(getCurrentUser().uid) > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            width: 24,
                            height: 24,
                            child: Center(
                              child: Text(
                                chat.newMessagesForUser(getCurrentUser().uid) <
                                        10
                                    ? chat
                                        .newMessagesForUser(
                                            getCurrentUser().uid)
                                        .toString()
                                    : '+9',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      color: Theme.of(context).backgroundColor,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (chat.lastMessageDate != null)
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Text(
                  timeago.format(chat.lastMessageDate),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 12.0,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void clickEvent() async {
    if (popFirst) Get.back();
    if (chat.chatUID == null) {
      final alreadyChat = await MessageRepository.getChatByUsers(
        chat.usersIDs,
      );

      print('NO CHAT UID: ${chat.toMap()}');

      Get.to(
        () => ChatMessagesView(
          chat: alreadyChat ?? chat,
        ),
      );
    } else
      Get.to(
        () => ChatMessagesView(
          chat: chat,
        ),
      );
  }
}
