import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Notification.dart' as notification_model;
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/main-views/notification-views/messages-views/messages_list.dart';
import 'package:stackedtasks/widgets/notification/notification_list_tile.dart';

class NotificationsView extends StatefulWidget {
  NotificationsView({Key key}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                bottom: 8.0,
              ),
              child: TabBar(
                labelStyle: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor:
                    Theme.of(context).textTheme.headline6.color,
                tabs: [
                  Tab(
                    text: 'Notifications',
                  ),
                  Tab(
                    text: 'Messages',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<List<notification_model.Notification>>(
                    stream: NotificationRepository.streamNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) if (snapshot.data.isEmpty)
                        return Center(
                          child: Text('You have no new notifications.'),
                        );
                      else
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8,
                          ),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            final notification = snapshot.data[index];
                            return NotificationListTile(
                              notification: notification,
                            );
                          },
                        );

                      return LoadingWidget();
                    },
                  ),
                  MessagesListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
