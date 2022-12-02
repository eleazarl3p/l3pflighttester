import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'flight.dart';

class FlightMap extends ChangeNotifier {
  // late String _inputOne = "";
  // late final String _inputTwo = '';

  late final Map _textFormFields = {
    'id': '0',
    "riser": '6.6875', //
    "bevel": '7.3125',
    "topCrotch": false,
    //"topCrotchHeight": '8.0',
    "topCrotchLength": '0.0',
    "bottomCrotch": false,
    //"bottomCrotchHeight": '8.0',
    //"btmError": false,
    //"upFlatError": false,
    "bottomCrotchLength": '0.0',
    //'bottomCrotchTextEnable': true,
    "lowerFlatPost": <Post>[
      //Post(distance: 5.0, embeddedType: 'none')
    ], //Post(distance: 10.0, embeddedType: 'sleeve')
    "rampPost": <
        RampPost>[], //RampPost(nosingDistance: 0.0, balusterDistance: 0.0, embeddedType: 'none', step: 5)
    "upperFlatPost": <Post>[
      //Post(distance: 6.0, embeddedType: 'none')
    ], //Post(distance: 10.0, embeddedType: 'none')
    "stairsCount": '18',

    "currentFocus": FocusNode(),
    //'bottomFlatPostEnable': true,
    'active': true,
    'enableBtn': true,
    'hasBottomCrotchPost': false
  };
  get textFormFields => _textFormFields;

  void updateFields(key, value) {
    _textFormFields[key] = value;

    notifyListeners();
  }

  void updateMap(Flight obj) {
    _textFormFields['riser'] = obj.riser.toString();
    _textFormFields['bevel'] = obj.bevel.toString();
    _textFormFields['topCrotch'] = obj.topCrotch;
    _textFormFields['topCrotchLength'] = obj.topCrotchDistance.toString();
    _textFormFields['bottomCrotch'] = obj.bottomCrotch;
    _textFormFields['bottomCrotchLength'] = obj.bottomCrotchDistance.toString();
    _textFormFields['lowerFlatPost'] = [...obj.bottomPostList];
    _textFormFields['rampPost'] = [...obj.rampPostList];
    _textFormFields['upperFlatPost'] = obj.topPostList;
    _textFormFields['hasBottomCrotchPost'] = obj.bottomCrotchPost;
    _textFormFields['stairsCount'] = obj.numberOfSteps.toString();
    _textFormFields['id'] = obj.id.toString();

    notifyListeners();
  }

}

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

class FlatPostTable extends StatefulWidget {
  FlatPostTable({
    super.key,
    required this.postList,
    required this.flatposition,
    required this.resetView,
    required this.alphabet,
    this.enableLosBtn = true,
  });

  late List<Post> postList;
  final String flatposition; // bottom or up
  final VoidCallback resetView;
  final List alphabet;
  bool enableLosBtn;
  //late FocusNode upFocus;

  @override
  State<FlatPostTable> createState() => _FlatPostTableState();
}

class _FlatPostTableState extends State<FlatPostTable> {
  late TextEditingController controller = TextEditingController();
  late List<Post> itemList;
  late List<Post> lowerFlatPostList;
  late double crotchDistance;
  late bool crotch;
  late String side;
  late String initialLabel;
  bool distError = false;
  late bool _enableBtn;
  double postDistance = 0;

