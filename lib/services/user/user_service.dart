import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

createUser() async {
  User user = getCurrentUser();
  await FirebaseFirestore.instance.collection('users').add({
    'uid': user.uid,
  });
}

User getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
