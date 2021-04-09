import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<TextSpan> textToSpans(
  String text, {
  List parameters,
  double initialTextSize: 12.0,
  bool linksActivated: false,
}) {
  List<TextSpan> spans = [];
  /*
  * %*n => normal
  * %*l => light
  * %*b => gras
  * %s!{size}p => textSize
  * %c!{indexOfPar} => par
  * */

  if (text == null) return [];

  if (!text.startsWith("%*")) text = "%*n" + text;

  if (parameters != null)
    for (int i = 0; i < parameters.length; i++) {
      text = text.replaceAll("%c*$i", parameters[i]);
    }

  List<String> parts = text.split("%*").sublist(1);
  for (String part in parts) {
    String thePart = part;
    double fontSize = initialTextSize.toDouble();
    FontWeight fontWeight = FontWeight.normal;
    FontStyle fontStyle = FontStyle.normal;

    if (thePart[0] == 'b') {
      fontWeight = FontWeight.bold;
      thePart = thePart.substring(1);
    } else if (thePart[0] == 'l') {
      fontWeight = FontWeight.w300;
      fontStyle = FontStyle.italic;
      thePart = thePart.substring(1);
    } else if (thePart[0] == 'n') {
      fontWeight = FontWeight.normal;
      thePart = thePart.substring(1);
    }
    try {
      if (thePart.substring(0, 3) == '%s!') {
        String sizeInPx = '';
        for (String p in thePart.substring(3).split('')) {
          if (p == 'p') {
            break;
          } else {
            int k = int.parse(p);
            sizeInPx += k.toString();
          }
        }
        fontSize = int.parse(sizeInPx).toDouble();
        thePart = thePart.substring(4 + sizeInPx.length);
      }
    } catch (e) {
      if (e is NullThrownError) {
      } else {}
    }
    if (linksActivated && thePart.contains("http")) {
      String beforeLink = thePart.split("http")[0];
      spans.add(
        TextSpan(
          text: beforeLink,
          style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize,
            fontStyle: fontStyle,
          ),
        ),
      );
      for (int i = 1; i < thePart.split("http").length; i++) {
        String link = "http" + thePart.split("http")[i].split(" ")[0];
        String afterLink = "";
        for (String sub in thePart.split("http")[i].split(" ").sublist(1)) {
          afterLink += " " + sub;
        }
        spans.addAll([
          TextSpan(
            text: link,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
              color: Colors.blue,
              fontStyle: fontStyle,
            ),
            recognizer: new TapGestureRecognizer()..onTap = () => launch(link),
          ),
          TextSpan(
            text: afterLink,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
              fontStyle: fontStyle,
            ),
          ),
        ]);
      }
    } else {
      spans.add(
        TextSpan(
          text: thePart,
          style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize,
            fontStyle: fontStyle,
          ),
        ),
      );
    }
  }
  return spans.length == 0 ? [TextSpan(text: text)] : spans;
}
