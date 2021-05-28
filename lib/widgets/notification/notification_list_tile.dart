import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Notification.dart' as app_notification;
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class NotificationListTile extends StatelessWidget {
  final app_notification.Notification notification;

  const NotificationListTile({
    Key key,
    @required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loading = false;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notification.sender.fullName + ' Invited you to join',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            notification is app_notification.TaskInvitationNotification
                ? (notification as app_notification.TaskInvitationNotification)
                    .taskTitle
                : notification
                        is app_notification.TasksStackInvitationNotification
                    ? (notification as app_notification
                            .TasksStackInvitationNotification)
                        .stackTitle
                    : notification
                            is app_notification.GoalInvitationNotification
                        ? (notification
                                as app_notification.GoalInvitationNotification)
                            .goalTitle
                        : '',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 16),
          StatefulBuilder(builder: (context, setState) {
            return Row(
              children: [
                Expanded(
                  child: AppActionButton(
                    loading: loading,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Are you sure to decline the invitation ?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async => {
                              setState(
                                () => loading = true,
                              ),
                              Navigator.pop(context),
                              await NotificationRepository
                                  .declineInviteNotification(
                                notification.id,
                              ).then((value) {
                                if (!value) {
                                  setState(
                                    () => loading = false,
                                  );
                                  showFlushBar(
                                    title: 'Error',
                                    message:
                                        'Couldn\'t decline this invitation, please try again later !',
                                    success: false,
                                  );
                                } else {
                                  showFlushBar(
                                    title: 'Success',
                                    message:
                                        'Successfully declined this invitation !',
                                  );
                                }
                              }),
                            },
                            child: Text('Decline'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.red[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    label: 'Decline',
                    backgroundColor: Colors.red[400],
                    shadows: [],
                    margin: EdgeInsets.zero,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppActionButton(
                    loading: loading,
                    onPressed: () async => {
                      setState(
                        () => loading = true,
                      ),
                      await NotificationRepository.acceptInvitationNotification(
                        notification,
                        notification.type,
                      ).then(
                        (value) {
                          if (!value) {
                            setState(
                              () => loading = false,
                            );
                            showFlushBar(
                              title: 'Error',
                              message:
                                  'Couldn\'t accept this invitation, please try again later !',
                              success: false,
                            );
                          } else {
                            showFlushBar(
                              title: 'Success',
                              message:
                                  'Successfully accepted this invitation !',
                            );
                          }
                        },
                      )
                    },
                    label: 'Accept',
                    shadows: [],
                    margin: EdgeInsets.zero,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
