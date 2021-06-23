import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:share/share.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/shared/tools/contact_picker.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/views/stack/stack_body_view.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_appbar.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:stackedtasks/widgets/shared/card/app_button_card.dart';
import 'package:stackedtasks/widgets/shared/user/user_card.dart';
import 'package:url_launcher/url_launcher.dart';

class StackDetailsPage extends StatefulWidget {
  final TasksStack stack;

  StackDetailsPage({
    Key key,
    @required this.stack,
  }) : super(key: key);

  @override
  _StackDetailsPageState createState() => _StackDetailsPageState();
}

class _StackDetailsPageState extends State<StackDetailsPage> {
  bool loadingPartners = true;
  List<UserModel> partners = [];

  _editStack() {
    Get.to(
      () => SaveStackPage(
        stack: widget.stack,
        goalRef: widget.stack.goalRef,
        goalColor: widget.stack.color,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  _deleteStack() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Stack',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${widget.stack.title?.toUpperCase() ?? ''}\' ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await toggleLoading(state: true);
                await widget.stack.delete();
                await toggleLoading(state: false);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    if (widget.stack?.partnersIDs != null &&
        widget.stack.partnersIDs.isNotEmpty) {
      final partnersQuery = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(
            USER_UID_KEY,
            whereIn: widget.stack.partnersIDs,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: '',
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // PARTNERS
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            child: Divider(
                              color: Colors.black26,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            height: 24,
                            child: Center(
                              child: Text('Partners'),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black26,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                ),
                                if (loadingPartners)
                                  Container(
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
                                        valueColor: AlwaysStoppedAnimation(
                                          HexColor.fromHex(
                                            widget.stack.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...partners.map(
                                    (e) => InkWell(
                                      onTap: () => openPartner(e),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          child: e.photoURL == null
                                              ? Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .color
                                                        .withOpacity(.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      e.fullName[0]
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .backgroundColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Image(
                                                  image: CachedImageProvider(
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
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).backgroundColor,
                                    Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(.9),
                                    Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(.75),
                                    Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(0),
                                  ],
                                ),
                              ),
                              child: GestureDetector(
                                onTap: addPartner,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEEEEEE),
                                    shape: BoxShape.circle,
                                  ),
                                  width: 28,
                                  height: 28,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.stack.goalRef != null)
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 4.0),
                      child: Hero(
                        tag: widget.stack.goalRef,
                        child: Text(
                          (widget.stack.goalTitle?.toUpperCase() ?? '') + ' >',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Hero(
                        tag: widget.stack.id,
                        child: Text(
                          widget.stack.title.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.headline5.copyWith(),
                        ),
                      ),
                    ),
                    AppActionButton(
                      icon: Icons.edit,
                      onPressed: _editStack,
                      backgroundColor: Theme.of(context).accentColor,
                      margin: EdgeInsets.only(left: 8, right: 4),
                    ),
                    AppActionButton(
                      icon: Icons.delete,
                      onPressed: _deleteStack,
                      backgroundColor: Colors.red,
                      margin: EdgeInsets.only(left: 4),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Expanded(
              child: StackBodyView(
                stack: widget.stack,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
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
                                  .addStackNotification(
                                widget.stack,
                                foundUser.uid,
                              );
                              if (status)
                                showFlushBar(
                                  title: 'Invitation Sent',
                                  message:
                                      '${foundUser.fullName[0].toUpperCase() + foundUser.fullName.substring(1)} has been invited to partner up in this stack with you!',
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
            await widget.stack
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
