import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/BalusterPost.dart';
import '../models/Post.dart';
import '/models/project.dart';
import '/screens/dibujo.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../file_manager/secretary.dart';
import '../models/Projects.dart';

import '../widget/CustomActionButton.dart';
//import 'Home.dart';

final _formKey = GlobalKey<FormState>();

class FlightEditor extends StatefulWidget {
  FlightEditor({Key? key, required this.pIndex, required this.sIndex, required this.fIndex, required this.template})
      : super(key: key);

  int pIndex;
  int sIndex;
  int fIndex;
  Map<String, dynamic> template;

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
  TextEditingController riserController = TextEditingController();
  TextEditingController bevelController = TextEditingController();
  TextEditingController btcController = TextEditingController();
  TextEditingController tcController = TextEditingController();
  TextEditingController lowerPostQuantity = TextEditingController();
  TextEditingController upperPostQuantity = TextEditingController();
  TextEditingController balusterQuantity = TextEditingController();
  TextEditingController lastNoseDistance = TextEditingController();

  FocusNode riserFocus = FocusNode();
  FocusNode bevelFocus = FocusNode();
  FocusNode btcFocus = FocusNode();
  FocusNode tcFocus = FocusNode();
  FocusNode lowerPostQFocus = FocusNode();
  FocusNode upperPostQFocus = FocusNode();
  FocusNode balusterQFocus = FocusNode();
  FocusNode lastNoseDistFocus = FocusNode();

  // FocusNode riserFocus = FocusNode();
  int cp = 2;

  bool bottomFlatDistanceError = false;
  bool topFlatDistanceError = false;
  bool lowerQuantityError = false;
  bool upperQuantityError = false;
  bool rampQuantityError = false;
  bool lastNoseError = false;

  final double hypotenuse = 12.8575;

  Map<String, dynamic> templatel = {};

  @override
  void initState() {
    super.initState();
    riserController.text = widget.template['riser'];
    bevelController.text = widget.template['bevel'];
    btcController.text = widget.template['bottomCrotchLength'];
    tcController.text = widget.template['topCrotchLength'];
    lowerPostQuantity.text = widget.template['lowerFlatPost'].length.toString();
    upperPostQuantity.text = widget.template['upperFlatPost'].length.toString();
    balusterQuantity.text = widget.template['balusters'].length.toString();
    lastNoseDistance.text = widget.template['lastNoseDistance'];

    templatel = widget.template;
    templatel['lowerFlatPost'] = [...templatel['lowerFlatPost']];
    templatel['upperFlatPost'] = [...templatel['upperFlatPost']];
    templatel['balusters'] = [...templatel['balusters']];
    int numStp = (double.parse(lastNoseDistance.text) / hypotenuse).round() + 1;
    templatel['stepsCount'] = numStp.toString();
  }

