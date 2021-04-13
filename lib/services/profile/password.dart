import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plandoraslist/services/feed-back/flush_bar.dart';
import 'package:plandoraslist/services/feed-back/loader.dart';
import 'package:plandoraslist/widgets/shared/app_action_button.dart';
import 'package:plandoraslist/widgets/shared/app_text_field.dart';

_updatePassword(String p1, String p2, String oldP) async {
  if (p1 != p2) {
    showFlushBar(
      title: 'Passwords mismatch',
      message: 'Please make sure the passwords are similar',
      success: false,
    );
    return;
  }
  toggleLoading(state: true);
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: FirebaseAuth.instance.currentUser.email,
      password: oldP,
    );
    await FirebaseAuth.instance.currentUser.updatePassword(p1);
    toggleLoading(state: false);
    toggleLoading(state: false);
    showFlushBar(
      title: 'Password Updated!',
      message:
          'Don\'t forget to use your new password instead of the old one while logging in.',
    );
  } catch (e) {
    await toggleLoading(state: false);
    if (e is FirebaseAuthException && e.code == 'wrong-password')
      showFlushBar(
        title: 'Wrong Password',
        message: 'Please make sure your old password is correct.',
        success: false,
      );
    else
      showFlushBar(
        title: 'Change Password Error',
        message: e.message ?? 'Unknown Error!',
        success: false,
      );
  }
}

changePassword(context) {
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  final _passwordController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: Container(
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
                    "Change Password",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 18),
                  ),
                ),
                AppTextField(
                  controller: _password1Controller,
                  label: 'New Password',
                  hint: 'Enter your new password',
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
                  textInputAction: TextInputAction.next,
                ),
                AppTextField(
                  controller: _password2Controller,
                  label: 'Repeat New Password',
                  hint: 'Repeat your new password',
                  maxLines: 1,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  obscureText: true,
                  containerDecoration: BoxDecoration(
                    color: Color(0x05000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                AppTextField(
                  controller: _passwordController,
                  label: 'Old Password',
                  hint: 'Enter your old password',
                  maxLines: 1,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
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
                      onPressed: () => _updatePassword(
                          _password1Controller.text,
                          _password2Controller.text,
                          _passwordController.text),
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
