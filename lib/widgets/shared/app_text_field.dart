import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label, hint, ifRequiredMessage;
  final bool isRequired, obscureText, autoFocus;
  final Color backgroundColor;
  final InputBorder border;
  final TextEditingController controller;
  final BoxDecoration containerDecoration;
  final EdgeInsets margin;
  final EdgeInsets contentPadding;
  final TextInputAction textInputAction;
  final int minLines, maxLines;
  final Widget prefix, suffix;
  final TextInputType keyboardType;
  final Function(String) onSubmit;

  const AppTextField({
    Key key,
    @required this.controller,
    this.label,
    this.hint,
    this.backgroundColor: const Color(0x10000000),
    this.border: InputBorder.none,
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
    this.onSubmit,
    this.minLines,
    this.maxLines,
    this.prefix,
    this.suffix,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: containerDecoration ??
          BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
      margin: margin,
      child: TextFormField(
        controller: controller,
        onFieldSubmitted: onSubmit,
        autofocus: autoFocus,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          contentPadding: contentPadding,
          border: border,
          prefix: prefix,
          suffix: suffix,
        ),
        keyboardType: keyboardType,
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