  @override
  void dispose() {
    riserController.dispose();
    bevelController.dispose();
    btcController.dispose();
    tcController.dispose();
    lowerPostQuantity.dispose();
    upperPostQuantity.dispose();
    balusterQuantity.dispose();
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

    List<DataColumn> createColumns() {
      return [
        const DataColumn(label: Text('Id')),
        DataColumn(
          label: Expanded(
            child: Container(
              width: 86,
              alignment: Alignment.center,
              child: const Text('Distance'),
            ),
          ),
        ),
        const DataColumn(label: Text('Emb. Type')),
      ];
    }

    List<DataRow> createRows({required bool crotch, required String campo, required double crotchDistance}) {
      double sumDistance = 0;
      String letter = campo == "lowerFlatPost" ? 'B' : "U";

      return List<DataRow>.generate(
        templatel[campo].length,
        (index) => DataRow(cells: [
          DataCell(Text('$letter${index + 1}')),
          DataCell(
            Focus(
              child: TextFormField(
                focusNode: templatel[campo][index].pFocusNode,
                controller: templatel[campo][index].pController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: () => templatel[campo][index].pController.selection =
                    TextSelection(baseOffset: 0, extentOffset: templatel[campo][index].pController.value.text.length),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || value.isEmpty) {
                    templatel[campo][index].error = true;
                    return '';
                  }

                  if (crotch) {
                    List sublista = templatel[campo].sublist(0, index + 1);
                    sumDistance =
                        sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.pController.text));

                    if (sumDistance >= crotchDistance && double.parse(value) != 0) {
                      templatel[campo][index].error = true;

                      return "";
                    }
                  }

                  templatel[campo][index].error = false;
                  return null;
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!value) {
                  if (!templatel[campo][index].error) {
                    templatel[campo][index].distance = double.parse(templatel[campo][index].pController.text);
                  } else {
                    templatel[campo][index].pFocusNode.requestFocus();
                  }
                }
              },
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
                value: templatel[campo][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    templatel[campo][index].embeddedType = value;
                  });
                }

                //widget.resetView();

                ),
          ),
        ]),
      );
    }

    Widget buildTable({required bool crotch, required String campo, required double crotchDistance}) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: DataTable(
            dataRowHeight: 50.0,
            columnSpacing: 12.0,
            horizontalMargin: 10.0,
            columns: createColumns(),
            rows: createRows(crotch: crotch, campo: campo, crotchDistance: crotchDistance),
            //columnSpacing: 20,
          ),
        ),
      );
    }

    List<DataRow> rampRows({required int steps}) {
      List<String> alphabet = List.generate(26, (index) => String.fromCharCode(index + 65));

      return List<DataRow>.generate(
        templatel['balusters'].length,
        (index) => DataRow(cells: [
          DataCell(Text(alphabet[index])),
          DataCell(
            Focus(
              child: TextFormField(
                focusNode: templatel['balusters'][index].noseFocus,
                controller: templatel['balusters'][index].noseController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: () => templatel['balusters'][index].noseController.selection = TextSelection(
                    baseOffset: 0, extentOffset: templatel['balusters'][index].noseController.value.text.length),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || value.isEmpty) {
                    templatel['balusters'][index].noseError = true;
                    return '';
                  }

                  double noseValue = double.parse(value);
                  if (double.tryParse(lastNoseDistance.text) != null) {
                    if (noseValue >= double.parse(lastNoseDistance.text)) {
                      templatel['balusters'][index].noseError = true;
                      return "";
                    }
                  }

                  templatel['balusters'][index].noseError = false;
                  int step = (noseValue / hypotenuse).round()..toInt();

                  templatel['balusters'][index].step = step + 1;
                  templatel['balusters'][index].nosingDistance = double.parse(value);
                  return null;
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!lastNoseError) {
                  if (!value) {
                    if (templatel['balusters'][index].noseError) {
                      templatel['balusters'][index].noseFocus.requestFocus();
                    } else {
                      setState(() {
                        double noseValue = double.parse(lastNoseDistance.text);
                        int step = (noseValue / hypotenuse).round()..toInt();

                        templatel['balusters'][index].step = step + 1;
                        templatel['balusters'][index].nosingDistance = double.parse(lastNoseDistance.text);
                      });
                    }
                  }
                }
              },
            ),
          ),
          DataCell(
            Focus(
              child: TextFormField(
                focusNode: templatel['balusters'][index].balusterFocus,
                controller: templatel['balusters'][index].balusterController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: () => templatel['balusters'][index].balusterController.selection = TextSelection(
                    baseOffset: 0, extentOffset: templatel['balusters'][index].balusterController.value.text.length),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || value.isEmpty) {
                    templatel['balusters'][index].balusterError = true;
                    return '';
                  }

                  double noseValue = double.parse(value);
                  if (noseValue >= 10) {
                    templatel['balusters'][index].balusterError = true;
                    return "";
                  }

                  templatel['balusters'][index].balusterError = false;
                  templatel['balusters'][index].balusterDistance = double.parse(value);

                  return null;
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!value) {
                  if (templatel['balusters'][index].balusterError) {
                    templatel['balusters'][index].balusterFocus.requestFocus();
                  } else {
                    setState(() {
                      templatel['balusters'][index].balusterDistance =
                          double.parse(templatel['balusters'][index].balusterController.text);
                    });
                  }
                }
              },
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
                value: templatel['balusters'][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    templatel['balusters'][index].embeddedType = value;
                  });
                }),
          ),
        ]),
      );
    }

    Widget balusterTable({required int steps}) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: DataTable(
            dataRowHeight: 50.0,
            columnSpacing: 12.0,
            horizontalMargin: 10.0,
            columns: [
              const DataColumn(
                label: Text('Id'),
              ),
              DataColumn(
                label: Expanded(
                  child: Container(
                    width: 86,
                    alignment: Alignment.center,
                    child: const Text('Distance'),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Container(
                    width: 86,
                    alignment: Alignment.center,
                    child: const Text('Baluster'),
                  ),
                ),
              ),
              const DataColumn(label: Text('Emb. Type')),
            ],
            rows: rampRows(steps: steps),
            //columnSpacing: 20,
          ),
        ),
      );
    }

    TextStyle kCardLabelStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        leading: const Text(''),
        title: const Text("Edit Flight"),
        actions: [
          CustomActionButton(
            txt: 'View',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dibujo(templatel)));
            },
          ),
          CustomActionButton(
            txt: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CustomActionButton(
            txt: 'Save',
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                //int numStp = (double.parse(lastNoseDistance.text) / hypotenuse).round() + 1;
                Map<String, dynamic> tempFlight = {
                  'id': templatel['id'],
                  "riser": riserController.text, //
                  "bevel": bevelController.text,

                  "topCrotch": templatel['topCrotch'],
                  "topCrotchLength": tcController.text,
                  'hasBottomCrotchPost': templatel['topCrotch'],
                  //
                  "bottomCrotch": templatel['bottomCrotch'],
                  "bottomCrotchLength": btcController.text,
                  'hasTopCrotchPost': templatel['hasBottomCrotchPost'],
                  //
                  "lowerFlatPost": [...templatel['lowerFlatPost']],
                  "balusters": [...templatel['balusters']],
                  "upperFlatPost": templatel['upperFlatPost'],
                  //"stepsCount": numStp,
                  "lastNoseDistance": lastNoseDistance.text,
                  'hypotenuse': hypotenuse
                };

                context
                    .read<Projects>()
                    // Provider.of<Projects>(context, listen: false)
                    .projects[widget.pIndex]
                    .stairs[widget.sIndex]
                    .flights[widget.fIndex]
                    .updateFl(tempFlight);

                print(Provider.of<Projects>(context, listen: false).toJson());
                await OurDataStorage.writeDocument(
                    "allProjects", Provider.of<Projects>(context, listen: false).toJson());

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1000),
                    content: const Text('Saved!'),
                    backgroundColor: Colors.blueGrey.shade400,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            height: 50.0,
            child: Card(
              child: Container(
                //padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Project : ',
                      style: kLabel600,
                    ),
                    Text(
                      '${Provider.of<Projects>(context, listen: false).projects[widget.pIndex].id} >',
                      style: kLabelStyle,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Stair : ',
                      style: kLabel600,
                    ),
                    Text(
                      '${Provider.of<Projects>(context, listen: false).projects[widget.pIndex].stairs[widget.sIndex].id} >',
                      style: kLabelStyle,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Flight : ',
                      style: kLabel600,
                    ),
                    Text(
                      '${Provider.of<Projects>(context, listen: false).projects[widget.pIndex].stairs[widget.sIndex].flights[widget.fIndex].id}',
                      style: kLabelStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Divider(),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(shrinkWrap: true, children: [
                Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.start,

                          spacing: 30,
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
                                      controller: riserController,
                                      keyboardType: TextInputType.number,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (double.tryParse(value!) == null) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      onTap: () => riserController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: riserController.value.text.length),
                                      decoration: kInputDec,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (double.tryParse(riserController.text) == null) {
                                          riserFocus.requestFocus();
                                        } else {
                                          setState(() {
                                            templatel['riser'] = riserController.text;
                                          });
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
                                      keyboardType: TextInputType.number,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => bevelController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: bevelController.value.text.length),
                                      validator: (value) {
                                        if (double.tryParse(value!) == null) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      decoration: kInputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (double.tryParse(bevelController.text) == null) {
                                          bevelFocus.requestFocus();
                                        } else {
                                          setState(() {
                                            templatel['bevel'] = bevelController.text;
                                          });
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
                                      value: templatel['bottomCrotch'],
                                      onChanged: (value) {
                                        if (value != null) {
                                          if (templatel['lowerFlatPost'].isNotEmpty) {
                                            double sumDistance = 0;
                                            sumDistance = templatel['lowerFlatPost'].fold(
                                                0,
                                                (sum, element) =>
                                                    sum.toDouble() + double.parse(element.pController.text));

                                            if (sumDistance >= double.parse(templatel['bottomCrotchLength'])) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(milliseconds: 3000),
                                                  content: const Text(
                                                    "Total distance of the lower flat posts exceeds the distance value of the bottom crotch.",
                                                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
                                                  ),
                                                  backgroundColor: kAlert,
                                                ),
                                              );
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          templatel['bottomCrotch'] = !templatel['bottomCrotch'];
                                          if (!value!) {
                                            templatel['hasBottomCrotchPost'] = value;
                                          }
                                        });
                                      }),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: 'Bot.\u{00A0}Cr.\u{00A0}dist'),
                                MyTableCell(
                                  Focus(
                                    child: TextFormField(
                                      focusNode: btcFocus,
                                      controller: btcController,
                                      keyboardType: TextInputType.number,
                                      enabled: templatel['bottomCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => btcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: btcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          bottomFlatDistanceError = true;
                                          return "";
                                        }
                                        if (templatel['bottomCrotch']) {
                                          if (templatel['lowerFlatPost'].isNotEmpty) {
                                            double totDistance = 0;
                                            totDistance = templatel['lowerFlatPost']
                                                .fold(0, (previousValue, element) => previousValue + element.distance);

                                            if (double.parse(value) <= totDistance && totDistance != 0) {
                                              bottomFlatDistanceError = true;
                                              return "";
                                            }
                                          }
                                        }

                                        bottomFlatDistanceError = false;

                                        // //currentFocus = globalFocus;
                                        return null;
                                      },
                                      decoration: templatel['bottomCrotch'] ? kInputDec : kInputDecDisable,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: templatel['bottomCrotch'] ? Colors.black : Colors.blueGrey.shade50),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (bottomFlatDistanceError) {
                                          btcFocus.requestFocus();
                                        } else {
                                          setState(() {
                                            templatel['bottomCrotchLength'] = btcController.text;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Bot.\u{00A0}Cr.\u{00A0}Post"),
                                MyTableCell(
                                  Checkbox(
                                      value: templatel['hasBottomCrotchPost'],
                                      onChanged: templatel['bottomCrotch']
                                          ? (value) {
                                              setState(() {
                                                templatel['hasBottomCrotchPost'] = !templatel['hasBottomCrotchPost'];
                                              });
                                            }
                                          : (value) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(milliseconds: 3000),
                                                  content: const Text(
                                                    "Please add Bottom Crotch first.",
                                                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
                                                  ),
                                                  backgroundColor: kAlert,
                                                ),
                                              );
                                            }),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Top\u{00A0}Crotch"),
                                MyTableCell(
                                  Checkbox(
                                      value: templatel['topCrotch'],
                                      onChanged: (value) {
                                        if (value != null) {
                                          if (templatel['upperFlatPost'].isNotEmpty) {
                                            double sumDistance = 0;
                                            sumDistance = templatel['upperFlatPost'].fold(
                                                0,
                                                (sum, element) =>
                                                    sum.toDouble() + double.parse(element.pController.text));

                                            if (sumDistance >= double.parse(templatel['topCrotchLength'])) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(milliseconds: 3000),
                                                  content: const Text(
                                                    "Total distance of the upper flat posts exceeds the distance value of the bottom crotch.",
                                                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
                                                  ),
                                                  backgroundColor: kAlert,
                                                ),
                                              );
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          templatel['topCrotch'] = !templatel['topCrotch'];
                                          if (!value!) {
                                            templatel['hasTopCrotchPost'] = value;
                                          }
                                        });
                                      }),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Top\u{00A0}Cr.\u{00A0}Dist"),
                                MyTableCell(
                                  Focus(
                                    child: TextFormField(
                                      focusNode: tcFocus,
                                      controller: tcController,
                                      keyboardType: TextInputType.number,
                                      enabled: templatel['topCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => tcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: tcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          topFlatDistanceError = true;
                                          return "";
                                        }

                                        if (templatel['topCrotch']) {
                                          if (templatel['upperFlatPost'].isNotEmpty) {
                                            double totDistance = 0;
                                            totDistance = templatel['upperFlatPost']
                                                .fold(0, (previousValue, element) => previousValue + element.distance);

                                            if (double.parse(value) <= totDistance && totDistance != 0) {
                                              topFlatDistanceError = true;
                                              return "";
                                            }
                                          }
                                        }

                                        topFlatDistanceError = false;
                                        return null;
                                      },
                                      decoration: templatel['topCrotch'] ? kInputDec : kInputDecDisable,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: templatel['topCrotch'] ? Colors.black : Colors.blueGrey.shade50),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (topFlatDistanceError) {
                                          tcFocus.requestFocus();
                                        } else {
                                          templatel['topCrotchLength'] = tcController.text;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Top\u{00A0}Cr.\u{00A0}Post"),
                                MyTableCell(
                                  Checkbox(
                                      value: templatel['hasTopCrotchPost'],
                                      onChanged: templatel['topCrotch']
                                          ? (value) {
                                              setState(() {
                                                templatel['hasTopCrotchPost'] = !templatel['hasTopCrotchPost'];
                                              });
                                            }
                                          : (value) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(milliseconds: 3000),
                                                  content: const Text(
                                                    "Please add Top Crotch first.",
                                                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
                                                  ),
                                                  backgroundColor: kAlert,
                                                ),
                                              );
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
                                      controller: lastNoseDistance,
                                      keyboardType: TextInputType.number,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => lastNoseDistance.selection = TextSelection(
                                          baseOffset: 0, extentOffset: lastNoseDistance.value.text.length),
                                      validator: (value) {
                                        lastNoseError = false;
                                        if (double.tryParse(lastNoseDistance.text) == null) {
                                          lastNoseError = true;

                                          return '';
                                        }
                                        double parseVal = double.parse(value!);
                                        if (parseVal < hypotenuse) {
                                          lastNoseError = true;

                                          return '';
                                        }
                                        if (templatel['balusters'].isNotEmpty) {
                                          templatel['balusters'].forEach((rp) => {
                                                if (rp.nosingDistance > parseVal) {lastNoseError = true}
                                              });

                                          if (lastNoseError) {
                                            return '';
                                          }
                                        }

                                        lastNoseError = false;
                                        return null;
                                      },
                                      decoration: kInputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!lastNoseError) {
                                        double? lnd = double.tryParse(lastNoseDistance.text);

                                        if (!(lnd == null)) {
                                          if (lnd >= hypotenuse) {
                                            int numSteps = (lnd / hypotenuse).round() + 1;

                                            setState(() {
                                              templatel['stepsCount'] = numSteps.toString();
                                              templatel['lastNoseDistance'] = lastNoseDistance.text;
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: double.infinity,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 64,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            PostCard(
                              postCardChild: Column(
                                children: [
                                  const SizedBox(
                                    height: 6.0,
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'LFP',
                                            style: kCardLabelStyle,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty : ',
                                                style: kCardLabelStyle,
                                              ),
                                              SizedBox(
                                                width: 70.0,
                                                child: MyTableCell(
                                                  Focus(
                                                      child: TextFormField(
                                                        focusNode: lowerPostQFocus,
                                                        controller: lowerPostQuantity,
                                                        keyboardType: TextInputType.number,
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
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          if (!lowerQuantityError) {
                                                            int numLP = int.parse(lowerPostQuantity.text);
                                                            int listLpLen = templatel['lowerFlatPost'].length;
                                                            if (numLP > 0) {
                                                              if (templatel['lowerFlatPost'].length < numLP) {
                                                                for (int i = 0; i < (numLP - listLpLen); i++) {
                                                                  templatel['lowerFlatPost']
                                                                      .add(Post(distance: 0, embeddedType: 'none'));
                                                                }
                                                                setState(() {});
                                                              } else if (templatel['lowerFlatPost'].length > numLP) {
                                                                setState(() {
                                                                  templatel['lowerFlatPost'] =
                                                                      templatel['lowerFlatPost'].sublist(0, numLP);
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                templatel['lowerFlatPost'].clear();
                                                              });
                                                            }
                                                          } else {
                                                            lowerPostQFocus.requestFocus();
                                                          }
                                                        }
                                                      }),
                                                ),
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
                                    buildTable(
                                        crotch: templatel['bottomCrotch'],
                                        campo: 'lowerFlatPost',
                                        crotchDistance: double.parse(templatel['bottomCrotchLength']))
                                  ],
                                ],
                              ),
                              width: 250.0,
                            ),
                            PostCard(
                              postCardChild: Column(
                                children: [
                                  const SizedBox(
                                    height: 6.0,
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Baluster',
                                            style: kCardLabelStyle,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty : ',
                                                style: kCardLabelStyle,
                                              ),
                                              SizedBox(
                                                width: 70.0,
                                                child: MyTableCell(
                                                  Focus(
                                                      child: TextFormField(
                                                        focusNode: balusterQFocus,
                                                        controller: balusterQuantity,
                                                        keyboardType: TextInputType.number,
                                                        onTap: () {
                                                          balusterQuantity.selection = TextSelection(
                                                              baseOffset: 0,
                                                              extentOffset: balusterQuantity.value.text.length);
                                                        },
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

                                                          int numRP = int.parse(balusterQuantity.text);
                                                          int stepsCount = int.parse(templatel['stepsCount']);
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
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          int listRpLen = templatel['balusters'].length;
                                                          int numRP = int.parse(balusterQuantity.text);

                                                          if (!rampQuantityError) {
                                                            // If number of post to add in greater than zero
                                                            if (numRP > 0) {
                                                              // If number of post to add is minor than the amount of steps
                                                              if (numRP > listRpLen) {
                                                                for (int i = 0; i < (numRP - listRpLen); i++) {
                                                                  templatel['balusters'].add(BalusterPost(
                                                                      nosingDistance: 0.0,
                                                                      balusterDistance: 5.5,
                                                                      embeddedType: 'none',
                                                                      step: 0));
                                                                }
                                                                setState(() {});
                                                              } else {
                                                                setState(() {
                                                                  templatel['balusters'] =
                                                                      templatel['balusters'].sublist(0, numRP);
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                templatel['balusters'].clear();
                                                              });
                                                            }
                                                          } else {
                                                            balusterQFocus.requestFocus();
                                                          }
                                                        }
                                                      }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20.0,
                                  ),
                                  if (int.parse(balusterQuantity.text) > 0) ...[
                                    balusterTable(steps: int.parse(balusterQuantity.text))
                                  ]
                                ],
                              ),
                              width: 340.0,
                            ),
                            PostCard(
                              postCardChild: Column(
                                children: [
                                  const SizedBox(
                                    height: 6.0,
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'UFP',
                                            style: kCardLabelStyle,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty : ',
                                                style: kCardLabelStyle,
                                              ),
                                              SizedBox(
                                                width: 70,
                                                child: MyTableCell(
                                                  Focus(
                                                      child: TextFormField(
                                                        focusNode: upperPostQFocus,
                                                        controller: upperPostQuantity,
                                                        keyboardType: TextInputType.number,
                                                        onTap: () {
                                                          upperPostQuantity.selection = TextSelection(
                                                              baseOffset: 0,
                                                              extentOffset: upperPostQuantity.value.text.length);
                                                        },
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
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          int numLP = int.parse(upperPostQuantity.text);
                                                          int listLpLen = templatel['upperFlatPost'].length;
                                                          if (numLP > 0) {
                                                            if (templatel['upperFlatPost'].length < numLP) {
                                                              for (int i = 0; i < (numLP - listLpLen); i++) {
                                                                templatel['upperFlatPost']
                                                                    .add(Post(distance: 0, embeddedType: 'none'));
                                                              }
                                                              setState(() {});
                                                            } else if (templatel['upperFlatPost'].length > numLP) {
                                                              setState(() {
                                                                templatel['upperFlatPost'] =
                                                                    templatel['upperFlatPost'].sublist(0, numLP);
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              templatel['upperFlatPost'].clear();
                                                            });
                                                          }
                                                        }
                                                      }),
                                                ),
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
                                    buildTable(
                                        crotch: templatel['topCrotch'],
                                        campo: 'upperFlatPost',
                                        crotchDistance: double.parse(templatel['topCrotchLength']))
                                  ]
                                ],
                              ),
                              width: 250.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
    // );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({required this.postCardChild, this.width = 360.0});

  final Widget postCardChild;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(color: Colors.blueGrey.shade300, borderRadius: BorderRadius.circular(10)),
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
    return SizedBox(
      //margin: const EdgeInsets.only(top: 8.0),
      width: 100,
      child: celChild,
    );
  }
}

class MyTableCol extends StatelessWidget {
  final String name;
  final double largeur;

  MyTableCol({required this.name, this.largeur = 110.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 8.0),
      // margin: const EdgeInsets.symmetric(horizontal: 5.0),
      width: largeur,
      child: Text(
        name,
        style: kLabelStyle,
      ),
    );
  }
}
