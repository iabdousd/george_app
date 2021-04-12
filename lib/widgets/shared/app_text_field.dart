import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label, hint, ifRequiredMessage;
  final bool isRequired, obscureText, autoFocus;
  final TextEditingController controller;
  final BoxDecoration containerDecoration;
  final EdgeInsets margin;
  final EdgeInsets contentPadding;
  final TextInputAction textInputAction;
  final int minLines, maxLines;
  const AppTextField({
    Key key,
    @required this.controller,
    @required this.label,
    @required this.hint,
    this.ifRequiredMessage,
    this.isRequired: false,
    this.margin: const EdgeInsets.symmetric(vertical: 8.0),
    this.containerDecoration,
    this.contentPadding: const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 20.0,
    ),
    this.obscureText: false,
    this.textInputAction: TextInputAction.done,
    this.autoFocus: false,
    this.minLines,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: containerDecoration ??
          BoxDecoration(
            color: Color(0x10000000),
            borderRadius: BorderRadius.circular(8.0),
          ),
      margin: margin,
      child: TextFormField(
        controller: controller,
        autofocus: autoFocus,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          contentPadding: contentPadding,
          border: InputBorder.none,
        ),
        obscureText: obscureText,
        validator: (t) {
          if (isRequired && t.replaceAll('\n', '').trim().isEmpty)
            return ifRequiredMessage;
          return null;
        },
        textInputAction: textInputAction,
        minLines: minLines,
        maxLines: maxLines,
      ),
    );
  }
}
