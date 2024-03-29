import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({super.key, required this.child, required this.onPressed});

  final Widget child;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        width: 92,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xEEEEEEEE),
          borderRadius: BorderRadius.circular(5),
        ),
        child: child,
      ),
    );
  }
}
