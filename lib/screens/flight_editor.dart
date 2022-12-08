import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l3pflighttester/screens/dibujo.dart';

// import '/models/project.dart';
// import 'package:provider/provider.dart';
// import '../models/Projects.dart';
// import '/Utils/flight_data_input.dart';
// import '/models/flight.dart';
//
// import '../Utils/cuadro.dart';
// import '../Utils/cuadro_on_dev.dart';
// import '../Utils/flight_data_input_on_dev.dart';
// import '../Utils/stair_painter.dart';
import '../models/flight_map.dart';

class FlightEditor extends StatefulWidget {
  FlightEditor({Key? key, required this.pIndex, required this.sIndex, required this.fIndex, this.cloud = false})
      : super(key: key);

  int pIndex;
  int sIndex;
  int fIndex;
  bool cloud;

  List k = ["None", "Plate", 'Tube'];
  List<Post> lowerPost = [
    // Post(distance: 20, embeddedType: "None"),
    // Post(distance: 20, embeddedType: "None"),
    // Post(distance: 20, embeddedType: "None")
  ];

  @override
  State<FlightEditor> createState() => _FlightEditorState();
}

class _FlightEditorState extends State<FlightEditor> {
  TextEditingController riserController = TextEditingController(text: '6.6875');
  TextEditingController bevelController = TextEditingController(text: '7.45');
  TextEditingController btcController = TextEditingController(text: '0.0');
  TextEditingController tcController = TextEditingController(text: '0.0');
  TextEditingController lowerPostQuantity = TextEditingController(text: '0');
  TextEditingController upperPostQuantity = TextEditingController(text: '0');
  TextEditingController rampPostQuantity = TextEditingController(text: '0');
  TextEditingController lastNoseDistance = TextEditingController(text: '216');

  FocusNode riserFocus = FocusNode();
  FocusNode bevelFocus = FocusNode();
  FocusNode btcFocus = FocusNode();
  FocusNode tcFocus = FocusNode();
  FocusNode lowerPostQFocus = FocusNode();
  FocusNode upperPostQFocus = FocusNode();
  FocusNode rampPostQFocus = FocusNode();
  FocusNode lastNoseDistFocus = FocusNode();
  // FocusNode riserFocus = FocusNode();
  int cp = 2;

  bool bottomFlatDistanceError = false;
  bool topFlatDistanceError = false;
  bool lowerQuantityError = false;
  bool upperQuantityError = false;
  bool rampQuantityError = false;
  bool lastNoseError = false;

  final Map _textFormFields = {
    'id': '0',
    "riser": '6.6875', //
    "bevel": '7.3125',

    "topCrotch": false,
    "topCrotchLength": '0.0',
    'hasBottomCrotchPost': false,

    "bottomCrotch": false,
    "bottomCrotchLength": '0.0',
    'hasTopCrotchPost': true,

    "lowerFlatPost": <Post>[
      //Post(distance: 5.0, embeddedType: 'none')
    ], //Post(distance: 10.0, embeddedType: 'sleeve')
    "rampPost": <RampPost>[], //RampPost(nosingDistance: 0.0, balusterDistance: 0.0, embeddedType: 'none', step: 5)
    "upperFlatPost": <Post>[Post(distance: 6.0, embeddedType: 'none')], //Post(distance: 10.0, embeddedType: 'none')
    "stairsCount": '15',

    "currentFocus": FocusNode(),
    //'bottomFlatPostEnable': true,
    'active': true,
    'enableBtn': true,
    'hypotenuse': 12.875,
  };

