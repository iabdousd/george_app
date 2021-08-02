import 'package:flutter/material.dart';

import 'package:stackedtasks/models/notification/notification.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/notification/notification_list_tile.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/centered_not_found.dart';

class NotificationsListView extends StatelessWidget {
  const NotificationsListView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationRepository.streamNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) if (snapshot.data.isEmpty)
          return CenteredNotFound(
            image: 'assets/images/no_notifications.svg',
            title: 'You have no new notifications',
            subTitle: 'Yet 😉',
          );
        else
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
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
    );
  }
}
