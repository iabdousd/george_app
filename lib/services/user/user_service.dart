import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stackedtasks/constants/user.dart';

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
      USER_EMAIL_KEY: user.email,
      USER_PROFILE_PICTURE_KEY: user.photoURL,
    });

  return user != null && !user.isAnonymous;
}

User getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
