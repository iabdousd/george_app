import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/chat/chat_service.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/partner/add_partner_dialog.dart';

class TaskPartners extends StatefulWidget {
  final Task task;
  final Function(UserModel) deletePartner;
  final Function(UserModel) invitePartner;

  TaskPartners({
    Key key,
    @required this.task,
    @required this.deletePartner,
    this.invitePartner,
  }) : super(key: key);

  @override
  _TaskPartnersState createState() => _TaskPartnersState();
}

class _TaskPartnersState extends State<TaskPartners> {
  List<UserModel> partners = [];

  _init() async {
    if (widget.task?.id != null)
      for (final partnerID in widget.task.partnersIDs) {
        partners.add(await UserService.getUser(partnerID));
      }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Partners',
                style: TextStyle(
                  color: Color(0xFFB2B5C3),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddPartnerDialog(
                    object: widget.task,
                    type: PartnerInvitationType.task,
                    partners: partners,
                    invitePartner: widget.invitePartner,
                  ),
                ),
                icon: Icon(Icons.add),
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
          ListView.separated(
            itemCount: partners.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              if (index < partners.length - 1) return Divider();
              return Container();
            },
            itemBuilder: (context, index) {
              final partner = partners[index];
              return Container(
                child: Row(
                  key: Key(partner.uid),
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        image: partner.photoURL == null
                            ? null
                            : DecorationImage(
                                image: CachedImageProvider(
                                  partner.photoURL,
                                ),
                                fit: BoxFit.cover,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: partner.photoURL == null
                          ? Center(
                              child: Text(
                                partner.fullName.substring(0, 1).toUpperCase(),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        partner.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ChatService.openChatByUser(
                        context,
                        partner,
                      ),
                      icon: SvgPicture.asset('assets/images/icons/chat.svg'),
                    ),
                    IconButton(
                      onPressed: () => deletePartner(partner),
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void deletePartner(UserModel user) {
    setState(
      () => {
        partners.remove(user),
        widget.deletePartner(user),
      },
    );
  }
}
