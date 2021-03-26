import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final String title;
  final String color;
  final Function onSubmit;
  final DateTime startDate;
  final DateTime initialDate;
  final DateTime endDate;
  final bool withTime;
  final String dateFormat;
  final String timeFormat;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets margin;

  const DatePickerWidget({
    Key key,
    @required this.title,
    @required this.color,
    @required this.onSubmit,
    this.startDate,
    this.initialDate,
    this.endDate,
    this.withTime = false,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'hh:mm a',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin = const EdgeInsets.only(top: 8.0),
  }) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime selectedDate;
  bool hideTime;

  Future _selectTime() async {
    final TimeOfDay picked = await showRoundedTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
    );

    if (picked != null) {
      if ((widget.startDate != null &&
              widget.startDate.day == selectedDate.day &&
              widget.startDate.month == selectedDate.month &&
              widget.startDate.year == selectedDate.year &&
              picked.hour + picked.minute / 60 <=
                  (widget.startDate?.hour ?? 0) +
                      (widget.startDate?.minute ?? 0) / 60) ||
          (widget.endDate != null &&
              widget.endDate.day == selectedDate.day &&
              widget.endDate.month == selectedDate.month &&
              widget.endDate.year == selectedDate.year &&
              picked.hour + picked.minute / 60 >
                  (widget.endDate?.hour ?? 24) +
                      (widget.endDate?.minute ?? 0) / 60)) {
        showFlushBar(
          title: 'Malformat dates',
          message: 'The start date must be before the end date!',
          success: false,
        );

        return;
      }
      selectedDate = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, picked.hour, picked.minute);
      widget.onSubmit(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
          DateTime(1970, 1, 1, picked.hour, picked.minute));
    }
    setState(() {});
  }

  _pickDate() async {
    try {
      final DateTime picked = await showRoundedDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: widget.startDate ?? DateTime(2000),
        lastDate: widget.endDate ?? DateTime(2100),
        height: 280,
      );
      if (picked != null) {
        setState(() {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedDate.hour,
            selectedDate.minute,
          );
        });
        if (widget.withTime)
          widget.onSubmit(
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
              DateTime(1970, 1, 1, selectedDate.hour, selectedDate.minute));
        else
          widget.onSubmit(selectedDate);
      }
    } catch (e) {
      showFlushBar(
        title: 'Malformat dates',
        message: 'The start date must be before the end date!',
        success: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    hideTime = !widget.withTime;
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.withTime) hideTime = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: widget.margin,
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
          padding: EdgeInsets.only(top: 4, bottom: 4.0),
          decoration: BoxDecoration(
            color: Color(0x07000000),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: HexColor.fromHex(widget.color),
                          size: 24,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          DateFormat(widget.dateFormat).format(selectedDate),
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
              AnimatedOpacity(
                duration: Duration(milliseconds: 250),
                opacity: widget.withTime ? 1 : 0,
                onEnd: () => setState(() => hideTime = !widget.withTime),
                child: hideTime
                    ? Container()
                    : InkWell(
                        onTap: _selectTime,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.timer_rounded,
                                color: HexColor.fromHex(widget.color),
                                size: 24,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              DateFormat(widget.timeFormat)
                                  .format(selectedDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontSize: 16),
                            ),
                            SizedBox(
                              width: 8,
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
