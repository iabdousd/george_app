import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final String title;
  final String color;
  final Function(DateTime) onSubmit;

  const DatePickerWidget(
      {Key key,
      @required this.title,
      @required this.color,
      @required this.onSubmit})
      : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime selectedDate = DateTime.now();

  _pickDate() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onSubmit(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Theme.of(context).primaryColor.withOpacity(.2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Theme.of(context).primaryColor.withOpacity(.2),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: Color(0x07000000),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            onTap: _pickDate,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: HexColor.fromHex(widget.color),
                    size: 32,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  DateFormat('EEEE, dd MMMM').format(selectedDate),
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
                  width: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
