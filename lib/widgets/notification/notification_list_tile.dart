import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:stackedtasks/config/fcm.dart';
import 'package:stackedtasks/models/InvitationNotification.dart';
import 'package:stackedtasks/models/notification/notification.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';

class NotificationListTile extends StatefulWidget {
  final NotificationModel notification;

  const NotificationListTile({
    Key key,
    @required this.notification,
  }) : super(key: key);

  @override
  _NotificationListTileState createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: 0.15,
        child: GestureDetector(
          onTap: () => notificationClickEvent(
            widget.notification.action,
            widget.notification.data,
            false,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                      width: 42,
                      height: 42,
                      image: widget.notification.icon == null ||
                              widget.notification.icon.isEmpty
                          ? AssetImage(
                              'assets/images/icons/no_notification_icon.png',
                            )
                          : CachedImageProvider(
                              widget.notification.icon,
                            ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.notification.title,
                              style: TextStyle(
                                color: Color(0xFF3B404A),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(widget.notification.creationDate),
                            style: TextStyle(
                              color: Color(0xAA767C8D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.notification.body,
                        style: TextStyle(
                          color: Color(0xFF767C8D),
                          fontSize: 12,
                        ),
                      ),
                      if (widget.notification is InvitationNotification)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CircularActionButton(
                                  loading: loading,
                                  onClick: _declineInvitation,
                                  title: 'Decline',
                                  backgroundColor: Colors.red[400],
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CircularActionButton(
                                  loading: loading,
                                  onClick: _acceptInvitation,
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  title: 'Accept',
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  margin: EdgeInsets.zero,
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
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            iconWidget: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  color: Colors.red,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).backgroundColor,
                    size: 24.0,
                  ),
                );
              },
            ),
            closeOnTap: true,
            onTap: _deleteNotification,
          ),
        ],
      ),
    );
  }

  void _deleteNotification() async {
    toggleLoading(state: true);
    NotificationRepository.deleteNotification(widget.notification);
    toggleLoading(state: false);
  }

  void _acceptInvitation() async => {
        setState(
          () => loading = true,
        ),
        await NotificationRepository.acceptInvitationNotification(
          widget.notification,
          widget.notification.action,
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
                message: 'Successfully accepted this invitation !',
              );
            }
          },
        )
      };

  void _declineInvitation() => showDialog(
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
                await NotificationRepository.declineInviteNotification(
                  widget.notification.uid,
                ).then((value) {
                  if (value == null) return;
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
                      message: 'Successfully declined this invitation !',
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
      );
}
