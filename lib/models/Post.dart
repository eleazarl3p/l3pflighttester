import 'package:flutter/cupertino.dart';

class Post {
  late String distance;
  late String initialValue;
  late String embeddedType;
  bool error = false;
  TextEditingController pController = TextEditingController(); // distance from post to previous post or starting point
  FocusNode pFocusNode = FocusNode();
  FocusNode buttonFocus = FocusNode();

  Post({required this.distance, required this.embeddedType}) {
    pController.text = distance.toString();
  }

  @override
  void dispose() {
    pController.dispose();
    buttonFocus.dispose();
    pFocusNode.dispose();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(distance: json['distance'], embeddedType: json['embeddedType']);
  }

  Map toJson() => {"distance": distance, "embeddedType": embeddedType};
}
