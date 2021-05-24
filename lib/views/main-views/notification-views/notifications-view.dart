import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Notification.dart' as notification_model;
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/notification/notification_list_tile.dart';

class NotificationsView extends StatefulWidget {
  NotificationsView({Key key}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<notification_model.Notification>>(
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
          ),
        ],
      ),
    );
  }
}
