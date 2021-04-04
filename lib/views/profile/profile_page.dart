import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/clippers.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  ProfilePage({Key key, @required this.name}) : super(key: key);

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
                          child: Image(
                            image: CachedImageProvider(
                                'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headline5,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
