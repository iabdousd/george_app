import 'dart:convert';

import 'package:country_codes/country_codes.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/cache/contact_user.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class ContactRepository {
  static String trimPhoneNumber(String phone) =>
      (phone.startsWith('00') ? '+' + phone.substring(2) : phone)
          .replaceAll(' ', '')
          .replaceAll('-', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();

  static void syncContacts() async {
    await CountryCodes.init();
    final CountryDetails details = CountryCodes.detailsForLocale();

    List<String> alreadySyncedPhoneContacts = List<String>.from(jsonDecode(
      (await SharedPreferences.getInstance()).getString('synced_contacts') ??
          '[]',
    ));

    Map<String, Contact> contactList = {};
    await Permission.contacts.request();
    final status = await Permission.contacts.isGranted;

    if (status) {
      final contacts = Contacts.listContacts(
        bufferSize: 9999,
      );
      while (await contacts.moveNext()) {
        final contact = await contacts.current;
        for (final number in contact.phones) {
          final phone = trimPhoneNumber(number.value);
          contactList.putIfAbsent(
            phone.startsWith('+') ? phone : details.dialCode + phone,
            () => contact,
          );
        }
      }
      // FETCH USERS BASED ON THE CONTACT
      Map<String, UserModel> syncedUsers = await UserService.syncUserPhones(
        contactList.keys.toList(),
      );
      for (MapEntry<String, UserModel> syncedUser in syncedUsers.entries) {
        if (alreadySyncedPhoneContacts.contains(
          syncedUser.key,
        )) {
          alreadySyncedPhoneContacts.remove(
            syncedUser.key,
          );
        }
        await Hive.lazyBox<ContactUser>(CONTACT_USER_BOX_NAME).put(
          syncedUser.key,
          ContactUser.fromUserAndContact(
            syncedUser.value,
            contactList[syncedUser.key],
          ),
        );
      }

      // REMOVE OLDER CACH's CONTACTS WHEN THEY ARE DELETED FROM THE CONTACT LIST
      await Hive.lazyBox<ContactUser>(CONTACT_USER_BOX_NAME).deleteAll(
        alreadySyncedPhoneContacts,
      );

      await (await SharedPreferences.getInstance()).setString(
        'synced_contacts',
        jsonEncode(
          Hive.lazyBox<ContactUser>(CONTACT_USER_BOX_NAME).keys.toList(),
        ),
      );
    } else
      showFlushBar(
        title: 'Permission Error',
        message:
            'Couldn\'t fetch contacts because you didn\'t approve the permission to them !',
      );
  }
}
