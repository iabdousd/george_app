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
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

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
      appBar: AppAppBar(
        context: context,
        autoImplifyLeading: true,
        customTitle: Container(),
        decoration: BoxDecoration(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log In',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 36,
                    ),
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
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage:
                                  'Please insert your email first',
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage:
                                  'Please insert your password first',
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              maxLines: 1,
                              textInputAction: TextInputAction.done,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 12.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Text(
                                      'Forgot password',
                                      style: TextStyle(
                                        color: Color(0xFF767C8D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircularActionButton(
                              onClick: _login,
                              title: 'LOGIN',
                              margin: EdgeInsets.only(top: 16),
                              backgroundColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 48.0, bottom: 8.0),
                child: Center(
                  child: RichText(
                    text: new TextSpan(
                      text: 'If you are new  ',
                      style: TextStyle(
                        color: Color(0xFFB2B5C3),
                        fontSize: 14,
                      ),
                      children: [
                        new TextSpan(
                          text: 'Create an account',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () => Get.to(
                                  () => EmailRegisterView(),
                                  popGesture: true,
                                  transition: Transition.rightToLeft,
                                ),
                        )
                      ],
                    ),
                  ),
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
