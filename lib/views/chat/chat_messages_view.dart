import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/ChatMessage.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/user/user_profile.dart';
import 'package:stackedtasks/widgets/chat/chat_message_widget.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

class ChatMessagesView extends StatefulWidget {
  final NotificationChat chat;
  ChatMessagesView({
    Key key,
    @required this.chat,
  }) : super(key: key);

  @override
  _ChatMessagesViewState createState() => _ChatMessagesViewState();
}

class _ChatMessagesViewState extends State<ChatMessagesView> {
  NotificationChat chat;
  final messageFieldController = TextEditingController();
  StreamSubscription newMessagesSubscription;

  DocumentSnapshot beforeDocument, lastMessageDocument;
  List<ChatMessage> chatMessages = [];
  bool loading = true;
  final messagesScrollController = ScrollController();

  _init() async {
    chat = widget.chat;
    if (chat.chatUID == null) {
      if (chat.users == null || chat.users.isEmpty) {
        List<UserModel> users = [];
        for (final userID in chat.usersIDs) {
          users.add(
            await UserService.getUser(userID),
          );
        }
        chat.users = users;
      }

      return setState(
        () => loading = false,
      );
    }
    if (chat.users == null || chat.users.isEmpty) {
      List<UserModel> users = [];
      for (final userID in chat.usersIDs) {
        users.add(
          await UserService.getUser(userID),
        );
      }
      setState(() {
        chat.users = users;
      });
    }

    final chatMessagesQuery = await MessageRepository.getChatMessages(chat);

    if (mounted)
      setState(() {
        lastMessageDocument =
            chatMessagesQuery['firstDocument'] ?? lastMessageDocument;
        beforeDocument = chatMessagesQuery['lastDocument'] ?? beforeDocument;
        chatMessages = chatMessagesQuery['messages'];
        loading = false;
      });

    _initNewMessagesSubscription();

    messagesScrollController.addListener(() async {
      if (messagesScrollController.position.atEdge &&
          messagesScrollController.position.pixels != 0) {
        final olderMessages = await MessageRepository.getChatMessages(
          chat,
          beforeDocument,
        );
        if (mounted)
          setState(() {
            lastMessageDocument =
                olderMessages['firstDocument'] ?? lastMessageDocument;
            beforeDocument = olderMessages['lastDocument'] ?? beforeDocument;
            addMessages(
              olderMessages['messages'],
              false,
            );
          });
      }
    });
  }

  _initNewMessagesSubscription() {
    newMessagesSubscription =
        MessageRepository.streamNewMessages(chat, lastMessageDocument)
            .listen((event) async {
      final List messages = event['newMessages'];
      if (mounted) {
        chat = (await MessageRepository.emitChatSeen(chat)).copyWith(
          users: chat.users,
        );
      }
      if (messages != null && messages.isNotEmpty) {
        if (mounted && messages.isNotEmpty) {
          setState(() {
            newMessagesSubscription?.cancel();
            lastMessageDocument = event['firstDocument'] ?? lastMessageDocument;
            addMessages(messages, true);
            _initNewMessagesSubscription();
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    newMessagesSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Get.to(
            () => UserProfileView(
              user: chat.users?.first,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: InkWell(
                  onTap: () => Get.to(
                    () => AppPhotoView(
                        imageProvider: CachedImageProvider(
                      chat.users?.first?.photoURL ?? '',
                    )),
                    transition: Transition.downToUp,
                  ),
                  child: Image(
                    image:
                        CachedImageProvider(chat.users?.first?.photoURL ?? ''),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  chat.users?.first?.fullName ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatMessages.isEmpty
                  ? Center(
                      child: loading
                          ? LoadingWidget()
                          : Text('Be the first one to send message !'),
                    )
                  : ListView.builder(
                      controller: messagesScrollController,
                      itemCount: chatMessages.length,
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            if (index == chatMessages.length - 1 ||
                                (chatMessages[index].sendDate.day !=
                                    chatMessages[index + 1].sendDate.day))
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 24,
                                ),
                                child: Text(
                                  DateTime(
                                            chatMessages[index].sendDate.year,
                                            chatMessages[index].sendDate.month,
                                            chatMessages[index].sendDate.day,
                                          ) ==
                                          DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                          )
                                      ? 'Today'
                                      : DateFormat(
                                          chatMessages[index].sendDate.isAfter(
                                                    DateTime.now().subtract(
                                                      Duration(days: 7),
                                                    ),
                                                  )
                                              ? 'EEEE'
                                              : 'dd/MM/yyyy',
                                        ).format(chatMessages[index].sendDate),
                                  style: TextStyle(
                                    color: Color(0xFF767C8D),
                                  ),
                                ),
                              ),
                            ChatMessageWidget(
                              key: Key(chatMessages[index].uid),
                              message: chatMessages[index],
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: messageFieldController,
                        margin: EdgeInsets.only(
                          left: 16.0,
                          bottom: 8.0,
                          top: 8.0,
                        ),
                        label: null,
                        hint: 'Type your message here',
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: Icon(Icons.send_rounded),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addMessages(
    List<ChatMessage> messages,
    bool newMessages,
  ) {
    for (final message in messages) {
      final oldMessage =
          chatMessages.where((element) => element.uid == message.uid);
      if (oldMessage.isNotEmpty) {
        chatMessages[chatMessages.indexOf(oldMessage.first)] = message;
      } else if (newMessages) {
        chatMessages = [
          message,
          ...chatMessages,
        ];
      } else {
        chatMessages = [
          ...chatMessages,
          message,
        ];
      }
    }
    if (mounted) setState(() {});
  }

  sendMessage() async {
    if (chat.chatUID == null) {
      final uid = await MessageRepository.createChat(chat);
      chat.chatUID = uid;
    }

    ChatMessage sentMessage = ChatMessage(
      senderID: getCurrentUser().uid,
      sendDate: DateTime.now(),
      content: messageFieldController.text,
      status: 1,
      viewed: false,
    );
    messageFieldController.clear();

    final uid = await MessageRepository.sendMessage(chat, sentMessage);

    addMessages(
      [
        sentMessage.copyWith(
          uid: uid,
        )
      ],
      true,
    );
  }
}
