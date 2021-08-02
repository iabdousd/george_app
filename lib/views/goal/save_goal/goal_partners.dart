import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/partner/add_partner_dialog.dart';

class GoalPartners extends StatefulWidget {
  final Goal goal;
  final Function(UserModel) deletePartner;

  GoalPartners({
    Key key,
    @required this.goal,
    @required this.deletePartner,
  }) : super(key: key);

  @override
  _GoalPartnersState createState() => _GoalPartnersState();
}

class _GoalPartnersState extends State<GoalPartners> {
  List<UserModel> partners = [];

  _init() async {
    for (final partnerID in widget.goal.partnersIDs) {
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
                    object: widget.goal,
                    type: PartnerInvitationType.goal,
                    partners: partners,
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
                      onPressed: () => deletePartner(partner),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    )
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
