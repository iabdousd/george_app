import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mailto/mailto.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_partner_dialog.dart';

class AddPartnerByEmailDialog extends StatefulWidget {
  final List<UserModel> partners;
  final PartnerInvitationType type;
  final dynamic object;
  final Function(UserModel) invitePartner;

  const AddPartnerByEmailDialog({
    Key key,
    @required this.partners,
    this.type,
    this.object,
    this.invitePartner,
  }) : super(key: key);

  @override
  _AddPartnerByEmailDialogState createState() =>
      _AddPartnerByEmailDialogState();
}

class _AddPartnerByEmailDialogState extends State<AddPartnerByEmailDialog> {
  UserModel foundUser;
  bool loading = false, invited = false;
  String message;
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 18.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor.withOpacity(.92),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add partner',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            if (loading)
              LoadingWidget(
                padding: EdgeInsets.all(6.0),
              )
            else if (message != null)
              Column(
                children: [
                  if (invited)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                    ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                  )
                ],
              )
            else if (foundUser == null)
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter partner\'s email',
                backgroundColor: Colors.transparent,
                border: UnderlineInputBorder(),
              )
            else
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  key: Key(foundUser.uid),
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        image: foundUser.photoURL == null
                            ? null
                            : DecorationImage(
                                image: CachedImageProvider(
                                  foundUser.photoURL,
                                ),
                                fit: BoxFit.cover,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: foundUser.photoURL == null
                          ? Center(
                              child: Text(
                                foundUser.fullName
                                    .substring(0, 1)
                                    .toUpperCase(),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        foundUser.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => foundUser = null,
                      ),
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.only(
                top: 16,
                left: 6,
                right: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(64),
              ),
              width: double.infinity,
              child: InkWell(
                onTap: message != null
                    ? Navigator.of(context).pop
                    : _searchPartner,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_rounded,
                        color: Theme.of(context).backgroundColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          message != null
                              ? 'Close'
                              : foundUser != null
                                  ? 'Invite'
                                  : 'ADD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchPartner() async {
    if (loading)
      return;
    else if (foundUser != null) {
      return _invitePartner();
    }

    if (getCurrentUser().email.toLowerCase() ==
        _emailController.text.trim().toLowerCase()) {
      setState(() {
        loading = false;
        foundUser = null;
      });
      showFlushBar(
        title: 'Hmm..',
        message: 'You can\'t add your self as partner !',
        success: false,
      );
      return;
    }
    setState(() => loading = true);
    final userQuery = await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .where(
          USER_EMAIL_KEY,
          isEqualTo: _emailController.text,
        )
        .get();
    if (userQuery.size > 0) {
      final user = UserModel.fromMap(
        userQuery.docs.first.data(),
      );
      if (widget.partners != null &&
          widget.partners
              .where((element) => element.email == user.email)
              .isNotEmpty) {
        showFlushBar(
          title: 'Already Present',
          message: 'The sought user is already present in your partners list.',
          success: false,
        );
        setState(() {
          loading = false;
          foundUser = null;
        });
      } else
        setState(() {
          loading = false;
          foundUser = user;
        });
    } else {
      await showDialog(
        context: Get.context,
        builder: (context) {
          return AlertDialog(
            title: Text('User not found'),
            content: Text(
                'The typed email doesn\'t have an account associated to it, would you like to invite them ?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.red[400],
                  ),
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final mailtoLink = Mailto(
                    to: [_emailController.text.trim().toLowerCase()],
                    subject: 'A new way to manage your time',
                    body:
                        'Hey. I\'m using the Stacked Tasks app to get more done. Could you please help me out by being my accountability buddy? stackedtasks.com',
                  );
                  await launch('$mailtoLink');
                },
                child: Text('Invite'),
              ),
            ],
          );
        },
      );
      setState(() {
        loading = false;
        foundUser = null;
      });
    }
  }

  void _invitePartner() async {
    if (widget.object?.id == null) {
      widget.invitePartner(foundUser);
      Navigator.of(context).pop();
      showFlushBar(
        title: 'Partner invitation',
        message: 'Your partner will be invited on the creation of the Task.',
      );
      return;
    }
    setState(() {
      loading = true;
    });
    bool status = widget.type == PartnerInvitationType.task
        ? await NotificationRepository.addTaskNotification(
            widget.object,
            foundUser.uid,
          )
        : widget.type == PartnerInvitationType.stack
            ? await NotificationRepository.addStackNotification(
                widget.object,
                foundUser.uid,
              )
            : await NotificationRepository.addGoalNotification(
                widget.object,
                foundUser.uid,
              );

    if (status) {
      setState(() {
        loading = false;
        invited = true;
        message =
            '${foundUser.fullName[0].toUpperCase() + foundUser.fullName.substring(1)} has been invited to partner up with you!';
      });
      Future.delayed(Duration(seconds: 3)).whenComplete(
        () => mounted ? Navigator.pop(context) : null,
      );
    } else
      setState(() {
        loading = false;
        invited = false;
        message = 'Unknown error, please try again later!';
      });
  }
}
