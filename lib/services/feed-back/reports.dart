import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

void reportAnIssue(String message) async {
  if (message.replaceAll('\n', '').trim().isNotEmpty) {
    toggleLoading(state: true);
    await FirebaseFirestore.instance.collection('reports').add({
      'reporter': FirebaseAuth.instance.currentUser.uid,
      'message': message,
      'date': DateTime.now(),
    });
    toggleLoading(state: false);
    toggleLoading(state: false);
    showFlushBar(
      title: 'Report Success',
      message:
          'Thanks for leaving reports!\nYour report was sent successfully.',
      success: true,
    );
  } else {
    showFlushBar(
      title: 'Report Issue',
      message: 'The report message is empty',
      success: false,
    );
  }
}

void sendContactMessage(String title, String body) async {
  if (body.replaceAll('\n', '').trim().isNotEmpty) {
    toggleLoading(state: true);
    await FirebaseFirestore.instance.collection('contact_messages').add({
      'sender': FirebaseAuth.instance.currentUser.uid,
      'title': title,
      'body': body,
      'date': DateTime.now(),
    });
    toggleLoading(state: false);
    toggleLoading(state: false);
    showFlushBar(
      title: 'Send Message Success',
      message: 'Thanks for contacting us!\nYour message was sent successfully.',
      success: true,
    );
  } else {
    showFlushBar(
      title: 'Send Messsage Issue',
      message: 'The message is empty',
      success: false,
    );
  }
}
