import 'package:flutter/material.dart';

TextStyle kLabelStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 1.5);

InputDecoration kInputDec = const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    border: OutlineInputBorder(),
    errorStyle: TextStyle(fontSize: 0.0),
    errorMaxLines: 1,
    fillColor: Colors.white,
    filled: true
  // disabledBorder: InputBorder.none
);
InputDecoration kInputDecDisable = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    border: const OutlineInputBorder(),
    errorStyle: const TextStyle(fontSize: 0.0),
    errorMaxLines: 1,
    fillColor: Colors.blueGrey.shade50,
    filled: true
  // disabledBorder: InputBorder.none
);
Color kColorDisable = Colors.blueGrey.shade100;