  //late bool distError;
  //late FocusNode actualFocus;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //actualFocus.dispose();
    super.dispose();
  }

  bool showRow = true;
  @override
  Widget build(BuildContext context) {
    final userInputsProvider = context.watch<FlightMap>();
    itemList = userInputsProvider.textFormFields[widget.flatposition];
    //actualFocus = userInputsProvider.textFormFields['currentFocus'];
    //postDistance = 0;
    _enableBtn =
        userInputsProvider.textFormFields['enableBtn']; //widget.enableLosBtn;

    //userInputsProvider.textFormFields['enableBtn'];
    //print('post enable ${widget.enableLosBtn}');

    if (widget.flatposition == 'lowerFlatPost') {
      side = 'bottom';
      initialLabel = 'B';
      crotchDistance =
          double.parse(userInputsProvider.textFormFields['bottomCrotchLength']);
      //distError = userInputsProvider.textFormFields['btmError'];
      if (userInputsProvider.textFormFields['bottomCrotch']) {
        crotch = true;
      } else {
        crotch = false;
      }
    } else {
      crotchDistance =
          double.parse(userInputsProvider.textFormFields['topCrotchLength']);
      side = 'up';
      initialLabel = 'U';
      //distError = userInputsProvider.textFormFields['upFlatError'];

      if (userInputsProvider.textFormFields['topCrotch']) {
        crotch = true;
      } else {
        crotch = false;
      }
    }

    List<DataColumn> _createColumns() {
      return [
        const DataColumn(
            label: Text(
                "Distance\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}")),
        const DataColumn(label: Text('Embed\u{00A0}Type')),
        const DataColumn(label: Text(''))
      ];
    }

    Widget buildPTable() {
      return DataTable(
        columns: _createColumns(),
        rows: showRow ? _createRows(userInputsProvider) : [],
        columnSpacing: 40,
      );
    }

    //widget.currenContext = context;

    return Card(child: SizedBox(width: 350, child: buildPTable()));
  }

  List<DataRow> _createRows(FlightMap userInputsProvider) {
    Color _color = Colors.white;
    String _label = 'Unfocused';
    double sumDistance = 0.0;
    return List<DataRow>.generate(
      itemList.length,
      (index) => DataRow(cells: [
        DataCell(
          SizedBox(
            width: 100.0,
            child: Focus(
              child: TextFormField(
                focusNode: itemList[index].pFocusNode,
                controller: itemList[index].pController,
                decoration: InputDecoration(
                    label: Text("$initialLabel${index + 1}"),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0)),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      value.isEmpty) {
                    itemList[index].error = true;
                    return '';
                  }

                  if (crotch) {
                    List sublista = itemList.sublist(0, index + 1);
                    sumDistance = sublista.fold(
                        0,
                        (sum, element) =>
                            sum.toDouble() +
                            double.parse(element.pController.text));

                    double.parse(value);
                    if (sumDistance >= crotchDistance &&
                        double.parse(value) != 0) {
                      itemList[index].error = true;
                      return "";
                    }
                  }

                  itemList[index].error = false;
                  return null;
                }),
                onTap: (() {
                  itemList[index].pController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset:
                          itemList[index].pController.value.text.length);
                }),
                onEditingComplete: () {},
              ),
              onFocusChange: (value) {
                // if (_enable) {
                if (!value) {
                  if (!itemList[index].error) {
                    itemList[index].distance =
                        double.parse(itemList[index].pController.text);
                    userInputsProvider.updateFields(
                        widget.flatposition, itemList);
                  } else {
                    itemList[index].pFocusNode.requestFocus();
                  }
                } else {
                  //itemList[index].pFocusNode.requestFocus();
                }
              },
            ),
          ),
        ),
        DataCell(
          DropdownButton(
            isExpanded: false,
            items: const [
              DropdownMenuItem(
                value: "none",
                child: Text("None"),
              ),
              DropdownMenuItem(
                value: "plate",
                child: Text("Plate"),
              ),
              DropdownMenuItem(
                value: "sleeve",
                child: Text("Sleeve"),
              )
            ],
            value: itemList[index].embeddedType,
            onChanged: !_enableBtn
                ? null
                : (String? value) {
                    if (value is String) {
                      setState(() {
                        itemList[index].embeddedType = value;
                        userInputsProvider.updateFields(
                            widget.flatposition, itemList);
                      });
                      //widget.resetView();
                    }
                  },
          ),
        ),
        DataCell(TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black)),
            onPressed: !_enableBtn //&& !itemList[index].pFocusNode.hasFocus
                ? null
                : () {
                    //itemList[index].pController.text = '2';
                    itemList.removeAt(index);

                    userInputsProvider.updateFields(
                        widget.flatposition, itemList);
                    //widget.resetView();
                  },
            child: const Icon(Icons.delete)))
      ]),
    );
  }
}

class Post {
  late double distance;
  late String initialValue;
  late String embeddedType;
  bool error = false;
  TextEditingController pController =
      TextEditingController(); // distance from post to previous post or starting point
  FocusNode pFocusNode = FocusNode();
  FocusNode buttonFocuse = FocusNode();

  Post({required this.distance, required this.embeddedType}) {
    pController.text = distance.toString();
  }

  // @override
  // void initState() {
  //   pController.text = initialValue;
  // }
  @override
  void dispose() {
    pController.dispose();
    buttonFocuse.dispose();
    pFocusNode.dispose();
  }

  valid(
      String? value, bool crotch, List itemList, crotchDistance, String side) {
    if (value!.isEmpty || double.tryParse(value) == null) {
      error = true;
      return "";
    } else if (crotch) {
      double sumDistance = itemList.fold(
          0,
          (sum, element) =>
              sum.toDouble() + double.parse(element.pController.text));

      if (crotchDistance - sumDistance <= 0) {
        error = true;

        return "";
        //dialogAlerta(title: "Unable to add Post", msj: "Please review bottom crotch distance,\nand try again.");
      } else {
        distance = double.parse(value);
        error = false;
        return null;
      }
    } else {
      distance = double.parse(value);
      error = false;
      return null;
    }
  }

