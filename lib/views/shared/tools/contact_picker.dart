import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:flutter_contact/flutter_contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/contact/contact_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';

class ContactPickerView extends StatefulWidget {
  final String title, actionButtonText;
  final List<String> alreadyInvited;
  final bool selectable;
  final Function(UserModel) onContactClick;
  final String contactActionBtnText;
  const ContactPickerView({
    Key key,
    this.title: 'Add from contacts',
    @required this.actionButtonText,
    this.alreadyInvited: const [],
    this.selectable: true,
    this.onContactClick,
    this.contactActionBtnText: 'ADD',
  }) : super(key: key);

  @override
  _ContactPickerViewState createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  bool permissionError = false;
  List<Contact> foundContactList = [];
  List<Contact> contactList = [];
  Map<String, UserModel> selectedUsers = {};
  Map<String, UserModel> users = {};
  bool loading = true;
  CountryDetails details;

  _init() async {
    await CountryCodes.init();
    details = CountryCodes.detailsForLocale();
    await Permission.contacts.request();
    final status = await Permission.contacts.isGranted;

    if (status) {
      final contacts = Contacts.listContacts(
        bufferSize: 9999,
      );

      while (await contacts.moveNext()) {
        final contact = await contacts.current;
        // FETCH USERS BASED ON THE CONTACT
        bool contactAdded = false;
        for (final phone in contact.phones) {
          final tPhone = ContactRepository.trimPhoneNumber(phone.value);
          final user = await UserService.getContactUserByPhone(
            tPhone.startsWith('+') ? tPhone : details.dialCode + tPhone,
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
        for (final email in contact.emails) {
          final user = await UserService.getContactUserByEmail(email.value);
          if (user != null) {
            contactAdded = true;
            foundContactList.add(contact);
            users.putIfAbsent(
              user.email,
              () => user,
            );
          }
        }
        if (!contactAdded) {
          contactList.add(contact);
        }
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        permissionError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
        color: Theme.of(context).backgroundColor,
      ),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              color: Color(0xFFB2B6C3),
              width: 28,
              height: 3,
              margin: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Color(0xFFB2B6C3),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Color(0xFF767C8D),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(selectedUsers.values.toList()),
                child: Text(
                  widget.actionButtonText,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (permissionError)
            AppErrorWidget(
              customMessage: 'Contacts permission need to be granted first',
            )
          else if (loading)
            Expanded(
              child: Center(
                child: LoadingWidget(),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: foundContactList.length + contactList.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final contact = index < foundContactList.length
                      ? foundContactList[index]
                      : contactList[index - foundContactList.length];
                  bool notUser = index >= foundContactList.length;

                  final displayname = contact.displayName ?? contact.givenName;

                  if (displayname == null) {
                    return Container();
                  }

                  UserModel userModel;
                  if (!notUser) {
                    final foundPhones = contact.phones.where((element) {
                      final tPhone = ContactRepository.trimPhoneNumber(
                        element.value,
                      );
                      return users.containsKey(
                        tPhone.startsWith('+')
                            ? tPhone
                            : details.dialCode + tPhone,
                      );
                    });
                    if (foundPhones.isNotEmpty) {
                      final phone = ContactRepository.trimPhoneNumber(
                        foundPhones.first.value,
                      );
                      userModel = users[phone.startsWith('+')
                          ? phone
                          : details.dialCode + phone];
                    } else {
                      final foundEmails = contact.emails.where((element) {
                        return users.containsKey(
                          element.value.toLowerCase(),
                        );
                      });
                      if (foundEmails.isNotEmpty) {
                        final email = foundEmails.first.value;
                        userModel = users[email.toLowerCase()];
                      } else {
                        notUser = true;
                      }
                    }
                    if (userModel != null &&
                        userModel.uid == getCurrentUser().uid)
                      return Container();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == foundContactList.length || index == 0)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: (index == foundContactList.length ||
                                    (index == 0 && foundContactList.isNotEmpty))
                                ? 32.0
                                : 0.0,
                            bottom: (index == foundContactList.length ||
                                    (index == 0 && foundContactList.isNotEmpty))
                                ? 16.0
                                : 0.0,
                          ),
                          child: Text(
                            index == foundContactList.length
                                ? 'Friends that aren’t on the platform:'
                                : foundContactList.isNotEmpty
                                    ? 'Friends on the platform'
                                    : '',
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Color(0xFFB2B5C3),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 8,
                              right: 16,
                              top: 4,
                              bottom: 4,
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
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 32,
                                      height: 32,
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
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Center(
                                        child: Text(
                                          displayname[0].toUpperCase(),
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
                              displayname,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (notUser)
                            CircularActionButton(
                              onClick: () async {
                                await Share.share(
                                  'Hey. I\'m using the Stacked Tasks app to get more done. Could you please help me out by being my accountability buddy? stackedtasks.com',
                                );
                              },
                              title: 'INVITE',
                              backgroundColor: Theme.of(context).accentColor,
                            )
                          else if (widget.alreadyInvited
                              .contains(userModel.uid))
                            CircularActionButton(
                              onClick: () {},
                              title: 'ALREADY INVITED',
                              titleStyle: TextStyle(
                                color: Color(0xFFB2B5C3),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: Color(0x0CB2B5C3),
                            )
                          else if (!selectedUsers.containsKey(userModel.uid))
                            CircularActionButton(
                              onClick: widget.onContactClick != null
                                  ? () => widget.onContactClick(userModel)
                                  : () {
                                      if (!notUser)
                                        setState(() {
                                          if (selectedUsers
                                              .containsKey(userModel.uid)) {
                                            selectedUsers.remove(userModel.uid);
                                          } else {
                                            selectedUsers.putIfAbsent(
                                              userModel.uid,
                                              () => userModel,
                                            );
                                          }
                                        });
                                    },
                              title: widget.contactActionBtnText,
                              backgroundColor: Theme.of(context).accentColor,
                            )
                          else
                            CircularActionButton(
                              onClick: () {
                                if (!notUser)
                                  setState(() {
                                    if (selectedUsers
                                        .containsKey(userModel.uid)) {
                                      selectedUsers.remove(userModel.uid);
                                    } else {
                                      selectedUsers.putIfAbsent(
                                        userModel.uid,
                                        () => userModel,
                                      );
                                    }
                                  });
                              },
                              title: 'REMOVE',
                              backgroundColor: Colors.red,
                            )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
