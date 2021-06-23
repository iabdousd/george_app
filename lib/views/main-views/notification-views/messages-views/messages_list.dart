import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/notification/NotificationChat.dart';
import 'package:stackedtasks/repositories/notification/message_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/chat/chat_list_tile.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

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
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<List<NotificationChat>>(
        stream: StreamZip(
            [MessageRepository.getChats(), UserService.getUserFollowing()]).map(
          (event) => [
            ...event[0],
            ...(event[1]
                .where(
                  (e) => (event[0] as List<NotificationChat>)
                      .where((element) =>
                          element.usersIDs.contains((e as UserModel).uid))
                      .isEmpty,
                )
                .map(
                  (userModel) => NotificationChat(
                    usersIDs: [
                      (userModel as UserModel).uid,
                      getCurrentUser().uid,
                    ],
                    users: [
                      userModel as UserModel,
                      UserModel.fromCurrentUser(),
                    ],
                    newMessages: {},
                    lastMessage: '',
                  ),
                )
                .toList())
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return AppErrorWidget();
          }

          if (snapshot.hasData) if (snapshot.data.isEmpty)
            return Center(
              child: Text('You have no new messages.'),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: newChat,
      //   child: Icon(Icons.add),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   foregroundColor: Theme.of(context).backgroundColor,
      // ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void newChat() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(Icons.close),
                    ),
                    Text(
                      'Start Chat',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: UserService.getUserFollowing(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) if (snapshot.data.isEmpty)
                      return Center(
                        child: Text('You have no contacts'),
                      );
                    else
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        padding: EdgeInsets.all(16.0),
                        itemBuilder: (context, index) {
                          return ChatListTile(
                            popFirst: true,
                            chat: NotificationChat(
                              usersIDs: [
                                snapshot.data[index].uid,
                                getCurrentUser().uid,
                              ],
                              users: [
                                snapshot.data[index],
                                UserModel.fromCurrentUser(),
                              ],
                            ),
                          );
                        },
                      );
                    return LoadingWidget();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
