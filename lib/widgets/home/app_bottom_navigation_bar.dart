import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: index,
      onTap: changePage,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/icons/home.svg',
            key: keys[0],
            width: 22,
            height: 22,
            color: index == 0 ? Theme.of(context).primaryColor : null,
          ),
          label: '',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/icons/calendar.svg',
            key: keys[1],
            width: 22,
            height: 22,
            color: index == 1 ? Theme.of(context).primaryColor : null,
          ),
          label: '',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/icons/activity.svg',
            key: keys[3],
            width: 22,
            height: 22,
            color: index == 3 ? Theme.of(context).primaryColor : null,
          ),
          label: '',
          tooltip: '',
        ),
      ],
    );
  }
}
