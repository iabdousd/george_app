import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/constants/theme.dart';

class AppCheckbox extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;
  final Color activeColor;
  final Color activeBorderColor;
  final Color inactiveBorderColor;
  final double width, height;
  const AppCheckbox({
    Key key,
    @required this.onChanged,
    @required this.value,
    this.activeColor: kSecondaryColor,
    this.activeBorderColor: kSecondaryColor,
    this.inactiveBorderColor: const Color(0xFFB2B5C3),
    this.width: 32.0,
    this.height: 32.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value ? activeBorderColor : inactiveBorderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 150),
                opacity: value ? 1 : 0,
                child: SvgPicture.asset(
                  'assets/images/icons/done.svg',
                  color: activeColor,
                  width: 9.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
