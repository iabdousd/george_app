import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/models/cache/contact_user.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';

Future<bool> checkAuthorization() async {
  await Firebase.initializeApp();
  User user = FirebaseAuth.instance.currentUser;
  if (user != null)
    await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(user.uid)
        .update({
      USER_UID_KEY: user.uid,
      USER_FULL_NAME_KEY: user.displayName,
      USER_PHONE_NUMBER_KEY: user.phoneNumber,
      USER_EMAIL_KEY: user.email.trim().toLowerCase(),
      USER_PROFILE_PICTURE_KEY: user.photoURL,
    });

  return user != null && !user.isAnonymous;
}

User getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}

class UserService {
  static Map<String, UserModel> users = {};

  static Future<UserModel> fetchUser(String uid) async {
    final userRaw =
        await FirebaseFirestore.instance.collection(USERS_KEY).doc(uid).get();
    if (userRaw.exists) {
      return UserModel.fromMap(
        userRaw.data(),
      );
    }
    return null;
  }

  static Future<UserModel> fetchUserByPhone(String phone) async {
    final userRaw = await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .where(
          USER_PHONE_NUMBER_KEY,
          isEqualTo: phone,
        )
        .get();
    if (userRaw.size > 0) {
      print(userRaw.docs);
      return UserModel.fromMap(
        userRaw.docs.first.data(),
      );
    }
    return null;
  }

  static Future<UserModel> getUser(String uid) async {
    if (users.containsKey(uid)) {
      return users[uid];
    } else {
      final user = await fetchUser(uid);
      users.putIfAbsent(
        uid,
        () => user,
      );
      return user;
    }
  }

  static Future<UserModel> getUserByPhone(String phone) async {
    final sameUsers =
        users.values.where((element) => element.phoneNumber == phone);
    if (sameUsers.isNotEmpty) {
      return sameUsers.first;
    } else {
      final user = await fetchUserByPhone(phone);
      if (user != null)
        users.putIfAbsent(
          user.uid,
          () => user,
        );
      return user;
    }
  }

  static Future<UserModel> getContactUserByPhone(String phone) async {
    final user =
        await Hive.lazyBox<ContactUser>(CONTACT_USER_BOX_NAME).get(phone);
    if (user != null) {
      return UserModel(
        uid: user.userId,
        email: user.userEmail,
        fullName: user.userName,
        phoneNumber: user.userPhone,
        photoURL: user.userPhotoURL,
      );
    }
    return null;
  }

  static Future<Map<String, UserModel>> syncUserPhones(
      List<String> phones) async {
    Map<String, UserModel> syncedMap = {};
    for (final phone in phones) {
      final sameUsers =
          users.values.where((element) => element.phoneNumber == phone);
      if (sameUsers.isNotEmpty) {
        syncedMap.putIfAbsent(phone, () => sameUsers.first);
      }
    }
    final restPhones =
        phones.where((element) => !syncedMap.containsKey(element)).toList();

    final subDivisions = List.generate(
      restPhones.length ~/ 10 + 1,
      (index) => restPhones.sublist(
        index * 10,
        min(restPhones.length, (index + 1) * 10),
      ),
    );

    for (final subPhonesList in subDivisions) {
      final query = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(USER_PHONE_NUMBER_KEY, whereIn: subPhonesList)
          .get();
      if (query.size > 0) {
        for (final user in query.docs.map(
          (e) => UserModel.fromMap(
            e.data(),
          ),
        )) {
          syncedMap.putIfAbsent(
            user.phoneNumber,
            () => user,
          );
        }
      }
    }
    return syncedMap;
  }

  static Stream<int> countUserFollowing(String uid) {
    return FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(uid)
        .snapshots()
        .map(
          (event) => event.data()[USER_FOLLOWERS_KEY],
        );
  }

  static Stream<int> countUserFollowers(String uid) {
    return FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(uid)
        .snapshots()
        .map(
          (event) => event.data()[USER_FOLLOWING_KEY],
        );
  }

  static Future<void> followUser(UserModel user) async {
    assert(user?.uid != null);

    if (user.uid == getCurrentUser().uid) {
      showFlushBar(
        title: 'Hmmm..',
        message: 'Unfortunately, you cannot follow your self !',
        success: false,
      );
      return;
    }

    final followDoc = await FirebaseFirestore.instance
        .collection(USER_FOLLOWERS_COLLECTION)
        .doc(getCurrentUser().uid + '_TO_' + user.uid)
        .get();
    final oldUser = await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(user.uid)
        .get();

    if (followDoc.exists && followDoc.data() != null) {
      await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .doc(user.uid)
          .update({
        USER_FOLLOWERS_KEY:
            min(0, (oldUser.data()[USER_FOLLOWERS_KEY] ?? 0) - 1),
      });
      await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .doc(getCurrentUser().uid)
          .update({
        USER_FOLLOWING_KEY:
            min(0, (oldUser.data()[USER_FOLLOWING_KEY] ?? 0) - 1),
      });
      await followDoc.reference.delete();
      showFlushBar(
        title: 'Unfollowed',
        message: 'Successfully unfollowed ${user.fullName}',
      );
    } else {
      await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .doc(user.uid)
          .update({
        USER_FOLLOWERS_KEY: (oldUser.data()[USER_FOLLOWERS_KEY] ?? 0) + 1,
      });
      await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .doc(getCurrentUser().uid)
          .update({
        USER_FOLLOWING_KEY: (oldUser.data()[USER_FOLLOWING_KEY] ?? 0) + 1,
      });

      await followDoc.reference.set({
        USER_FOLLOW_DATE_KEY: Timestamp.now(),
        USER_FOLLOWER_KEY: getCurrentUser().uid,
        USER_FOLLOWED_KEY: user.uid,
      });

      showFlushBar(
        title: 'Followed',
        message: 'Successfully followed ${user.fullName}',
      );
    }
  }

  static Stream<bool> streamIsFollowed(UserModel user) {
    return FirebaseFirestore.instance
        .collection(USER_FOLLOWERS_COLLECTION)
        .doc(getCurrentUser().uid + '_TO_' + user.uid)
        .snapshots()
        .map(
          (event) => event.exists && event.data() != null,
        );
  }
}
