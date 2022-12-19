import 'package:flutter/material.dart';

class CustomIconActionButton extends StatelessWidget {
  const CustomIconActionButton({super.key, required this.child, required this.onPressed, required this.color});

  final Widget child;
  final Function() onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      fillColor: color,
      constraints: const BoxConstraints.tightFor(width: 35.0, height: 35.0),
      elevation: 0.0,

      // focusColor: Colors.blueGrey,
      splashColor: Colors.blueGrey,
      child: child,
      //(
      // alignment: Alignment.center,
      // //margin: const EdgeInsets.only(left: 40.0),
      // width: 35,
      // height: 35,
      // decoration: boxDecoration,
      //// child: Center(child: child),
      ///),
    );
  }
}
