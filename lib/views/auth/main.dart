import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'WELCOME TO',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'PandorasList',
                    style: Theme.of(context).textTheme.headline4.copyWith(
                          fontFamily: 'logo',
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/welcome.svg',
                width: 256,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 6.0),
                    child: ElevatedButton.icon(
                      onPressed: _loginWithEmail,
                      icon: Icon(Icons.email_rounded),
                      label: Text(
                        'Continue with Email',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor), //Color(0xFFBB001B)
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 10.0)),
                      ),
                    ),
                  ),
                  if (Platform.isIOS)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 6.0),
                      child: ElevatedButton.icon(
                        onPressed: _loginWitApple,
                        icon: SvgPicture.asset(
                          'assets/images/icons/apple.svg',
                          width: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Continue with Apple',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFF000000)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 10.0)),
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _loginWithGoogle,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0x22000000),
                                  width: 1,
                                ),
                              ),
                              child: SvgPicture.asset(
                                'assets/images/icons/google.svg',
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _loginWithFacebook,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0x22000000),
                                  width: 1,
                                ),
                              ),
                              child: SvgPicture.asset(
                                'assets/images/icons/facebook.svg',
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _loginWithTwitter,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(left: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0x22000000),
                                  width: 1,
                                ),
                              ),
                              child: SvgPicture.asset(
                                'assets/images/icons/twitter.svg',
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'By continuing you agree to PandorasList\'s ',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 12,
                              letterSpacing: .5,
                            ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => print('FORGOT PASSWORD'),
                          ),
                          TextSpan(
                            text: ' and ',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      fontSize: 12,
                                    ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
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
            ],
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
// TODO:
  }

  _loginWithFacebook() async {
// TODO:
  }

  _loginWithGoogle() async {
// TODO:
  }

  _loginWithTwitter() async {
// TODO:
  }
}
