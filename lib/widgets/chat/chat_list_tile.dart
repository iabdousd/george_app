import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/chat/chat_messages_view.dart';

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
    final now = DateTime.now();

    return GestureDetector(
      onTap: clickEvent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        padding: EdgeInsets.all(12.0),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(128),
                    child: Image(
                      image: CachedImageProvider(
                        otherUser.photoURL,
                      ),
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
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
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        otherUser.fullName,
                                        style: TextStyle(
                                          color: Color(0xFF3B404A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (chat.lastMessageDate != null &&
                                        chat.lastMessageSenderID ==
                                            getCurrentUser().uid)
                                      if ((chat.lastMessageSeen ?? false))
                                        Icon(
                                          Icons.done_all,
                                          size: 14,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      else
                                        Icon(
                                          Icons.done,
                                          size: 14,
                                        ),
                                    if (chat.lastMessageDate != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          (chat.lastMessageDate.isAfter(
                                            now.subtract(
                                              Duration(days: 1),
                                            ),
                                          )
                                                  ? DateFormat('hh:mm')
                                                  : chat.lastMessageDate
                                                          .isAfter(
                                                      now.subtract(
                                                        Duration(days: 7),
                                                      ),
                                                    )
                                                      ? DateFormat('EEEE')
                                                      : DateFormat(
                                                          'MM/dd/yyyy'))
                                              .format(chat.lastMessageDate),
                                          style: TextStyle(
                                            color: Color(0xFF767C8D),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (chat.lastMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2.0,
                                    ),
                                    child: Text(
                                      chat.lastMessage,
                                      style: TextStyle(
                                        color: Color(0xFF767C8D),
                                        fontSize: 14,
                                      ),
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
