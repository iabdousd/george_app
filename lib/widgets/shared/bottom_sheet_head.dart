import 'package:flutter/material.dart';

class BottomSheetHead extends StatelessWidget {
  final VoidCallback onSubmit;
  final String title, submitText;
  const BottomSheetHead({
    Key key,
    @required this.onSubmit,
    @required this.title,
    this.submitText: 'DONE',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            color: Color(0xFFB2B6C3),
            width: 28,
            height: 3,
            margin: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFFB2B6C3),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFF767C8D),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: onSubmit,
              child: Text(
                submitText,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
