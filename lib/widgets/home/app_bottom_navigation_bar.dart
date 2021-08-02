import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackedtasks/repositories/notification/notification_repository.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final List<GlobalKey> keys;
  final int index;
  final Function(int) changePage;
  const AppBottomNavigationBar({
    Key key,
    @required this.index,
    @required this.changePage,
    @required this.keys,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).backgroundColor,
      currentIndex: index,
      onTap: changePage,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).backgroundColor,
          icon: SvgPicture.asset(
            'assets/images/icons/home.svg',
            key: keys[0],
            width: 22,
            height: 22,
            color: index == 0 ? Theme.of(context).primaryColor : null,
          ),
          label: 'Home',
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).backgroundColor,
          icon: SvgPicture.asset(
            'assets/images/icons/calendar.svg',
            key: keys[1],
            width: 22,
            height: 22,
            color: index == 1 ? Theme.of(context).primaryColor : null,
          ),
          label: 'Calendar',
          tooltip: 'Calendar',
        ),
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).backgroundColor,
          icon: StreamBuilder<int>(
            stream: NotificationRepository.countNotifications(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Badge(
                showBadge: false, //count > 0,
                badgeContent: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 11,
                        ),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/bell.svg',
                  key: keys[2],
                  width: 22,
                  height: 22,
                  color: index == 2 ? Theme.of(context).primaryColor : null,
                ),
              );
            },
          ),
          label: 'Notifications',
          tooltip: 'Notifications',
        ),
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).backgroundColor,
          icon: SvgPicture.asset(
            'assets/images/icons/activity.svg',
            key: keys[3],
            width: 22,
            height: 22,
            color: index == 3 ? Theme.of(context).primaryColor : null,
          ),
          label: 'Activity',
          tooltip: 'Activity',
        ),
      ],
    );
  }
}
