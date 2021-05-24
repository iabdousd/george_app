import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/storage/image_upload.dart';
import 'package:stackedtasks/views/main-views/main.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

class EmailRegisterView extends StatefulWidget {
  EmailRegisterView({Key key}) : super(key: key);

  @override
  EmailRegisterViewState createState() => EmailRegisterViewState();
}

class EmailRegisterViewState extends State<EmailRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  PickedFile profileImage;
  Uint8List profileImageBytes;

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
                              'Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8.0, bottom: 32.0),
                              child: RichText(
                                text: new TextSpan(
                                  text: 'Please fill these fields to ',
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: [
                                    new TextSpan(
                                      text: 'Get Started!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 6,
                                        offset: Offset(1, 1),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: InkWell(
                                      onTap: addProfileImage,
                                      child: profileImage != null
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                kIsWeb
                                                    ? Image.memory(
                                                        profileImageBytes,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(profileImage.path),
                                                        fit: BoxFit.cover,
                                                      ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: () => setState(() {
                                                      profileImage = null;
                                                    }),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .backgroundColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Icon(
                                                        Icons.delete_sharp,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Icon(Icons.add_a_photo),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppTextField(
                              controller: _usernameController,
                              label: 'Username',
                              hint: 'A name for your Profile',
                              textInputAction: TextInputAction.next,
                            ),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Your email here',
                              textInputAction: TextInputAction.next,
                            ),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Make sure it\'s secure!',
                              obscureText: true,
                              maxLines: 1,
                              textInputAction: TextInputAction.next,
                            ),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Repeat your password',
                              obscureText: true,
                              maxLines: 1,
                              textInputAction: TextInputAction.next,
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
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            EdgeInsets.all(14.0),
                          ),
                        ),
                        child: Text(
                          'Register',
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

  _register() async {
    if (!_formKey.currentState.validate()) return;
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim())) {
      showFlushBar(
        title: 'Malformed email',
        message: 'Please make sure of the format of your email.',
        success: false,
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showFlushBar(
        title: 'Passwords mismatch',
        message: 'Please make sure that your passwords does match.',
        success: false,
      );
      return;
    }
    try {
      await toggleLoading(state: true);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      User user = FirebaseAuth.instance.currentUser;
      await user.sendEmailVerification();
      String pictureUrl;
      if (profileImage != null) {
        pictureUrl = await uploadFile(profileImage);
      }
      await user.updateProfile(
        displayName: _usernameController.text,
        photoURL: pictureUrl,
      );
      await FirebaseFirestore.instance.collection(USERS_KEY).doc(user.uid).set({
        USER_UID_KEY: user.uid,
        USER_FULL_NAME_KEY: _usernameController.text,
        USER_EMAIL_KEY: _emailController.text.trim().toLowerCase(),
        USER_PROFILE_PICTURE_KEY: pictureUrl,
      });
      await toggleLoading(state: false);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainView()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await toggleLoading(state: false);
        showFlushBar(
          title: 'Weak Password',
          message:
              'Please try to make your password more secure by adding numbers and letters to it.',
          success: false,
        );
        return;
      } else if (e.code == 'email-already-in-use') {
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
        message: e.message,
        success: false,
      );
    }
  }

  _pickImage(ImageSource imageSource) async {
    PickedFile image;

    try {
      image = await ImagePicker().getImage(
        imageQuality: 80,
        source: imageSource,
      );
    } on Exception catch (e) {
      print(e);
      if (imageSource != ImageSource.gallery)
        _pickImage(ImageSource.gallery);
      else
        showFlushBar(
          title: 'Error',
          message: 'Unknown error happened while importing your images.',
          success: false,
        );
    }
    if (image != null) {
      profileImageBytes = await image.readAsBytes();
      setState(() {
        profileImage = image;
      });
    }
    Navigator.of(context).pop();
  }

  addProfileImage() {
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icons.image_outlined,
              label: 'Photos',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 0, top: 4),
              iconSize: 28,
            ),
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 4, top: 0),
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }
}
