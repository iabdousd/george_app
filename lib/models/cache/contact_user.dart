import 'package:flutter_contact/contacts.dart';
import 'package:hive/hive.dart';
import 'package:stackedtasks/models/UserModel.dart';

part 'contact_user.g.dart';

const String CONTACT_USER_BOX_NAME = 'CONTACT_USER_BOX';

@HiveType(typeId: 1)
class ContactUser extends HiveObject {
  @HiveField(0)
  String userId;
  @HiveField(1)
  String userName;
  @HiveField(2)
  String contactName;
  @HiveField(3)
  String userEmail;
  @HiveField(4)
  String userPhone;
  @HiveField(5)
  List<String> contactPhones;
  @HiveField(6)
  String userPhotoURL;

  ContactUser({
    this.userId,
    this.userName,
    this.contactName,
    this.userEmail,
    this.userPhone,
    this.contactPhones,
    this.userPhotoURL,
  });

  ContactUser.fromUserAndContact(UserModel user, Contact contact) {
    this.userId = user.uid;
    this.userName = user.fullName;
    this.contactName = contact.displayName;
    this.userEmail = user.email;
    this.userPhone = user.phoneNumber;
    this.contactPhones = contact.phones.map((e) => e.value).toList();
    this.userPhotoURL = user.photoURL;
  }
}
