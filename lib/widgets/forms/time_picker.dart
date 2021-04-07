import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:plandoraslist/config/extensions/hex_color.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final String color;
  final Function onSubmit;
  final DateTime initialTime;
  final String timeFormat;
  final bool active;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets margin;

  const TimePickerWidget({
    Key key,
    @required this.title,
    @required this.color,
    @required this.onSubmit,
    this.initialTime,
    this.active: true,
    this.timeFormat = 'hh:mm a',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin = const EdgeInsets.only(top: 8.0),
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime selectedTime;
  bool hideTime;

  Future _selectTime() async {
    final TimeOfDay picked = await showRoundedTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute),
    );

    if (picked != null) {
      // if ((picked.hour + picked.minute / 60 <
      //         (widget.startDate?.hour ?? 0) +
      //             (widget.startDate?.minute ?? 0) / 60) ||
      //     (picked.hour + picked.minute / 60 >
      //         (widget.endDate?.hour ?? 24) +
      //             (widget.endDate?.minute ?? 0) / 60)) {
      //   showFlushBar(
      //     title: 'Malformat dates',
      //     message: 'The start date must be before the end date!',
      //     success: false,
      //   );

      //   return;
      // }
      selectedTime = DateTime(
        1970,
        1,
        1,
        picked.hour,
        picked.minute,
      );
      widget.onSubmit(DateTime(1970, 1, 1, picked.hour, picked.minute));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    hideTime = !widget.active;
    selectedTime = widget.initialTime ??
        DateTime(
          1970,
          1,
          1,
          DateTime.now().hour,
          DateTime.now().minute,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active) hideTime = false;
    return AnimatedOpacity(
      duration: Duration(milliseconds: 250),
      opacity: widget.active ? 1 : 0,
      onEnd: () => setState(() => hideTime = !widget.active),
      child: hideTime
          ? Container()
          : Column(
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
                  child: InkWell(
                    onTap: _selectTime,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
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
                          DateFormat(widget.timeFormat).format(selectedTime),
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
    );
  }
}