  Map toJson() => {"distance": distance, "embeddedType": embeddedType};
}

// ***************************************** Ramp Post ********************************************

class RampPostTable extends StatefulWidget {
  RampPostTable(
      {super.key,
      required this.postList,
      required this.resetView,
      required this.enableLosBtn});

  late List<RampPost> postList;
  final VoidCallback resetView;
  late bool enableLosBtn;

  @override
  State<RampPostTable> createState() => _RampPostTableState();
}

class _RampPostTableState extends State<RampPostTable> {
  late List<RampPost> itemList;
  late int numStep;
  late bool _enable;

  late FocusNode curFocus;

  bool noseDistanceError = false;
  bool balusterError = false;

  @override
  void initState() {
    super.initState();
    curFocus = FocusNode();
  }

  @override
  void dispose() {
    curFocus.dispose();
    super.dispose();
  }

  bool showRow = true;
  @override
  Widget build(BuildContext context) {
    final userInputsProvider = context.read<FlightMap>();
    itemList = userInputsProvider.textFormFields['rampPost'];
    numStep = int.parse(userInputsProvider.textFormFields['stairsCount']);
    _enable = widget.enableLosBtn;

    //userInputsProvider.textFormFields['active'];

    List<String> minAlphabet =
        List.generate(26, (index) => String.fromCharCode(index + 65));
    //curFocus = userInputsProvider.textFormFields['currentFocus'];



    Widget buildPTable() {
      final columns = [
        const Text("Nosing"),
        const Text("Thread"),
        const Text("Stair\u{00A0}\u{00A0}"),
        TextButton(
            onPressed: () {
              showRow = !showRow;
              setState(() {});
            },
            child: showRow
                ? const Icon(
                    Icons.close_outlined,
                  )
                : const Icon(Icons.remove_red_eye_outlined))
      ];
      return DataTable(
        columns: const [
          DataColumn(
              label: Text(
                  "Dist.\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}")),
          DataColumn(
              label: Text(
                  'Bal.\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}')),
          DataColumn(label: Text("Step\u{00A0}\u{00A0}\u{00A0}#\u{00A0}")),
          DataColumn(label: Text("Emb.\u{00A0}Type")),
          DataColumn(label: Text(''))
        ],
        rows: showRow
            ? List<DataRow>.generate(
                itemList.length,
                (index) => DataRow(cells: [
                      DataCell(
                        // nosing
                        SizedBox(
                          width: 50.0,
                          //height: 40,
                          child: Focus(
                            child: TextFormField(
                              focusNode: itemList[index].noseFocus,
                              controller: itemList[index].noseController,
                              decoration: InputDecoration(
                                  label: Text(minAlphabet.removeAt(0)),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0)),
                              autofocus: true,
                              autocorrect: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: ((value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value) == null ||
                                    double.parse(value) < 0) {
                                  itemList[index].noseError = true;

                                  return '';
                                }
                                itemList[index].noseError = false;
                                itemList[index].nosingDistance =
                                    double.parse(value);
                                return null;
                              }),
                              onTap: () =>
                                  itemList[index].noseController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: itemList[index]
                                              .noseController
                                              .value
                                              .text
                                              .length),
                            ),
                            onFocusChange: (value) {
                              if (!value) {
                                nodeDistanceValidator(userInputsProvider);
                              } else {
                                itemList[index].noseController.selection =
                                    TextSelection(
                                        baseOffset: 0,
                                        extentOffset: itemList[index]
                                            .noseController
                                            .value
                                            .text
                                            .length);
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        // baluster
                        SizedBox(
                          width: 50.0,
                          // height: 450,
                          child: Focus(
                            child: TextFormField(
                              controller: itemList[index].balusterController,
                              focusNode: itemList[index].balusterFocus,
                              decoration: const InputDecoration(
                                  //helperText: ' ',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0)),
                              //autofocus: true,
                              autocorrect: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: ((value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value) == null ||
                                    value.isEmpty ||
                                    double.parse(value) < 0) {
                                  itemList[index].balusterError = true;
                                  return '';
                                }
                                itemList[index].balusterError = false;
                                itemList[index].balusterDistance =
                                    double.parse(value);

                                return null;
                              }),
                              onTap: () =>
                                  itemList[index].balusterController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: itemList[index]
                                              .balusterController
                                              .value
                                              .text
                                              .length),
                              // onEditingComplete: () {
                              //   balusterDistanceValidator(userInputsProvider);
                              // },
                            ),
                            onFocusChange: (value) {
                              if (!value) {
                                balusterDistanceValidator(userInputsProvider);
                              } else {
                                itemList[index].balusterController.selection =
                                    TextSelection(
                                        baseOffset: 0,
                                        extentOffset: itemList[index]
                                            .balusterController
                                            .value
                                            .text
                                            .length);
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        // step
                        SizedBox(
                          width: 50.0,
                          // height: 450,
                          child: Focus(
                            child: TextFormField(
                              focusNode: itemList[index].stepFocus,
                              controller: itemList[index].stepController,
                              decoration: const InputDecoration(
                                  //helperText: ' ',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0)),
                              //autofocus: true,
                              autocorrect: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: ((value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) >= numStep ||
                                    int.parse(value) < 0) {
                                  itemList[index].stepError = true;
                                  return '';
                                }
                                itemList[index].stepError = false;
                                itemList[index].step = int.parse(value);

                                return null;
                              }),
                              onTap: () =>
                                  itemList[index].stepController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: itemList[index]
                                              .stepController
                                              .value
                                              .text
                                              .length),
                              // onEditingComplete: () {
                              //   stepValidator(userInputsProvider);
                              // },
                            ),
                            onFocusChange: (value) {
                              if (!value) {
                                stepValidator(userInputsProvider);
                              } else {
                                itemList[index].stepController.selection =
                                    TextSelection(
                                        baseOffset: 0,
                                        extentOffset: itemList[index]
                                            .stepController
                                            .value
                                            .text
                                            .length);
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text("None"),
                          ),
                          DropdownMenuItem(
                            value: 'plate',
                            child: Text("Plate"),
                          ),
                          DropdownMenuItem(
                            value: 'sleeve',
                            child: Text("Sleeve"),
                          ),
                        ],
                        value: itemList[index].embeddedType.toString(),
                        onChanged: !_enable
                            ? null
                            : (String? value) {
                                if (value is String) {
                                  setState(() {
                                    itemList[index].embeddedType = value;
                                    userInputsProvider.updateFields(
                                        'rampPost', itemList);
                                  });

                                  //widget.resetView();
                                }
                              },
                      )),
                      DataCell(SizedBox(
                        width: 30.0,
                        child: TextButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            // style: ElevatedButton.styleFrom(
                            //   backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                            //   foregroundColor: Colors.black,
                            //   elevation: 0.0,
                            // ),
                            onPressed:
                                _enable // userInputsProvider.textFormFields['active']
                                    ? () {
                                        setState(() {
                                          itemList.removeAt(index);
                                          userInputsProvider.updateFields(
                                              'rampPost', itemList);
                                        });
                                        //widget.resetView();
                                      }
                                    : null,
                            child: const Icon(
                              Icons.delete,
                            )),
                      )),
                    ]))
            : [],
        columnSpacing: 12.0,
        horizontalMargin: 10.0,
      );
    }

    return Card(child: SizedBox(width: 450.0, child: buildPTable()));
  }

