import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/config/extensions/clippers.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/storage/image_upload.dart';
import 'package:stackedtasks/views/auth/main.dart';
import 'package:stackedtasks/views/profile/contact_us.dart';
import 'package:stackedtasks/views/profile/report_issue.dart';
import 'package:stackedtasks/views/profile/settings.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

import 'about_us.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> animation;
  PickedFile profileImage;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween<double>(begin: 20, end: 346).animate(_controller);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            builder: (context, anim) {
              return ClipPath(
                clipper: RoundedClipper(animation.value),
                child: Container(
                  height: animation.value,
                  color: Color(0x08000000),
                ),
              );
            },
            animation: _controller,
          ),
          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 24,
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    GestureDetector(
                        child: Hero(
                          tag: 'progile_logo',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: profileImage != null
                                ? Image.file(
                                    File(profileImage.path),
                                    fit: BoxFit.cover,
                                    width: 64,
                                    height: 64,
                                  )
                                : FirebaseAuth.instance.currentUser?.photoURL !=
                                        null
                                    ? Image(
                                        image: CachedImageProvider(
                                          FirebaseAuth
                                              .instance.currentUser?.photoURL,
                                        ),
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/profile.svg',
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      ),
                          ),
                        ),
                        onTap: profilePictureClickEvent),
                    SizedBox(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    FirebaseAuth.instance.currentUser.displayName,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                AppActionButton(
                  onPressed: () => Get.to(() => SettingsScreen()),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   Settings',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
                AppActionButton(
                  onPressed: () {},
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   Notifications',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
                AppActionButton(
                  onPressed: () => Get.to(() => ContactScreen()),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.75),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   Contact Us',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
                AppActionButton(
                  onPressed: () => Get.to(() => AboutUsScreen()),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.75),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   About Us',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
                AppActionButton(
                  onPressed: () => Get.to(() => ReportIssue()),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.report_problem_outlined,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   Report an Issue',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
                AppActionButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Are you sre to disconnect ?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              toggleLoading(state: true);
                              await FirebaseAuth.instance.signOut();
                              toggleLoading(state: false);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => AuthViews(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.logout,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  iconSize: 26.0,
                  backgroundColor: Colors.transparent,
                  shadows: [],
                  label: '   Disconnect',
                  textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void profilePictureClickEvent() {
    _pickImage(ImageSource imageSource) async {
      PickedFile image;

      try {
        image = await ImagePicker().getImage(
          imageQuality: 80,
          source: imageSource,
        );
      } on Exception catch (e) {
        print(e);
        showFlushBar(
          title: 'Error',
          message: 'Unknown error happened while importing your images.',
          success: false,
        );
      }
      if (image != null) {
        toggleLoading(state: true);
        setState(() {
          profileImage = image;
        });
        String url = await uploadFile(image);
        await FirebaseAuth.instance.currentUser.updateProfile(
          photoURL: url,
        );
        toggleLoading(state: false);
        showFlushBar(
          title: 'Success',
          message: 'Successfully updated your Profile Picture.',
          success: true,
        );
      }
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
            if (FirebaseAuth.instance.currentUser.photoURL != null)
              AppActionButton(
                onPressed: () => Get.to(
                  () => AppPhotoView(
                    imageProvider: CachedImageProvider(
                      FirebaseAuth.instance.currentUser.photoURL,
                    ),
                  ),
                ),
                icon: Icons.remove_red_eye,
                label: 'Open Picture',
                backgroundColor: Theme.of(context).backgroundColor,
                textStyle: Theme.of(context).textTheme.subtitle1,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 0, top: 4),
                iconSize: 28,
              ),
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icons.image_outlined,
              label: 'Update from Photos',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.subtitle1,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 0, top: 4),
              iconSize: 28,
            ),
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icons.camera_alt_outlined,
              label: 'Update from Camera',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.subtitle1,
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
