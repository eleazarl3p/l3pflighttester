import 'package:flutter/cupertino.dart';

import 'flight_map.dart';
//

class Flight extends ChangeNotifier {
  String id;

  double riser;
  double bevel;
  double topCrotchDistance;
  double bottomCrotchDistance;

  bool topCrotch;
  bool bottomCrotch;
  bool bottomCrotchPost;
  bool topCrotchPost;
  bool onHold;

  int stepsCount;

  double lastNoseDistance;

  double hypotenuse;

  List<Post> lowerFlatPost = [];

  List<Post> upperFlatPost = [];
  List<RampPost> rampPostList = [];
  TextEditingController controller = TextEditingController();

  Flight({
    this.id = '',
    this.riser = 6.7835,
    this.bevel = 7.3154,
    this.topCrotch = false,
    this.topCrotchDistance = 0.0,
    this.topCrotchPost = false,
    this.bottomCrotch = true,
    this.bottomCrotchDistance = 0.0,
    this.bottomCrotchPost = false,
    this.stepsCount = 15,
    this.lastNoseDistance = 193.1625,
    // this.lowerFlatPost = [],
    // this.rampPostList =  <RampPost>[],
    // this.upperFlatPost = const <Post>[],
    this.onHold = true,
    this.hypotenuse = 12.8575,
  });

  factory Flight.copy(Flight obj) {
    Flight fl = Flight(
      id: obj.id,
      riser: obj.riser,
      bevel: obj.bevel,
      topCrotch: obj.topCrotch,
      topCrotchDistance: obj.topCrotchDistance,
      bottomCrotch: obj.bottomCrotch,
      bottomCrotchDistance: obj.bottomCrotchDistance,
      bottomCrotchPost: obj.bottomCrotchPost,
      //stepsCount: obj.stepsCount,
      lastNoseDistance: obj.lastNoseDistance,
      // lowerFlatPost: obj.lowerFlatPost,
      // rampPostList: obj.rampPostList,
      // upperFlatPost: obj.upperFlatPost
    );
    fl.controller.text = obj.id;
    fl.lowerFlatPost = [
      ...obj.lowerFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()
    ];
    fl.rampPostList = [
      ...obj.rampPostList
          .map((item) => RampPost(
              nosingDistance: item.nosingDistance,
              balusterDistance: item.balusterDistance,
              embeddedType: item.embeddedType,
              step: item.step))
          .toList()
    ];
    fl.upperFlatPost = [
      ...obj.upperFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()
    ];
    // fl.lowerFlatPost = [...obj.lowerFlatPost];
    // fl.rampPostList = [...obj.rampPostList];
    // fl.upperFlatPost = [...obj.upperFlatPost];
    return fl;
  }

  void updateFlight(Map flt) {
    riser = double.parse(flt['riser']);
    bevel = double.parse(flt['bevel']);
    topCrotchDistance = double.parse(flt['topCrotchLength']);
    bottomCrotchDistance = double.parse(flt['bottomCrotchLength']);

    topCrotch = flt['topCrotch'];
    bottomCrotch = flt['bottomCrotch'];
    bottomCrotchPost = flt['hasBottomCrotchPost'];
    stepsCount = int.parse(flt['stairsCount']);

    lowerFlatPost = flt['lowerFlatPost'];
    rampPostList = flt['rampPost'];
    upperFlatPost = flt['upperFlatPost'];
    notifyListeners();
  }

  Map toJson() {
    List<Map> bottomPosts = lowerFlatPost.map((e) => e.toJson()).toList();
    List<Map> topPosts = upperFlatPost.map((e) => e.toJson()).toList();
    List<Map> rampPosts = rampPostList.map((e) => e.toJson()).toList();

    return {
      "id": id,
      "riser": riser,
      "bevel": bevel,
      "topCrotchDistance": topCrotchDistance,
      "bottomCrotchDistance": bottomCrotchDistance,
      "topCrotch": topCrotch,
      "bottomCrotch": bottomCrotch,
      "bottomCrotchPost": bottomCrotchPost,
      //"stepsCount": stepsCount,
      "lowerFlatPost": bottomPosts,
      "upperFlatPost": topPosts,
      "rampPost": rampPosts,
      "lastNoseDistance": lastNoseDistance
    };
  }

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
        id: json['id'],
        riser: json['riser'],
        bevel: json['bevel'],
        topCrotch: json['topCrotch'],
        topCrotchDistance: json['topCrotchDistance'],
        bottomCrotch: json['bottomCrotch'],
        bottomCrotchDistance: json['bottomCrotchDistance'],
        bottomCrotchPost: json['bottomCrotchPost'],
        lastNoseDistance: json['lastNoseDistance']
        //stepsCount: json['stepsCount'],
        // lowerFlatPost: obj.lowerFlatPost,
        // rampPostList: obj.rampPostList,
        // upperFlatPost: obj.upperFlatPost);
        );
  }

  Map<String, dynamic> template() => {
        'id': id.toString(),
        "riser": riser.toString(), //
        "bevel": bevel.toString(),

        "topCrotch": topCrotch,
        "topCrotchLength": topCrotchDistance.toString(),
        'hasBottomCrotchPost': topCrotchPost,

        "bottomCrotch": bottomCrotch,
        "bottomCrotchLength": bottomCrotchDistance.toString(),
        'hasTopCrotchPost': bottomCrotchPost,

        "lowerFlatPost": lowerFlatPost,
        "rampPost": rampPostList,
        "upperFlatPost": upperFlatPost,
        //"stepsCount": stepsCount.toString(),
        "lastNoseDistance": lastNoseDistance.toString(),
        'hypotenuse': hypotenuse
      };

  void updateFl(Map<String, dynamic> template) {
    id = template['id'];
    riser = double.parse(template["riser"]); //
    bevel = double.parse(template["bevel"]);

    topCrotch = template['topCrotch'];
    topCrotchDistance = double.parse(template['topCrotchLength']);
    topCrotchPost = template['hasBottomCrotchPost'];

    bottomCrotch = template['bottomCrotch'];
    bottomCrotchDistance = double.parse(template['bottomCrotchLength']);
    bottomCrotchPost = template['hasTopCrotchPost'];

    lowerFlatPost = [...template['lowerFlatPost']];
    rampPostList = [...template['rampPost']];
    upperFlatPost = [...template['upperFlatPost']];
    //stepsCount = template['hasTopCrotchPost'];
    lastNoseDistance = double.parse(template['lastNoseDistance']);

    notifyListeners();
  }
}

class PostObj {}

class RampPostObj {}
