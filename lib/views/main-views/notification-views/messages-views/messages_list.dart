import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/chat/chat_messages_view.dart';
import 'package:stackedtasks/views/shared/tools/contact_picker.dart';
import 'package:stackedtasks/widgets/chat/chat_list_tile.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/centered_not_found.dart';

class MessagesListView extends StatefulWidget {
  MessagesListView({Key key}) : super(key: key);

  @override
  _MessagesListViewState createState() => _MessagesListViewState();
}

class _MessagesListViewState extends State<MessagesListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: StreamBuilder<List<NotificationChat>>(
        stream: MessageRepository.getChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return AppErrorWidget();
          }

          if (snapshot.hasData) if (snapshot.data.isEmpty)
            return CenteredNotFound(
              image: 'assets/images/no_messages.svg',
              title: 'You have no new messages',
              subTitle: 'Yet 😉',
              imageWidth: MediaQuery.of(context).size.width - 58 * 2,
            );
          else
            return ListView.builder(
              itemCount: snapshot.data.length,
              padding: EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return ChatListTile(
                  chat: snapshot.data[index],
                );
              },
            );

          return LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openContacts,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).backgroundColor,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void openContacts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactPickerView(
        title: 'Contacts',
        actionButtonText: 'DONE',
        contactActionBtnText: 'Message',
        onContactClick: (user) async {
          final alreadyChat = await MessageRepository.getChatByUsers([
            user.uid,
            getCurrentUser().uid,
          ]);

          Get.to(
            () => ChatMessagesView(
              chat: alreadyChat ??
                  NotificationChat(
                    users: [
                      UserModel.fromCurrentUser(),
                      user,
                    ],
                    usersIDs: [
                      getCurrentUser().uid,
                      user.uid,
                    ],
                    lastMessage: '',
                    lastMessageDate: DateTime.now(),
                  ),
            ),
          );
        },
        selectable: false,
      ),
    ).then(
      (users) async {
        if (users != null) {}
      },
    );
  }
}
