import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/main-views/main.dart';

import 'email_register.dart';

class EmailLoginView extends StatefulWidget {
  EmailLoginView({Key key}) : super(key: key);

  @override
  EmailLoginViewState createState() => EmailLoginViewState();
}

class EmailLoginViewState extends State<EmailLoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Icon(Icons.arrow_back),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: kIsWeb ? 512 : null,
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Log in',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8.0, bottom: 44.0),
                              child: RichText(
                                text: new TextSpan(
                                  text: 'If you are new / ',
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: [
                                    new TextSpan(
                                      text: 'Create an account',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () => Get.to(
                                              () => EmailRegisterView(),
                                              popGesture: true,
                                              transition:
                                                  Transition.rightToLeft,
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0x10000000),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Your email here',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 20.0,
                                  ),
                                  border: InputBorder.none,
                                ),
                                validator: (t) {
                                  if (t.isEmpty)
                                    return 'Please insert your email first';
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0x10000000),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Your secure password here',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 20.0,
                                  ),
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                validator: (t) {
                                  if (t.isEmpty)
                                    return 'Please insert your password first';
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 8.0,
                              ),
                              child: RichText(
                                text: new TextSpan(
                                  text: 'Forgot password? / ',
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: [
                                    new TextSpan(
                                      text: 'Reset Password',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap =
                                            () => print('FORGOT PASSWORD'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: kIsWeb ? 512 : double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            EdgeInsets.all(14.0),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _login() async {
    if (!_formKey.currentState.validate()) return;
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim())) {
      showFlushBar(
        title: 'Wrong email',
        message: 'Please make sure of the format of your email.',
        success: false,
      );
      return;
    }
    try {
      await toggleLoading(state: true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await getCurrentUser().reload();
      final user = getCurrentUser();
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
      await toggleLoading(state: false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('hasEnteredBefore', true);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainView()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await toggleLoading(state: false);
        showFlushBar(
          title: 'User not found',
          message: 'Please make sure that your email is typed correctly.',
          success: false,
        );
        return;
      }
      await toggleLoading(state: false);
      showFlushBar(
        title: 'Error',
        message: e.message,
        success: false,
      );
    }
  }
}
