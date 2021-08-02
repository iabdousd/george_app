import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Register',
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 36,
                        ),
                  ),
                  GestureDetector(
                    onTap: addProfileImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0x14B2B5C3),
                        shape: BoxShape.circle,
                        image: profileImageBytes == null && profileImage == null
                            ? null
                            : DecorationImage(
                                image: kIsWeb
                                    ? MemoryImage(
                                        profileImageBytes,
                                      )
                                    : FileImage(
                                        File(profileImage.path),
                                      ),
                                fit: BoxFit.cover,
                              ),
                      ),
                      width: 104,
                      height: 104,
                      child: profileImageBytes != null || profileImage != null
                          ? null
                          : Image.asset(
                              'assets/images/icons/camera.png',
                            ),
                    ),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppTextField(
                              controller: _usernameController,
                              label: 'Username',
                              hint: 'A name for your Profile',
                              textInputAction: TextInputAction.next,
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage:
                                  'Please insert your username first',
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Your email here',
                              textInputAction: TextInputAction.next,
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage:
                                  'Please insert your email first',
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Make sure it\'s secure!',
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage:
                                  'Please insert your password first',
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Repeat your password',
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              backgroundColor: Colors.transparent,
                              border: UnderlineInputBorder(),
                              isRequired: true,
                              ifRequiredMessage: 'Please verify your password',
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                            ),
                            CircularActionButton(
                              onClick: _register,
                              title: 'SIGN UP',
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
                height: 104,
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
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppActionButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icons.image_outlined,
                label: 'Photos',
                backgroundColor: Colors.transparent,
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
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 4, top: 0),
                iconSize: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
