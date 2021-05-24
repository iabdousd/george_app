import 'dart:convert';

import 'package:stackedtasks/constants/user.dart';

class UserModel {
  String uid;
  String fullName;
  String photoURL;
  String phoneNumber;
  String email;
  UserModel({
    this.uid,
    this.fullName,
    this.photoURL,
    this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      USER_UID_KEY: uid,
      USER_FULL_NAME_KEY: fullName,
      USER_PROFILE_PICTURE_KEY: photoURL,
      USER_PHONE_NUMBER_KEY: phoneNumber,
      USER_EMAIL_KEY: email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[USER_UID_KEY],
      fullName: map[USER_FULL_NAME_KEY],
      photoURL: map[USER_PROFILE_PICTURE_KEY],
      phoneNumber: map[USER_PHONE_NUMBER_KEY],
      email: map[USER_EMAIL_KEY],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
