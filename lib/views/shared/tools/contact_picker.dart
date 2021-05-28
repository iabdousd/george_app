import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:flutter_contact/flutter_contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class ContactPickerView extends StatefulWidget {
  final String actionButtonText;
  const ContactPickerView({
    Key key,
    @required this.actionButtonText,
  }) : super(key: key);

  @override
  _ContactPickerViewState createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  List<Contact> foundContactList = [];
  List<Contact> contactList = [];
  List<UserModel> selectedUsers = [];
  Map<String, UserModel> users = {};
  bool loading = true;

  _init() async {
    await Permission.contacts.request();
    final status = await Permission.contacts.isGranted;

    if (status) {
      final contacts = Contacts.listContacts(
        bufferSize: 9999,
      );
      // TODO:
      while (await contacts.moveNext()) {
        final contact = await contacts.current;
        // FETCH USERS BASED ON THE CONTACT
        bool contactAdded = false;
        for (final phone in contact.phones) {
          final user = await UserService.getContactUserByPhone(
            phone.value.replaceAll(' ', '').trim(),
          );
          if (user != null) {
            contactAdded = true;
            foundContactList.add(contact);
            users.putIfAbsent(
              user.phoneNumber,
              () => user,
            );
          }
        }
        if (!contactAdded) {
          contactList.add(contact);
        }
      }
      print(foundContactList.length);
      print(contactList.length);
      setState(() {
        loading = false;
      });
    } else
      showFlushBar(
        title: 'Permission Error',
        message:
            'Couldn\'t fetch contacts because you didn\'t approve the permission to them !',
      );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add By Phone',
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 65,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.black26,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (selectedUsers.isEmpty)
                      Text(
                        'Nothing is selected',
                      )
                    else
                      for (final user in selectedUsers)
                        FadeIn(
                          duration: Duration(milliseconds: 350),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 4,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            margin: EdgeInsets.only(right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 8,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: user.photoURL != null
                                        ? Image(
                                            image: CachedImageProvider(
                                              user.photoURL,
                                            ),
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(.75),
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            child: Center(
                                              child: Text(
                                                user.fullName[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Text(
                                  user.fullName,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: InkWell(
                                      onTap: () => setState(
                                            () => selectedUsers.remove(user),
                                          ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            if (loading)
              Expanded(
                child: Center(
                  child: LoadingWidget(),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: foundContactList.length + contactList.length,
                  itemBuilder: (context, index) {
                    final contact = index < foundContactList.length
                        ? foundContactList[index]
                        : contactList[index - foundContactList.length];
                    final notUser = index >= foundContactList.length;

                    final userModel = notUser
                        ? null
                        : users[contact.phones
                            .where((element) => users
                                .containsKey(element.value.replaceAll(' ', '')))
                            .first
                            .value
                            .replaceAll(' ', '')];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == foundContactList.length)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 12.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              'Friends that aren\'t on the Platform:',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                            ),
                          ),
                        InkWell(
                          onTap: () {
                            if (!notUser)
                              setState(() {
                                if (selectedUsers.contains(userModel))
                                  selectedUsers.remove(userModel);
                                else
                                  selectedUsers.add(userModel);
                              });
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(44),
                                  child: userModel?.photoURL != null ||
                                          contact.avatar != null
                                      ? Image(
                                          image: userModel?.photoURL != null
                                              ? CachedImageProvider(
                                                  userModel.photoURL,
                                                )
                                              : MemoryImage(contact.avatar),
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: notUser
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .color
                                                    .withOpacity(.25)
                                                : Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(.75),
                                            borderRadius:
                                                BorderRadius.circular(32),
                                          ),
                                          child: Center(
                                            child: Text(
                                              contact.displayName[0]
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  contact.displayName,
                                ),
                              ),
                              if (notUser)
                                AppActionButton(
                                  onPressed: () async {
                                    await Share.share(
                                      'Hey. I\'m using the Stacked Tasks app to get more done. Could you please help me out by being my accountability buddy? stackedtasks.com',
                                    );
                                  },
                                  label: 'Invite',
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.5),
                                )
                              else if (selectedUsers.contains(userModel))
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            AppActionButton(
              onPressed: () => Navigator.of(context).pop(selectedUsers),
              label: widget.actionButtonText,
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
