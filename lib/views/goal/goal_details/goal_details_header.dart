import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/goal/save_goal/save_goal.dart';
import 'package:intl/intl.dart';
import 'package:mailto/mailto.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/shared/tools/contact_picker.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:stackedtasks/widgets/shared/card/app_button_card.dart';
import 'package:stackedtasks/widgets/shared/user/user_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/user.dart';

class GoalDetailsHeader extends StatefulWidget {
  final Goal goal;
  final Function(Goal) updateGoal;

  const GoalDetailsHeader({
    Key key,
    @required this.goal,
    @required this.updateGoal,
  }) : super(key: key);

  @override
  _GoalDetailsHeaderState createState() => _GoalDetailsHeaderState();
}

class _GoalDetailsHeaderState extends State<GoalDetailsHeader> {
  bool loadingPartners = true;
  List<UserModel> partners = [];
  Goal goal;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    goal = widget.goal;
    if (goal?.partnersIDs != null && goal.partnersIDs.isNotEmpty) {
      final partnersQuery = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(
            USER_UID_KEY,
            whereIn: goal.partnersIDs,
          )
          .get();
      partners = partnersQuery.docs
          .map(
            (e) => UserModel.fromMap(e.data()),
          )
          .toList();
    }
    setState(() {
      loadingPartners = false;
    });
  }

  _editGoal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveGoalPage(goal: goal),
    ).then(
      (value) {
        if (value != null && value is Goal) {
          widget.updateGoal(value);
          setState(() {
            if (partners.isNotEmpty)
              partners.removeWhere(
                (element) =>
                    value.partnersIDs.isEmpty ||
                    !value.partnersIDs.contains(element.uid),
              );
            goal = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 16.0),
      child: GestureDetector(
        onTap: () => _editGoal(context),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8.0,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 8.0,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: HexColor.fromHex(goal.color),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                  ),
                  // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/icons/calendar.svg',
                                width: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                DateFormat('EEE, d MMM yyyy')
                                        .format(goal.startDate) +
                                    ' - ' +
                                    DateFormat('EEE, d MMM yyyy')
                                        .format(goal.endDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFFB2B5C3),
                                      fontSize: 14,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // PARTNERS
                        Container(
                          padding: EdgeInsets.only(
                            top: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                child: Text(
                                  'Partners',
                                  style: TextStyle(
                                    color: Color(0xFF767C8D),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: loadingPartners
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEEEEEE),
                                            shape: BoxShape.circle,
                                          ),
                                          width: 32,
                                          height: 32,
                                          padding: EdgeInsets.all(4),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                HexColor.fromHex(
                                                  goal.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 38,
                                        child: Stack(
                                          children: [
                                            ...partners.map(
                                              (e) => Positioned(
                                                right: (partners.length -
                                                        partners.indexOf(e) -
                                                        1) *
                                                    16.0,
                                                child: InkWell(
                                                  onTap: () => openPartner(e),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .backgroundColor,
                                                        width: 3,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        32,
                                                      ),
                                                      child: e.photoURL == null
                                                          ? Container(
                                                              width: 32,
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline6
                                                                    .color
                                                                    .withOpacity(
                                                                        .25),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            32),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  e.fullName[0]
                                                                      .toUpperCase(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .backgroundColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Image(
                                                              image:
                                                                  CachedImageProvider(
                                                                e.photoURL,
                                                              ),
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addPartner() async {
    String addType;
    bool loading = false;
    List<UserModel> foundUsers = [];
    final emailFieldController = TextEditingController();

    void searchByEmail(StateSetter smallSetState) async {
      foundUsers = [];
      if (getCurrentUser().email.toLowerCase() ==
          emailFieldController.text.trim().toLowerCase()) {
        smallSetState(() {
          loading = false;
          foundUsers = [];
        });
        showFlushBar(
          title: 'Hmm..',
          message: 'You can\'t add your self as partner !',
          success: false,
        );
        return;
      }
      smallSetState(() => loading = true);
      final userQuery = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(
            USER_EMAIL_KEY,
            isEqualTo: emailFieldController.text,
          )
          .get();
      if (userQuery.size > 0) {
        final user = UserModel.fromMap(
          userQuery.docs.first.data(),
        );
        if (partners
            .where((element) => element.email == user.email)
            .isNotEmpty) {
          showFlushBar(
            title: 'Already Present',
            message:
                'The sought user is already present in your partners list.',
            success: false,
          );
          smallSetState(() {
            loading = false;
            foundUsers = [];
          });
        } else
          smallSetState(() {
            loading = false;
            foundUsers = [user];
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
                      to: [emailFieldController.text.trim().toLowerCase()],
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
        smallSetState(() {
          loading = false;
          foundUsers = [];
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, smallSetState) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Add Partner',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  height: addType != 'email' ? 0 : 178,
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ClipRect(
                    child: loading
                        ? Center(
                            child: LoadingWidget(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.email_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () => smallSetState(
                                      () {
                                        foundUsers = [];
                                        addType = null;
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Add By Email',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ],
                              ),
                              AppTextField(
                                label: 'Email',
                                controller: emailFieldController,
                                margin: EdgeInsets.zero,
                                keyboardType: TextInputType.emailAddress,
                                onSubmit: (email) => searchByEmail(
                                  smallSetState,
                                ),
                                suffix: InkWell(
                                  onTap: () => searchByEmail(smallSetState),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    child: Center(
                                      child: Icon(
                                        Icons.search,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (addType == null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 350),
                    height: addType == 'email' ? 0 : 144,
                    child: ClipRect(
                      child: AppButtonCard(
                        icon: Icon(
                          Icons.email_outlined,
                          size: 44.0,
                        ),
                        text: 'Add By Email',
                        onPressed: () => smallSetState(
                          () {
                            foundUsers = [];
                            addType = 'email';
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),

                /** --- EXTERNAL INVITATION METHODS --- **/
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  height: addType != 'phone' ? 0 : 178,
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ClipRect(
                    child: loading
                        ? Center(
                            child: LoadingWidget(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.phone_iphone_outlined,
                                      color: Colors.green[400],
                                    ),
                                    onPressed: () => smallSetState(
                                      () {
                                        foundUsers = [];
                                        addType = null;
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Add from contacts',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ],
                              ),
                              AppActionButton(
                                onPressed: () async {
                                  final List<UserModel> users =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContactPickerView(
                                        actionButtonText: 'Invite to Task',
                                      ),
                                    ),
                                  );
                                  if (users != null && users.isNotEmpty) {
                                    smallSetState(() {
                                      foundUsers = users;
                                    });
                                  }
                                },
                                backgroundColor: Colors.green[400],
                                label: 'Choose Contact',
                              ),
                            ],
                          ),
                  ),
                ),
                if (addType == null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 350),
                    height: addType == 'phone' ? 0 : 144,
                    child: ClipRect(
                      child: AppButtonCard(
                        icon: Icon(
                          Icons.phone_iphone_outlined,
                          size: 44.0,
                          color: Colors.green[400],
                        ),
                        text: 'Add from contacts',
                        onPressed: () => smallSetState(
                          () {
                            foundUsers = [];
                            addType = 'phone';
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: TextStyle(
                          color: Colors.green[400],
                        ),
                      ),
                    ),
                  ),
                if (foundUsers != null && foundUsers.isNotEmpty)
                  for (final foundUser in foundUsers)
                    UserCard(
                      user: foundUser,
                      onDelete: () => smallSetState(
                        () => foundUsers.remove(foundUser),
                      ),
                    ),
                if (!loading)
                  AppActionButton(
                    onPressed: (foundUsers != null && foundUsers.isNotEmpty)
                        ? () async {
                            Navigator.pop(context);
                            for (final foundUser in foundUsers) {
                              bool status = await NotificationRepository
                                  .addGoalNotification(
                                goal,
                                foundUser.uid,
                              );
                              if (status)
                                showFlushBar(
                                  title: 'Invitation Sent',
                                  message:
                                      '${foundUser.fullName[0].toUpperCase() + foundUser.fullName.substring(1)} has been invited to partner up in this goal with you!',
                                );
                            }
                          }
                        : addType == 'email'
                            ? () => searchByEmail(smallSetState)
                            : () => Navigator.pop(context),
                    label: foundUsers != null && foundUsers.isNotEmpty
                        ? 'Add'
                        : addType == 'email'
                            ? 'Search'
                            : 'Close',
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  openPartner(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: UserCard(
          user: user,
          onDelete: () async {
            setState(
              () => partners.remove(user),
            );
            Navigator.pop(context);
            await goal
                .copyWith(
                  partnersIDs: partners
                      .map(
                        (e) => e.uid,
                      )
                      .toList(),
                )
                .save();
          },
        ),
      ),
    );
  }
}
