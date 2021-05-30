import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

_updatePhone(CountryCode country, String phone, String password) async {
  if (phone.length < 8) {
    showFlushBar(
      title: 'Malformed phone number',
      message: 'Please make sure of the format of your phone number.',
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
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: country.dialCode + phone,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.currentUser.linkWithCredential(credential);
      },
      verificationFailed: (exception) {
        print('EXCEPTION: $exception');
        if (exception.code == 'invalid-phone-number') {
          toggleLoading(state: false);
          showFlushBar(
            title: 'Verification Failure',
            message: 'The provided phone number is not valid.',
            success: false,
          );
        }
        toggleLoading(state: false);
        showFlushBar(
          title: 'Verification Failure',
          message: 'We couldn\'t send SMS code to this number.',
          success: false,
        );
      },
      codeSent: (String verificationId, int resendToken) {
        final _codeController = TextEditingController();
        toggleLoading(state: false);
        toggleLoading(state: false);
        showDialog(
          context: Get.context,
          builder: (context) {
            return AlertDialog(
              title: Text('Provide you SMS code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: _codeController,
                    label: 'Verification Code',
                  ),
                  AppActionButton(
                    onPressed: () async {
                      try {
                        toggleLoading(state: true);
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                          verificationId: verificationId,
                          smsCode: _codeController.text,
                        );
                        if (FirebaseAuth.instance.currentUser.phoneNumber !=
                            null) {
                          await FirebaseAuth.instance.currentUser
                              .updatePhoneNumber(credential);
                        } else {
                          await FirebaseAuth.instance.currentUser
                              .linkWithCredential(credential);
                        }
                        await getCurrentUser().reload();
                        await FirebaseFirestore.instance
                            .collection(USERS_KEY)
                            .doc(getCurrentUser().uid)
                            .update({
                          USER_PHONE_NUMBER_KEY: getCurrentUser().phoneNumber,
                        });

                        toggleLoading(state: false);
                        toggleLoading(state: false);
                        showFlushBar(
                          title: 'Phone Number Added',
                          message:
                              'Your phone number has been linked to your account successfully!',
                        );
                      } catch (e) {
                        toggleLoading(state: false);
                        showFlushBar(
                          title: 'Verification Error',
                          message: e.message ??
                              'The code inserted has been expired or is incorrect.',
                          success: false,
                        );
                      }
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    label: 'Confirm',
                  ),
                ],
              ),
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (code) {
        //
      },
    );
  } catch (e) {
    print(e);
    if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
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
      message: e?.message ?? 'Unknown Error!',
      success: false,
    );
  }
}

editPhone(context) {
  CountryCode _country = CountryCode.fromCountryCode('US');
  final _phoneController = TextEditingController();
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
                    "Phone number",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 18),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CountryCodePicker(
                      onChanged: (CountryCode code) => _country = code,
                      initialSelection: 'US',
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: _phoneController,
                        label: 'Phone number',
                        hint: 'Enter your phone number',
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
                    ),
                  ],
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
                      onPressed: () => _updatePhone(_country,
                          _phoneController.text, _passwordController.text),
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
