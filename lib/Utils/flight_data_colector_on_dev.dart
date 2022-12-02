import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flight.dart';

class FlightDataCollector_on_dev extends StatelessWidget {
  FlightDataCollector_on_dev({Key? key}) : super(key: key);

  TextEditingController riserController = TextEditingController();
  TextEditingController bevelController = TextEditingController();
  TextEditingController bcdController = TextEditingController();

  FocusNode riserFocus = FocusNode();
  FocusNode bevelFocus = FocusNode();
  FocusNode bcdFocus = FocusNode();
  FocusNode tcdFocus = FocusNode();
  FocusNode nosFocus = FocusNode();
  //FocusNode riserFocus = FocusNode()

  // @override
  // void dispose() {
  //   riserFocus.dispose();
  //   bevelFocus.dispose();
  //   bcdFocus.dispose();
  //   tcdFocus.dispose();
  //   nosFocus.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    //final flightData = context.read<Flight>();
    return Column(
      children: [
        Input(
            controller: riserController,
            focus: riserFocus,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return "Please enter valid number";
              }
              return null;
            }),
        Input(
            controller: bevelController,
            focus: bevelFocus,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return "Please enter valid number";
              }
              return null;
            }),
        Input(
            controller: bcdController,
            focus: bcdFocus,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return "Please enter valid number";
              }
              return null;
            }),
      ],
    );
  }
}

class Input extends StatefulWidget {
  Input({
    Key? key,
    required this.controller,
    required this.validator,
    required this.focus,
  }) : super(key: key);

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final FocusNode focus;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  //FocusNode myFocus = FocusNode();
  @override
  void dispose() {}

  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.0,
      child: Focus(
        child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focus,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              isValid = widget.validator!(value) == null ? true : false;

              if (isValid) {
                return null;
              }
              return '';
            },
            onEditingComplete: () {}),
        onFocusChange: (value) {
          if (!isValid) {
            setState(() {

            widget.focus.requestFocus();
            });
          }
        },
      ),
    );
  }
}
