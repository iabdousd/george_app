import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/svg.dart';
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
    this.dateFormat = 'dd MMM yyyy',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin = const EdgeInsets.only(
      top: 16.0,
      left: 8.0,
      right: 8.0,
    ),
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
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Color(0xFFB2B6C3),
                ),
          ),
          Container(
            padding: EdgeInsets.only(top: 4, bottom: 4.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0x88B2B5C3),
                ),
              ),
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
                        Expanded(
                          child: Text(
                            DateFormat(dateFormat).format(selectedDate),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/images/icons/calendar.svg',
                            color: HexColor.fromHex(color),
                            width: 24,
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
      ),
    );
  }
}
