import 'package:flutter/material.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/views/shared/tools/contact_picker.dart';

import 'partner_by_email_dialog.dart';

enum PartnerInvitationType {
  task,
  stack,
  goal,
}

class AddPartnerDialog extends StatelessWidget {
  final List<UserModel> partners;
  final PartnerInvitationType type;
  final dynamic object;
  final Function(UserModel) invitePartner;

  const AddPartnerDialog({
    Key key,
    this.partners,
    this.type,
    this.object,
    this.invitePartner,
  }) : super(key: key);

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
            Container(
              margin: EdgeInsets.only(
                top: 16,
                bottom: 10,
                left: 6,
                right: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(64),
              ),
              width: double.infinity,
              child: InkWell(
                onTap: () => addByEmail(context),
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
                          'ADD BY EMAIL',
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
            Container(
              margin: EdgeInsets.only(
                left: 6,
                right: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(64),
              ),
              width: double.infinity,
              child: InkWell(
                onTap: () => addFromContacts(context),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_iphone_rounded,
                        color: Theme.of(context).backgroundColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          'ADD FROM CONTACTS',
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

  void addByEmail(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => AddPartnerByEmailDialog(
        partners: partners,
        type: type,
        object: object,
        invitePartner: invitePartner,
      ),
    );
  }

  void addFromContacts(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactPickerView(
        actionButtonText: 'DONE',
        alreadyInvited: partners.map((e) => e.uid).toList(),
      ),
    ).then((users) async {
      if (users != null && users is List<UserModel>) {
        if (object?.id == null) {
          for (final foundUser in users) {
            invitePartner(foundUser);
          }
          showFlushBar(
            title: 'Partner invitation',
            message:
                'Your partner will be invited on the creation of the Task.',
          );
          return;
        }
        int successCount = users.length;
        for (final foundUser in users) {
          bool res = type == PartnerInvitationType.task
              ? await NotificationRepository.addTaskNotification(
                  object,
                  foundUser.uid,
                )
              : type == PartnerInvitationType.stack
                  ? await NotificationRepository.addStackNotification(
                      object,
                      foundUser.uid,
                    )
                  : await NotificationRepository.addGoalNotification(
                      object,
                      foundUser.uid,
                    );
          if (!res) {
            successCount--;
          }
        }
        if (successCount > 0)
          showFlushBar(
            title: 'Success',
            message: 'Successfully invited $successCount partner(s)',
          );
      }
    });
  }
}
