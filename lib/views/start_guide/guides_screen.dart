import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/views/auth/main.dart';

class GuidesScreen extends StatefulWidget {
  GuidesScreen({Key key}) : super(key: key);

  @override
  _GuidesScreenState createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  final _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  List _pagesContent = [
    {
      'image': 'assets/images/welcome/page_0.svg',
      'title': 'Welcome',
      'sub_title':
          'Stacked Tasks is a tool that assists you as you go about achieving your goals and dreams.',
    },
    {
      'image': 'assets/images/welcome/page_1.svg',
      'title': 'Planning',
      'sub_title':
          'Plan your goals, Set an overall date by when you want to achieve your goal and break it down into manageable parts called stacks.',
    },
    {
      'image': 'assets/images/welcome/page_2.svg',
      'title': 'Execution',
      'sub_title':
          'Stay on track with a Calendar and Timer screen that shows you the upcoming tasks.',
    },
    {
      'image': 'assets/images/welcome/page_3.svg',
      'title': 'Review',
      'sub_title':
          'Get a summarised view of your productivity by day, a feed of your activity by task and a more high level progress summary for each of your goals.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentIndex < 3
                    ? TextButton(
                        onPressed: () => Get.to(() => AuthViews()),
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: Color(0xFFB2B5C3),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Container(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 512,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 4,
                      pageSnapping: true,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              _pagesContent[index]['image'],
                              height: 276,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 32.0, bottom: 8.0),
                              child: Text(
                                _pagesContent[index]['title'],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: Color(0xFF3B404A),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                _pagesContent[index]['sub_title'],
                                style: TextStyle(
                                  color: Color(0xFF767C8D),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _currentIndex == 3
                            ? Get.to(() => AuthViews())
                            : _pageController.nextPage(
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              ),
                        child: Text(
                          _currentIndex == 3 ? 'START' : 'NEXT',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 4; i++)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: _currentIndex == i ? 16 : 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? Theme.of(context).accentColor
                                  : Color(0xFFEEEEEE),
                              gradient: _currentIndex == i
                                  ? LinearGradient(
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                      colors: [
                                        Theme.of(context).accentColor,
                                        Theme.of(context).primaryColor,
                                      ],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
