import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/UserModel.dart';

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
}
