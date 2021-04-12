import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plandoraslist/services/feed-back/reports.dart';
import 'package:plandoraslist/widgets/shared/app_action_button.dart';

class ContactScreen extends StatefulWidget {
  ContactScreen({Key key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              'assets/images/contact_us.svg',
              height: 200,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Text(
            'CONTACT US!',
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
              maxLines: 1,
              controller: _titleController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                labelText: 'Title',
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
              textInputAction: TextInputAction.next,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 12,
              left: 32,
              right: 32,
            ),
            child: TextField(
              maxLines: 3,
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Body',
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
            onPressed: () =>
                sendContactMessage(_titleController.text, _bodyController.text),
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
            label: 'SEND MESSAGE',
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
