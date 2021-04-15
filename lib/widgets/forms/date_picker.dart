import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final String title;
  final String color;
  final Function onSubmit;
  final DateTime startDate;
  final DateTime selectedDate;
  final DateTime endDate;
  final String dateFormat;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets margin;

  const DatePickerWidget({
    Key key,
    @required this.title,
    @required this.color,
    @required this.onSubmit,
    this.startDate,
    this.selectedDate,
    this.endDate,
    this.dateFormat = 'dd/MM/yyyy',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin = const EdgeInsets.only(top: 8.0),
  }) : super(key: key);

  _pickDate(context) async {
    try {
      final DateTime picked = await showRoundedDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: startDate != null
            ? DateTime(
                startDate.year,
                startDate.month,
                startDate.day,
              )
            : DateTime(2000),
        lastDate: endDate != null
            ? DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
              )
            : DateTime(2100),
        height: 280,
      );
      if (picked != null) {
        onSubmit(DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        ));
      }
    } catch (e) {
      print(e);
      if (!(e is NoSuchMethodError))
        showFlushBar(
          title: 'Malformat dates',
          message: 'The start date must be before the end date!',
          success: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: margin,
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
                  title,
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
          padding: EdgeInsets.only(top: 4, bottom: 4.0),
          decoration: BoxDecoration(
            color: Color(0x07000000),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: HexColor.fromHex(color),
                          size: 24,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          DateFormat(dateFormat).format(selectedDate),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
