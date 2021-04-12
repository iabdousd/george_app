import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plandoraslist/services/feed-back/reports.dart';
import 'package:plandoraslist/widgets/shared/app_action_button.dart';

class ReportIssue extends StatefulWidget {
  ReportIssue({Key key}) : super(key: key);

  @override
  _ReportIssueState createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REPORT AN ISSUE'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 44,
              bottom: 24,
            ),
            child: SvgPicture.asset(
              'assets/images/report_issue.svg',
              height: 200,
              width: 200,
            ),
          ),
          Text(
            'What is your issue?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context)
                      .textTheme
                      .headline5
                      .color
                      .withOpacity(.5),
                ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 24,
              left: 32,
              right: 32,
            ),
            child: TextField(
              maxLines: 3,
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Color(0x22000000),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Color(0x22000000),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          AppActionButton(
            onPressed: () => reportAnIssue(_controller.text),
            margin: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 64,
            ),
            radius: 24,
            shadows: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(.5),
                blurRadius: 8,
              )
            ],
            backgroundColor: Theme.of(context).backgroundColor,
            label: 'REPORT',
            textStyle: Theme.of(context).textTheme.headline6.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }
}
