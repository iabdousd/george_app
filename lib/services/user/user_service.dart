import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future createUser() async {
  await Firebase.initializeApp();
  if (getCurrentUser() != null) return;
  UserCredential user = await FirebaseAuth.instance.signInAnonymously();
  await FirebaseFirestore.instance.collection('users').doc(user.user.uid).set({
    'uid': user.user.uid,
  });
}

User getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
