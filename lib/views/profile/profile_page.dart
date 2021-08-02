import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/storage/image_upload.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/auth/main.dart';
import 'package:stackedtasks/views/profile/contact_us.dart';
import 'package:stackedtasks/views/profile/report_issue.dart';
import 'package:stackedtasks/views/profile/settings.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

import 'about_us.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  PickedFile profileImage;

  final menuItems = [
    {
      'title': 'Notifications',
      'clickEvent': () => print('Notifications screen'),
      'icon': 'assets/images/icons/notification.svg',
    },
    {
      'title': 'Contact Us',
      'clickEvent': () => Get.to(() => ContactScreen()),
      'icon': 'assets/images/icons/mail.svg',
    },
    {
      'title': 'About Us',
      'clickEvent': () => Get.to(() => AboutUsScreen()),
      'icon': 'assets/images/icons/info.svg',
    },
    {
      'title': 'Report an Issue',
      'clickEvent': () => Get.to(() => ReportIssue()),
      'icon': 'assets/images/icons/danger.svg',
    },
    {
      'title': 'Settings',
      'clickEvent': () => Get.to(() => SettingsScreen()),
      'icon': 'assets/images/icons/settings.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppAppBar(
        context: context,
        customTitle: Text('My profile'),
        centerTitle: false,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back),
          iconSize: 24,
          color: Theme.of(context).backgroundColor,
        ),
        trailing: IconButton(
          onPressed: _disconnect,
          icon: Icon(Icons.logout),
          iconSize: 24,
          color: Theme.of(context).backgroundColor,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (FirebaseAuth.instance.currentUser?.photoURL !=
                              null)
                            Get.to(
                              () => AppPhotoView(
                                imageProvider: CachedImageProvider(
                                  FirebaseAuth.instance.currentUser?.photoURL,
                                ),
                              ),
                              transition: Transition.downToUp,
                            );
                        },
                        child: Hero(
                          tag: 'progile_logo',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: profileImage != null
                                ? Image.file(
                                    File(profileImage.path),
                                    fit: BoxFit.cover,
                                    width: 104,
                                    height: 104,
                                  )
                                : FirebaseAuth.instance.currentUser?.photoURL !=
                                        null
                                    ? Image(
                                        image: CachedImageProvider(
                                          FirebaseAuth
                                              .instance.currentUser?.photoURL,
                                        ),
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/profile.svg',
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: profilePictureClickEvent,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                                colors: [
                                  Theme.of(context).accentColor,
                                  Theme.of(context).primaryColor,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).backgroundColor,
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit,
                              color: Theme.of(context).backgroundColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      getCurrentUser().displayName,
                      style: TextStyle(
                        color: Color(0xFF3B404A),
                        fontWeight: FontWeight.w600,
                        fontSize: 36,
                        height: 1.75,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final menuItem = menuItems[index];
                    return AppActionButton(
                      onPressed: menuItem['clickEvent'],
                      label: menuItem['title'],
                      textStyle: TextStyle(
                        color: Color(0xFF3B404A),
                        fontSize: 16,
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: SvgPicture.asset(
                          menuItem['icon'],
                          color: Color(0xFFB2B5C3),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Color(0xFFB2B5C3),
                        size: 24,
                      ),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.transparent,
                      shadows: [],
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    indent: 0,
                  ),
                  itemCount: menuItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _disconnect() {
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
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            child: Text('Yes'),
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
        await FirebaseAuth.instance.currentUser?.updateProfile(
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
          color: Theme.of(context).backgroundColor,
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
      ),
    );
  }
}
