import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plandoraslist/views/auth/main.dart';

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
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 400,
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
                              height: 200,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 32.0, bottom: 8.0),
                              child: Text(
                                _pagesContent[index]['title'],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              _pagesContent[index]['sub_title'],
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _currentIndex == 0
                                ? Theme.of(context).primaryColor
                                : Color(0x22000000),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _currentIndex == 1
                                ? Theme.of(context).primaryColor
                                : Color(0x22000000),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _currentIndex == 2
                                ? Theme.of(context).primaryColor
                                : Color(0x22000000),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _currentIndex == 3
                                ? Theme.of(context).primaryColor
                                : Color(0x22000000),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex < 3)
                    TextButton(
                      onPressed: () => Get.to(() => AuthViews()),
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    )
                  else
                    Container(),
                  TextButton(
                    onPressed: () => _currentIndex == 3
                        ? Get.to(() => AuthViews())
                        : _pageController.nextPage(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          ),
                    child: Text(
                      _currentIndex == 3 ? 'Start' : 'Next',
                      style: Theme.of(context).textTheme.subtitle1,
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
