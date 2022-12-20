import 'package:flutter/cupertino.dart';

class BalusterPost {
  late String nosingDistance;
  late String balusterDistance;
  late String embeddedType;
  late int step;
  bool stepError = false;
  bool noseError = false;
  bool balusterError = false;
  final FocusNode stepFocus = FocusNode();
  final FocusNode balusterFocus = FocusNode();
  final FocusNode noseFocus = FocusNode();

  TextEditingController noseController = TextEditingController();
  TextEditingController balusterController = TextEditingController();
  TextEditingController stepController = TextEditingController();

  //late int? stair;
  BalusterPost(
      {required this.nosingDistance, required this.balusterDistance, required this.embeddedType, required this.step}) {
    noseController.text = nosingDistance.toString();
    balusterController.text = balusterDistance.toString();
    stepController.text = step.toString();
  }

  @override
  void dispose() {
    balusterController.dispose();
    stepFocus.dispose();
    balusterFocus.dispose();
    noseFocus.dispose();
  }

  Map toJson() => {
        "nosingDistance": nosingDistance,
        "balusterDistance": balusterDistance,
        "embeddedType": embeddedType,
        "step": step
      };

  factory BalusterPost.fromJson(Map<String, dynamic> json) {
    return BalusterPost(
        nosingDistance: json['nosingDistance'],
        balusterDistance: json['balusterDistance'],
        embeddedType: json['embeddedType'],
        step: json['step']);
  }
}