  InputDecoration inputDec = const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    border: OutlineInputBorder(),
    errorStyle: TextStyle(fontSize: 0.0),
    errorMaxLines: 1,
    // disabledBorder: InputBorder.none
  );

  @override
  void dispose() {
    riserController.dispose();
    bevelController.dispose();
    btcController.dispose();
    tcController.dispose();
    lowerPostQuantity.dispose();
    upperPostQuantity.dispose();
    rampPostQuantity.dispose();
    lastNoseDistance.dispose();

    riserFocus.dispose();
    bevelFocus.dispose();
    btcFocus.dispose();
    tcFocus.dispose();
    lowerPostQFocus.dispose();
    lastNoseDistFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String selectedItem;
    // int selectedItemPosition = 0;

    List<DataColumn> _createColumns() {
      return [
        const DataColumn(label: Text('Id')),
        const DataColumn(label: Expanded(child: SizedBox(width: 90, child: Text('Distance')))),
        const DataColumn(label: Text('Emb. Type')),
      ];
    }

    List<DataRow> _createRows({required bool crotch, required String campo, required double crotchDistance}) {
      double sumDistance = 0;
      return List<DataRow>.generate(
        _textFormFields[campo].length,
        (index) => DataRow(cells: [
          DataCell(Text('B${index + 1}')),
          DataCell(
            Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Focus(
                child: TextFormField(
                  focusNode: _textFormFields[campo][index].pFocusNode,
                  controller: _textFormFields[campo][index].pController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => _textFormFields[campo][index].pController.selection = TextSelection(
                      baseOffset: 0, extentOffset: _textFormFields[campo][index].pController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      _textFormFields[campo][index].error = true;
                      return '';
                    }

                    if (crotch) {
                      List sublista = _textFormFields[campo].sublist(0, index + 1);
                      sumDistance =
                          sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.pController.text));

                      if (sumDistance >= crotchDistance && double.parse(value) != 0) {
                        _textFormFields[campo][index].error = true;
                        return "";
                      }
                    }

                    _textFormFields[campo][index].error = false;
                    return null;
                  },
                  decoration: inputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!value) {
                    if (!_textFormFields[campo][index].error) {
                      _textFormFields[campo][index].distance =
                          double.parse(_textFormFields[campo][index].pController.text);
                    } else {
                      _textFormFields[campo][index].pFocusNode.requestFocus();
                    }
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
                value: _textFormFields[campo][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    _textFormFields[campo][index].embeddedType = value;
                  });
                }

                //widget.resetView();

                ),
          ),
        ]),
      );
    }

    Widget BuildTable({required bool crotch, required String campo, required double crotchDistance}) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DataTable(
            columns: _createColumns(),
            rows: _createRows(crotch: crotch, campo: campo, crotchDistance: crotchDistance),
            //columnSpacing: 20,
          ),
        ),
      );
    }

    List<DataRow> _rampRows({required int steps}) {
      double sumDistance = 0;
      return List<DataRow>.generate(
        _textFormFields['rampPost'].length,
        (index) => DataRow(cells: [
          DataCell(Text('B${index + 1}')),
          DataCell(
            Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Focus(
                child: TextFormField(
                  focusNode: _textFormFields['rampPost'][index].noseFocus,
                  controller: _textFormFields['rampPost'][index].noseController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => _textFormFields['rampPost'][index].noseController.selection = TextSelection(
                      baseOffset: 0, extentOffset: _textFormFields['rampPost'][index].noseController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      _textFormFields['rampPost'][index].noseError = true;
                      return '';
                    }

                    // List sublista = _textFormFields['ramPost'].sublist(0, index + 1);
                    // sumDistance =
                    //     sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.noseController.text));
                    double noseValue = double.parse(value);
                    if (noseValue >= double.parse(lastNoseDistance.text)) {
                      _textFormFields['rampPost'][index].noseError = true;
                      return "";
                    }

                    _textFormFields['rampPost'][index].noseError = false;
                    _textFormFields['rampPost'][index].step = noseValue ~/ _textFormFields['hypotenuse'];
                    _textFormFields['rampPost'][index].nosingDistance = double.parse(value);
                    return null;
                  },
                  decoration: inputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!value) {
                    if (_textFormFields['rampPost'][index].noseError) {
                      _textFormFields['rampPost'][index].noseFocus.requestFocus();
                    }
                  }
                },
              ),
            ),
          ),
          DataCell(
            Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Focus(
                child: TextFormField(
                  focusNode: _textFormFields['rampPost'][index].balusterFocus,
                  controller: _textFormFields['rampPost'][index].balusterController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => _textFormFields['rampPost'][index].balusterController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _textFormFields['rampPost'][index].balusterController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      _textFormFields['rampPost'][index].balusterError = true;
                      return '';
                    }

                    // List sublista = _textFormFields['ramPost'].sublist(0, index + 1);
                    // sumDistance =
                    //     sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.noseController.text));
                    double noseValue = double.parse(value);
                    if (noseValue >= 10) {
                      _textFormFields['rampPost'][index].balusterError = true;
                      return "";
                    }

                    _textFormFields['rampPost'][index].balusterError = false;
                    _textFormFields['rampPost'][index].balusterDistance = double.parse(value);

                    return null;
                  },
                  decoration: inputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!value) {
                    if (_textFormFields['rampPost'][index].balusterError) {
                      _textFormFields['rampPost'][index].balusterFocus.requestFocus();
                    }
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
                value: _textFormFields['rampPost'][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    _textFormFields['rampPost'][index].embeddedType = value;
                  });
                }

                //widget.resetView();

                ),
          ),
        ]),
      );
    }

    Widget RampPostTable({required int steps}) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DataTable(
            columnSpacing: 10.0,
            columns: const [
              DataColumn(label: Text('Id')),
              DataColumn(label: Expanded(child: SizedBox(width: 80, child: Text('Distance')))),
              DataColumn(label: Expanded(child: SizedBox(width: 80, child: Text('Baluster')))),
              DataColumn(label: Text('Emb. Type')),
            ],
            rows: _rampRows(steps: steps),
            //columnSpacing: 20,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Text(''),
        title: ListTile(
          title: const Text('Flight'
              //'Flight : ${Provider.of<Projects>(context).projects[pIndex].stairs[sIndex].flights[fIndex].id}',
              //style: const TextStyle(color: Colors.white),
              ),
          subtitle: widget.cloud
              ? const Text('Cloud > Project > Stair > FLight', style: TextStyle(color: Colors.white))
              : const Text('Local > Projects > Stair > FLight', style: TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dibujo(_textFormFields)));
            },
            child: Container(
              width: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60.0)),
              child: const Icon(Icons.stairs_outlined),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: () {},
            child: Container(
              width: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: ListView(children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 10,
                        runSpacing: 20,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              MyTableCol(name: 'Riser'),
                              MyTableCell(
                                Focus(
                                  child: TextFormField(
                                    focusNode: riserFocus,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: riserController,
                                    validator: (value) {
                                      if (double.tryParse(value!) == null) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    onTap: () => riserController.selection =
                                        TextSelection(baseOffset: 0, extentOffset: riserController.value.text.length),
                                    keyboardType: TextInputType.phone,
                                    decoration: inputDec,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onFocusChange: (value) {
                                    if (!value) {
                                      if (double.tryParse(riserController.text) == null) {
                                        riserFocus.requestFocus();
                                      } else {
                                        _textFormFields['riser'] = riserController.text;
                                        double hypotenuse = sqrt(121 + pow(double.parse(riserController.text), 2));
                                        _textFormFields['hypotenuse'] = hypotenuse;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: 'Bevel'),
                              MyTableCell(
                                Focus(
                                  child: TextFormField(
                                    focusNode: bevelFocus,
                                    controller: bevelController,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onTap: () => bevelController.selection =
                                        TextSelection(baseOffset: 0, extentOffset: bevelController.value.text.length),
                                    validator: (value) {
                                      if (double.tryParse(value!) == null) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.phone,
                                    decoration: inputDec,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onFocusChange: (value) {
                                    if (!value) {
                                      if (double.tryParse(bevelController.text) == null) {
                                        bevelFocus.requestFocus();
                                      } else {
                                        _textFormFields['bevel'] = bevelController.text;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: 'Bot. Crotch'),
                              MyTableCell(
                                Checkbox(
                                    value: _textFormFields['bottomCrotch'],
                                    onChanged: (value) {
                                      if (value != null) {
                                        if (_textFormFields['lowerFlatPost'].isNotEmpty) {
                                          double sumDistance = 0;
                                          sumDistance = _textFormFields['lowerFlatPost'].fold(
                                              0,
                                              (sum, element) =>
                                                  sum.toDouble() + double.parse(element.pController.text));

                                          if (sumDistance >= double.parse(_textFormFields['bottomCrotchLength'])) {
                                            return;
                                          }
                                        }
                                      }
                                      setState(() {
                                        _textFormFields['bottomCrotch'] = !_textFormFields['bottomCrotch'];
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: 'Bot. Cr. dist'),
                              Container(
                                color: _textFormFields['bottomCrotch'] ? Colors.white : Colors.grey.shade300,
                                child: MyTableCell(
                                  Focus(
                                    child: TextFormField(
                                      focusNode: btcFocus,
                                      controller: btcController,
                                      enabled: _textFormFields['bottomCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => btcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: btcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          bottomFlatDistanceError = true;
                                          return "";
                                        }

                                        if (_textFormFields['lowerFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = _textFormFields['lowerFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            bottomFlatDistanceError = true;
                                            return "";
                                          }
                                        }
                                        _textFormFields['bottomCrotchLength'] = btcController.text;

                                        bottomFlatDistanceError = false;

                                        // //currentFocus = globalFocus;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: inputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (bottomFlatDistanceError) {
                                          btcFocus.requestFocus();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: "Bot. Cr. Post"),
                              MyTableCell(
                                Checkbox(
                                    value: _textFormFields['hasBottomCrotchPost'],
                                    onChanged: (value) {
                                      setState(() {
                                        _textFormFields['hasBottomCrotchPost'] =
                                            !_textFormFields['hasBottomCrotchPost'];
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: "Top Crotch"),
                              MyTableCell(
                                Checkbox(
                                    value: _textFormFields['topCrotch'],
                                    onChanged: (value) {
                                      if (value != null) {
                                        if (_textFormFields['upperFlatPost'].isNotEmpty) {
                                          double sumDistance = 0;
                                          sumDistance = _textFormFields['upperFlatPost'].fold(
                                              0,
                                              (sum, element) =>
                                                  sum.toDouble() + double.parse(element.pController.text));

                                          if (sumDistance >= double.parse(_textFormFields['topCrotchLength'])) {
                                            return;
                                          }
                                        }
                                      }
                                      setState(() {
                                        _textFormFields['topCrotch'] = !_textFormFields['topCrotch'];
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: "Top Cr. Dist"),
                              Container(
                                color: _textFormFields['topCrotch'] ? Colors.white : Colors.grey.shade300,
                                child: MyTableCell(
                                  Focus(
                                    child: TextFormField(
                                      focusNode: tcFocus,
                                      controller: tcController,
                                      enabled: _textFormFields['topCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => tcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: tcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          topFlatDistanceError = true;
                                          return "";
                                        }

                                        if (_textFormFields['upperFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = _textFormFields['upperFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            topFlatDistanceError = true;
                                            return "";
                                          }
                                        }

                                        _textFormFields['topCrotchLength'] = tcController.text;
                                        topFlatDistanceError = false;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: inputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (topFlatDistanceError) {
                                          tcFocus.requestFocus();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: "Top Cr. Post"),
                              MyTableCell(
                                Checkbox(
                                    value: _textFormFields['hasTopCrotchPost'],
                                    onChanged: (value) {
                                      setState(() {
                                        _textFormFields['hasTopCrotchPost'] = !_textFormFields['hasTopCrotchPost'];
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              MyTableCol(name: "Last Nose"),
                              MyTableCell(
                                Focus(
                                  child: TextFormField(
                                    focusNode: lastNoseDistFocus,
                                    autocorrect: true,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onTap: () => lastNoseDistance.selection =
                                        TextSelection(baseOffset: 0, extentOffset: lastNoseDistance.value.text.length),
                                    validator: (value) {
                                      if (double.tryParse(lastNoseDistance.text) == null) {
                                        lastNoseError = true;
                                        return '';
                                      }
                                      double parseVal = double.parse(value!);
                                      if (parseVal < _textFormFields['hypotenuse']) {
                                        lastNoseError = true;
                                        return '';
                                      }

                                      _textFormFields['rampPost'].forEach((rp) => {
                                        if (rp.nosingDistance > parseVal) {
                                          lastNoseError = true,

                                        }
                                      });

                                      if(lastNoseError) {
                                        return '';
                                      }

                                      lastNoseError = false;
                                      return null;
                                    },
                                    controller: lastNoseDistance,
                                    keyboardType: TextInputType.phone,
                                    decoration: inputDec,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onFocusChange: (value) {
                                    if(!lastNoseError) {

                                    double? lnd = double.tryParse(lastNoseDistance.text);
                                    double hypotenuse = _textFormFields['hypotenuse'];

                                    if (!(lnd == null)) {
                                      if (lnd >= hypotenuse) {
                                        int numSteps = (lnd / hypotenuse).round();
                                        setState(() {
                                          _textFormFields['stairsCount'] = numSteps.toString();
                                        });
                                      } else {
                                        lastNoseDistFocus.requestFocus();
                                      }
                                    }
                                    } else {
                                      lastNoseDistFocus.requestFocus();
                                    }
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 64,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          PostCard(
                            Column(
                              children: [
                                const SizedBox(
                                  height: 6.0,
                                ),
                                SizedBox(
                                  height: 40.0,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Lower Flat Post'),
                                        Row(
                                          children: [
                                            const Text('Quantity : '),
                                            MyTableCell(
                                              Focus(
                                                  child: TextFormField(
                                                    focusNode: lowerPostQFocus,
                                                    controller: lowerPostQuantity,
                                                    keyboardType: TextInputType.phone,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    onTap: () {
                                                      lowerPostQuantity.selection = TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset: lowerPostQuantity.value.text.length);
                                                    },
                                                    validator: (value) {
                                                      if (value == null) {
                                                        lowerQuantityError = true;

                                                        return '';
                                                      }

                                                      if (int.tryParse(value) == null) {
                                                        lowerQuantityError = true;
                                                        return '';
                                                      }
                                                      lowerQuantityError = false;
                                                      return null;
                                                    },
                                                    decoration: inputDec,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  onFocusChange: (value) {
                                                    if (!value) {
                                                      if (!lowerQuantityError) {
                                                        int numLP = int.parse(lowerPostQuantity.text);
                                                        int listLpLen = _textFormFields['lowerFlatPost'].length;
                                                        if (numLP > 0) {
                                                          if (_textFormFields['lowerFlatPost'].length < numLP) {
                                                            for (int i = 0; i < (numLP - listLpLen); i++) {
                                                              _textFormFields['lowerFlatPost']
                                                                  .add(Post(distance: 0, embeddedType: 'none'));
                                                            }
                                                            setState(() {});
                                                          } else if (_textFormFields['lowerFlatPost'].length > numLP) {
                                                            setState(() {
                                                              _textFormFields['lowerFlatPost'] =
                                                                  _textFormFields['lowerFlatPost'].sublist(0, numLP);
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            _textFormFields['lowerFlatPost'].clear();
                                                          });
                                                        }
                                                      } else {
                                                        lowerPostQFocus.requestFocus();
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                if (int.parse(lowerPostQuantity.text) > 0) ...[
                                  BuildTable(
                                      crotch: _textFormFields['bottomCrotch'],
                                      campo: 'lowerFlatPost',
                                      crotchDistance: double.parse(_textFormFields['bottomCrotchLength']))
                                ],
                              ],
                            ),
                          ),
                          PostCard(
                            Column(
                              children: [
                                const SizedBox(
                                  height: 6.0,
                                ),
                                SizedBox(
                                  height: 40.0,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Upper Flat Post'),
                                        Row(
                                          children: [
                                            const Text('Quantity : '),
                                            MyTableCell(
                                              Focus(
                                                  child: TextFormField(
                                                    focusNode: upperPostQFocus,
                                                    controller: upperPostQuantity,
                                                    onTap: () {
                                                      upperPostQuantity.selection = TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset: upperPostQuantity.value.text.length);
                                                    },
                                                    keyboardType: TextInputType.phone,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return '';
                                                      }

                                                      if (int.tryParse(value) == null) {
                                                        return '';
                                                      }

                                                      return null;
                                                    },
                                                    decoration: inputDec,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  onFocusChange: (value) {
                                                    if (!value) {
                                                      int numLP = int.parse(upperPostQuantity.text);
                                                      int listLpLen = _textFormFields['upperFlatPost'].length;
                                                      if (numLP > 0) {
                                                        if (_textFormFields['upperFlatPost'].length < numLP) {
                                                          for (int i = 0; i < (numLP - listLpLen); i++) {
                                                            _textFormFields['upperFlatPost']
                                                                .add(Post(distance: 0, embeddedType: 'none'));
                                                          }
                                                          setState(() {});
                                                        } else if (_textFormFields['upperFlatPost'].length > numLP) {
                                                          setState(() {
                                                            _textFormFields['upperFlatPost'] =
                                                                _textFormFields['upperFlatPost'].sublist(0, numLP);
                                                          });
                                                        }
                                                      } else {
                                                        setState(() {
                                                          _textFormFields['upperFlatPost'].clear();
                                                        });
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                if (int.parse(upperPostQuantity.text) > 0) ...[
                                  BuildTable(
                                      crotch: _textFormFields['topCrotch'],
                                      campo: 'upperFlatPost',
                                      crotchDistance: double.parse(_textFormFields['topCrotchLength']))
                                ]
                              ],
                            ),
                          ),
                          PostCard(
                            Column(
                              children: [
                                const SizedBox(
                                  height: 6.0,
                                ),
                                SizedBox(
                                  height: 40.0,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Post'),
                                        Row(
                                          children: [
                                            const Text('Quantity : '),
                                            MyTableCell(
                                              Focus(
                                                  child: TextFormField(
                                                    focusNode: rampPostQFocus,
                                                    controller: rampPostQuantity,
                                                    onTap: () {
                                                      rampPostQuantity.selection = TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset: rampPostQuantity.value.text.length);
                                                    },
                                                    keyboardType: TextInputType.phone,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (value) {
                                                      if (value == null) {
                                                        rampQuantityError = true;
                                                        return '';
                                                      }

                                                      if (double.tryParse(value) == null) {
                                                        rampQuantityError = true;
                                                        return '';
                                                      }

                                                      int numRP = int.parse(rampPostQuantity.text);
                                                      int stepsCount = int.parse(_textFormFields['stairsCount']);
                                                      if (numRP > 0) {
                                                        // If number of post to add is minor than the amount of steps
                                                        if (numRP > stepsCount) {
                                                          rampQuantityError = true;
                                                          return '';
                                                        }
                                                      }
                                                      rampQuantityError = false;
                                                      return null;
                                                    },
                                                    decoration: inputDec,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  onFocusChange: (value) {
                                                    if (!value) {
                                                      int listRpLen = _textFormFields['rampPost'].length;
                                                      int numRP = int.parse(rampPostQuantity.text);

                                                      if (!rampQuantityError) {
                                                        // If number of post to add in greater than zero
                                                        if (numRP > 0) {
                                                          // If number of post to add is minor than the amount of steps
                                                          if (numRP > listRpLen) {
                                                            for (int i = 0; i < (numRP - listRpLen); i++) {
                                                              _textFormFields['rampPost'].add(RampPost(
                                                                  nosingDistance: 0.0,
                                                                  balusterDistance: 5.5,
                                                                  embeddedType: 'none',
                                                                  step: 0));
                                                            }
                                                            setState(() {});
                                                          } else {
                                                            setState(() {
                                                              _textFormFields['rampPost'] =
                                                                  _textFormFields['rampPost'].sublist(0, numRP);
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            _textFormFields['rampPost'].clear();
                                                          });
                                                        }
                                                      } else {
                                                        rampPostQFocus.requestFocus();
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                if (int.parse(rampPostQuantity.text) > 0) ...[
                                  RampPostTable(steps: int.parse(rampPostQuantity.text))
                                ]
                                // BuildTable(
                                //     crotch: _textFormFields['Crotch'],
                                //     campo: 'upperFlatPost',
                                //     crotchDistance: double.parse(_textFormFields['topCrotchLength']))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(flex: 2, child: Column())
            ],
          ),
        ),
      ]),
    );
    // );
  }
}

class PostCard extends StatelessWidget {
  PostCard(this.postCardChild);
  final Widget postCardChild;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10.0),
      child: postCardChild,
    );
  }
}

class MyTableCell extends StatelessWidget {
  final celChild;
  MyTableCell(this.celChild);

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.only(top: 8.0),
      width: 90,

      child: celChild,
    );
  }
}

class MyTableCol extends StatelessWidget {
  final String name;
  final double largeur;
  MyTableCol({required this.name, this.largeur = 90.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 8.0),
        // margin: const EdgeInsets.symmetric(horizontal: 5.0),
        width: largeur,
        child: Text(name));
  }
}

// Row(children: [
// const Expanded(
// //flex: 2,
// child: Padding(
// padding: EdgeInsets.all(16.0),
// child: Cuadro(),
// ),
// ),
// SizedBox(
// width: 400.0,
// child: FlightDataInput(
// pIndex: pIndex,
// sIndex: sIndex,
// fIndex: fIndex,
// cloud: cloud,
// ),
// ),
// ])
