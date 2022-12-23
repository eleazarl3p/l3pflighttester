import 'package:flutter/cupertino.dart';

import 'BalusterPost.dart';
import 'Post.dart';

//

class Flight extends ChangeNotifier {
  String id;

  String riser;
  String bevel;
  String topCrotchDistance;
  String bottomCrotchDistance;
  String lastNoseDistance;
  String topCrotchEmbeddedType = 'none';
  String bottomCrotchEmbeddedType = 'none';

  bool topCrotch;
  bool bottomCrotch;
  bool bottomCrotchPost;
  bool topCrotchPost;

  //bool onHold;

  int stepsCount;

  double hypotenuse;

  List<Post> lowerFlatPost = [];

  List<Post> upperFlatPost = [];
  List<BalusterPost> balusters = [];
  TextEditingController controller = TextEditingController();

  Flight({
    this.id = '',
    this.riser = "6.7835",
    this.bevel = "7.3154",
    this.topCrotch = false,
    this.topCrotchDistance = "100.0",
    this.topCrotchPost = false,
    this.bottomCrotch = false,
    this.bottomCrotchDistance = "100.0",
    this.bottomCrotchPost = false,
    this.stepsCount = 15,
    this.lastNoseDistance = "193.1625",
    // this.lowerFlatPost = [],
    // this.balustersList =  <balusters>[],
    // this.upperFlatPost = const <Post>[],
    //this.onHold = true,
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
      // balustersList: obj.balustersList,
      // upperFlatPost: obj.upperFlatPost
    );
    fl.bottomCrotchEmbeddedType = obj.bottomCrotchEmbeddedType;
    fl.topCrotchEmbeddedType = obj.topCrotchEmbeddedType;
    fl.controller.text = obj.id;
    fl.lowerFlatPost = [...obj.lowerFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()];
    fl.balusters = [
      ...obj.balusters
          .map((item) => BalusterPost(
              nosingDistance: item.nosingDistance, balusterDistance: item.balusterDistance, embeddedType: item.embeddedType, step: item.step))
          .toList()
    ];
    fl.upperFlatPost = [...obj.upperFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()];
    // fl.lowerFlatPost = [...obj.lowerFlatPost];
    // fl.balustersList = [...obj.balustersList];
    // fl.upperFlatPost = [...obj.upperFlatPost];
    return fl;
  }

  // void updateFlight(Map flt) {
  //   riser = double.parse(flt['riser']);
  //   bevel = double.parse(flt['bevel']);
  //   topCrotchDistance = double.parse(flt['topCrotchLength']);
  //   bottomCrotchDistance = double.parse(flt['bottomCrotchLength']);
  //
  //   topCrotch = flt['topCrotch'];
  //   bottomCrotch = flt['bottomCrotch'];
  //   bottomCrotchPost = flt['hasBottomCrotchPost'];
  //   stepsCount = int.parse(flt['stairsCount']);
  //
  //   lowerFlatPost = flt['lowerFlatPost'];
  //   balusters = flt['balusters'];
  //   upperFlatPost = flt['upperFlatPost'];
  //   notifyListeners();
  // }

  Map toJson() {
    List<Map> bottomPosts = lowerFlatPost.map((e) => e.toJson()).toList();
    List<Map> topPosts = upperFlatPost.map((e) => e.toJson()).toList();
    List<Map> balustersP = balusters.map((e) => e.toJson()).toList();

    return {
      "id": id,
      "riser": riser,
      "bevel": bevel,
      "topCrotchDistance": topCrotchDistance,
      "bottomCrotchDistance": bottomCrotchDistance,
      "topCrotch": topCrotch,
      "bottomCrotch": bottomCrotch,
      "bottomCrotchPost": bottomCrotchPost,
      "bottomCrotchEmbeddedType": bottomCrotchEmbeddedType,
      "topCrotchEmbeddedType": topCrotchEmbeddedType,
      //"stepsCount": stepsCount,
      "lowerFlatPost": bottomPosts,
      "upperFlatPost": topPosts,
      "balusters": balustersP,
      "lastNoseDistance": lastNoseDistance
    };
  }

  factory Flight.fromJson(Map<String, dynamic> json) {
    Flight fjs = Flight(
      id: json['id'],
      riser: json['riser'],
      bevel: json['bevel'],
      topCrotch: json['topCrotch'],
      topCrotchDistance: json['topCrotchDistance'],
      bottomCrotch: json['bottomCrotch'],
      bottomCrotchDistance: json['bottomCrotchDistance'],
      bottomCrotchPost: json['bottomCrotchPost'],
      lastNoseDistance: json['lastNoseDistance'],
    );

    fjs.bottomCrotchEmbeddedType = json['bottomCrotchEmbeddedType'];
    fjs.topCrotchEmbeddedType = json['topCrotchEmbeddedType'];

    for (var bp in json['lowerFlatPost']) {
      fjs.lowerFlatPost.add(Post(distance: bp['distance'], embeddedType: bp['embeddedType']));
    }

    for (var up in json['upperFlatPost']) {
      fjs.upperFlatPost.add(Post(distance: up['distance'], embeddedType: up['embeddedType']));
    }

    try {
      for (var bal in json['balusters']) {
        fjs.balusters.add(BalusterPost(
            nosingDistance: bal['nosingDistance'], balusterDistance: bal['balusterDistance'], embeddedType: bal['embeddedType'], step: bal['step']));
      }
    } catch (err) {}

    fjs.controller.text = json['id'];
    return fjs;
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
        "lowerFlatPost": [...lowerFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()],
        "balusters": [
          ...balusters
              .map((item) => BalusterPost(
                  nosingDistance: item.nosingDistance, balusterDistance: item.balusterDistance, embeddedType: item.embeddedType, step: item.step))
              .toList()
        ],

        "upperFlatPost": [...upperFlatPost.map((item) => Post(distance: item.distance, embeddedType: item.embeddedType)).toList()],

        //"stepsCount": stepsCount.toString(),
        "lastNoseDistance": lastNoseDistance.toString(),
        'hypotenuse': hypotenuse,
        "bottomCrotchEmbeddedType": bottomCrotchEmbeddedType,
        "topCrotchEmbeddedType": topCrotchEmbeddedType,
      };

  void updateFl(Map<String, dynamic> template) {
    id = template['id'];
    riser = template["riser"]; //
    bevel = template["bevel"];

    topCrotch = template['topCrotch'];
    topCrotchDistance = template['topCrotchLength'];
    topCrotchPost = template['hasBottomCrotchPost'];

    bottomCrotch = template['bottomCrotch'];
    bottomCrotchDistance = template['bottomCrotchLength'];
    bottomCrotchPost = template['hasTopCrotchPost'];

    lowerFlatPost = [...template['lowerFlatPost']];
    balusters = [...template['balusters']];
    upperFlatPost = [...template['upperFlatPost']];
    //stepsCount = template['hasTopCrotchPost'];
    lastNoseDistance = template['lastNoseDistance'];
    bottomCrotchEmbeddedType = template["bottomCrotchEmbeddedType"];
    topCrotchEmbeddedType = template["topCrotchEmbeddedType"];

    notifyListeners();
  }
}

class PostObj {}

// class balustersObj {}
