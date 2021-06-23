import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/models/notification/ChatMessage.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageWidget({
    Key key,
    @required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.senderID == getCurrentUser().uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                top: 8.0,
                bottom: 28.0,
              ),
              constraints: BoxConstraints(
                minWidth: 64.0,
                maxWidth: 2 * (MediaQuery.of(context).size.width - 32) / 3,
              ),
              decoration: BoxDecoration(
                color: message.senderID == getCurrentUser().uid
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: message.senderID == getCurrentUser().uid
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).textTheme.bodyText1.color,
                    ),
                textAlign: message.senderID == getCurrentUser().uid
                    ? TextAlign.right
                    : TextAlign.left,
              ),
            ),
            Positioned(
              bottom: 12,
              right: 20.0,
              child: Text(
                DateFormat('hh:mm').format(message.sendDate),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: message.senderID == getCurrentUser().uid
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).textTheme.bodyText2.color,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
