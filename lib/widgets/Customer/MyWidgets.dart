
import 'package:flutter/material.dart';

Widget textWidget({ required String text, TextStyle? style, TextAlign? textAlign, TextOverflow? overflow, int? maxLines,})
{
  return Text(
    text,
    style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
  );
}