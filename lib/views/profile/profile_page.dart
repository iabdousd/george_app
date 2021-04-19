import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/config/extensions/clippers.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
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
                          child: FirebaseAuth.instance.currentUser.photoURL !=
                                  null
                              ? Image(
                                  image: CachedImageProvider(
                                    FirebaseAuth.instance.currentUser.photoURL,
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
                      onTap: () => Get.to(
                        () => AppPhotoView(
                          imageProvider: CachedImageProvider(
                            FirebaseAuth.instance.currentUser.photoURL,
                          ),
                        ),
                      ),
                    ),
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
                    toggleLoading(state: true);
                    await FirebaseAuth.instance.signOut();
                    toggleLoading(state: false);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AuthViews()),
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
}
