import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plandoraslist/services/feed-back/flush_bar.dart';
import 'package:plandoraslist/services/feed-back/loader.dart';
import 'package:plandoraslist/widgets/shared/app_action_button.dart';
import 'package:plandoraslist/widgets/shared/app_text_field.dart';

_updateEmail(String email, String password) async {
  if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email)) {
    showFlushBar(
      title: 'Malformed email',
      message: 'Please make sure of the format of your email.',
      success: false,
    );
    return;
  }
  toggleLoading(state: true);
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: FirebaseAuth.instance.currentUser.email,
      password: password,
    );
    await FirebaseAuth.instance.currentUser.updateEmail(email);
    await FirebaseAuth.instance.currentUser.sendEmailVerification();
    toggleLoading(state: false);
    toggleLoading(state: false);
    showFlushBar(
      title: 'Email Updated',
      message:
          'Don\'t forget to use your new email instead of the old one while logging in.',
    );
  } catch (e) {
    if (e.code == 'email-already-in-use') {
      await toggleLoading(state: false);
      showFlushBar(
        title: 'Already registered',
        message: 'Seems like this email is already registered!',
        success: false,
      );
      return;
    }
    await toggleLoading(state: false);
    showFlushBar(
      title: 'Error',
      message: e.message ?? 'Unknown Error!',
      success: false,
    );
  }
}

editEmail(context) {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Edit Email",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 18),
                  ),
                ),
                AppTextField(
                  controller: _emailController,
                  label: 'New Email',
                  hint: 'Enter your new email',
                  maxLines: 1,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  autoFocus: true,
                  containerDecoration: BoxDecoration(
                    color: Color(0x05000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  maxLines: 1,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  autoFocus: true,
                  obscureText: true,
                  containerDecoration: BoxDecoration(
                    color: Color(0x05000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppActionButton(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.transparent,
                      label: 'Cancel',
                      textStyle: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontSize: 14),
                      shadows: [],
                    ),
                    AppActionButton(
                      onPressed: () => _updateEmail(
                          _emailController.text, _passwordController.text),
                      backgroundColor: Colors.transparent,
                      label: 'Submit',
                      textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                      shadows: [],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
