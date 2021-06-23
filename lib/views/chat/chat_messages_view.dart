import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/ChatMessage.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
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
    if (chat.chatUID == null)
      return setState(
        () => loading = false,
      );

    if (chat.users == null || chat.users.isEmpty) {
      List<UserModel> users = [];
      for (final userID in chat.usersIDs) {
        users.add(
          await UserService.getUser(userID),
        );
      }
      chat.users = users;
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
            chatMessages = [...chatMessages, ...olderMessages['messages']];
          });
      }
    });
  }

  _initNewMessagesSubscription() {
    newMessagesSubscription =
        MessageRepository.streamNewMessages(chat, lastMessageDocument)
            .listen((event) {
      final List messages = event['newMessages'];

      if (messages != null && messages.isNotEmpty) {
        if (mounted && messages.isNotEmpty)
          setState(() {
            newMessagesSubscription?.cancel();
            lastMessageDocument = event['firstDocument'] ?? lastMessageDocument;
            chatMessages = [...messages, ...chatMessages];
            _initNewMessagesSubscription();
          });
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
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: InkWell(
                onTap: () => Get.to(
                  () => AppPhotoView(
                    imageProvider:
                        CachedImageProvider(chat.users?.first?.photoURL ?? ''),
                  ),
                ),
                child: Image(
                  image: CachedImageProvider(chat.users?.first?.photoURL ?? ''),
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
                        return ChatMessageWidget(
                          key: Key(chatMessages[index].uid),
                          message: chatMessages[index],
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

  sendMessage() async {
    if (chat.chatUID == null) {
      print('NO CHAT UID');
      final uid = await MessageRepository.createChat(chat);
      chat.chatUID = uid;
      print(uid);
    }

    String tempUID = DateTime.now().microsecondsSinceEpoch.toRadixString(16);

    ChatMessage sentMessage = ChatMessage(
      senderID: getCurrentUser().uid,
      sendDate: DateTime.now(),
      content: messageFieldController.text,
      status: 1,
      viewed: false,
    );
    messageFieldController.clear();
    if (mounted)
      setState(() {
        chatMessages = [
          sentMessage.copyWith(uid: tempUID),
          ...chatMessages,
        ];
      });
    final uid = await MessageRepository.sendMessage(chat, sentMessage);

    final oldIndex =
        chatMessages.indexWhere((element) => element.uid == tempUID);

    chatMessages[oldIndex] = sentMessage.copyWith(
      uid: uid,
    );

    if (mounted)
      setState(() {
        chatMessages = [
          ...chatMessages,
        ];
      });
  }
}
