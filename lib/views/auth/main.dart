import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';

import 'email_login.dart';

class AuthViews extends StatefulWidget {
  AuthViews({Key key}) : super(key: key);

  @override
  _AuthViewsState createState() => _AuthViewsState();
}

class _AuthViewsState extends State<AuthViews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: kIsWeb ? 512 : null,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Welcome to',
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/welcome.svg',
                  width: 230,
                  height: 230,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 51),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircularActionButton(
                        onClick: _loginWithEmail,
                        title: 'CONTINUE WITH EMAIL',
                        titleStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: Icon(
                          Icons.email,
                          color: Theme.of(context).backgroundColor,
                        ),
                        backgroundColor: Theme.of(context).accentColor,
                        margin: EdgeInsets.only(bottom: 16),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFB2B5C3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Color(0xFFB2B5C3),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFB2B5C3),
                            ),
                          ),
                        ],
                      ),
                      if (!kIsWeb && Platform.isIOS)
                        CircularActionButton(
                          onClick: _loginWitApple,
                          title: 'CONTINUE WITH APPLE',
                          titleStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).backgroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                          icon: SvgPicture.asset(
                            'assets/images/icons/apple.svg',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.black,
                          margin: EdgeInsets.only(top: 16),
                        ),
                      CircularActionButton(
                        onClick: _loginWithGoogle,
                        title: 'CONTINUE WITH GOOGLE',
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: SvgPicture.asset(
                          'assets/images/icons/google.svg',
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFB2B5C3),
                          ),
                          borderRadius: BorderRadius.circular(64),
                        ),
                        margin: EdgeInsets.only(top: 8),
                      ),
                      CircularActionButton(
                        onClick: _loginWithFacebook,
                        title: 'CONTINUE WITH FACEBOOK',
                        titleStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: SvgPicture.asset(
                          'assets/images/icons/facebook.svg',
                        ),
                        backgroundColor: Color(0xFF3B5998),
                        margin: EdgeInsets.only(top: 8),
                      ),
                      CircularActionButton(
                        onClick: _loginWithTwitter,
                        title: 'CONTINUE WITH TWITTER',
                        titleStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: SvgPicture.asset(
                          'assets/images/icons/twitter.svg',
                        ),
                        backgroundColor: Color(0xFF03A9F4),
                        margin: EdgeInsets.only(top: 8),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'By continuing you agree to Stackedtasks\'s ',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      fontSize: 12,
                                      letterSpacing: .5,
                                      color: Color(0xFFB2B5C3),
                                    ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFFB2B5C3),
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => print('FORGOT PASSWORD'),
                              ),
                              TextSpan(
                                text: ' and ',
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFFB2B5C3),
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => print('FORGOT PASSWORD'),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _loginWithEmail() {
    Get.to(
      () => EmailLoginView(),
      popGesture: true,
      transition: Transition.rightToLeft,
    );
  }

  _loginWitApple() async {
    // ! TO IMPLEMENT
  }

  _loginWithFacebook() async {
    // ! TO IMPLEMENT
  }

  _loginWithGoogle() async {
    // ! TO IMPLEMENT
  }

  _loginWithTwitter() async {
    // ! TO IMPLEMENT
  }
}