  void stepValidator(FlightMap userInputsProvider) {
    bool _error = false;
    for (RampPost item in itemList) {
      if (item.stepError) {
        item.stepFocus.requestFocus();
        _error = true;
        break;
      }
    }

    if (!_error) {
      var seen = <String>{}; // remove duplicate step
      List<RampPost> filteredList = itemList
          .where((element) => seen.add(element.step.toString()))
          .toList();

      setState(() {
        userInputsProvider.updateFields('rampPost', filteredList);
      });

      //widget.resetView();
    }
  }

  void nodeDistanceValidator(FlightMap userInputsProvider) {
    bool _error = false;
    for (RampPost item in itemList) {
      if (item.noseError) {
        item.noseFocus.requestFocus();
        _error = true;
        break;
      }
    }
    if (!_error) {
      userInputsProvider.updateFields('rampPost', itemList);

      //widget.resetView();
    }
  }

  void balusterDistanceValidator(FlightMap userInputsProvider) {
    bool _error = false;
    for (RampPost item in itemList) {
      if (item.balusterError) {
        item.balusterFocus.requestFocus();
        _error = true;
        break;
      }
    }
    if (!_error) {
      userInputsProvider.updateFields('rampPost', itemList);

      //widget.resetView();
    }
  }
}

class RampPost {
  late double nosingDistance;
  late double balusterDistance;
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
  RampPost(
      {required this.nosingDistance,
      required this.balusterDistance,
      required this.embeddedType,
      required this.step}) {
    noseController.text = nosingDistance.toString();
    balusterController.text = balusterController.toString();
    stepController.text = step.toString();

    // @override
    // void initState() {
    //   stepFocus = FocusNode();
    //   balusterFocus = FocusNode();
    //   noseFocus = FocusNode();
    // }
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
}

