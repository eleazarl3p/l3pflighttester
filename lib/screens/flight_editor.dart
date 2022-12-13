import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l3pflighttester/models/project.dart';
import 'package:l3pflighttester/screens/dibujo.dart';
import 'package:provider/provider.dart';

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
import '../constants.dart';
import '../file_storage_manager/secretaria.dart';
import '../models/Projects.dart';
import '../models/flight_map.dart';
import '../widget/CustomActionButton.dart';
import 'Home.dart';

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
  TextEditingController rampPostQuantity = TextEditingController();
  TextEditingController lastNoseDistance = TextEditingController();

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
    rampPostQuantity.text = widget.template['rampPost'].length.toString();
    lastNoseDistance.text = widget.template['lastNoseDistance'];

    // templatel['lowerFlatPost'] =templatel['lowerFlatPost'];
    // templatel['upperFlatPost'] =templatel['upperFlatPost'];
    // templatel['rampPost'] =templatel['rampPost'];
    templatel = widget.template;
  }

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

    List<DataColumn> createColumns() {
      return [
        const DataColumn(label: Text('Id')),
        const DataColumn(label: Expanded(child: SizedBox(width: 90, child: Text('Distance')))),
        const DataColumn(label: Text('Emb. Type')),
      ];
    }

    List<DataRow> createRows({required bool crotch, required String campo, required double crotchDistance}) {
      double sumDistance = 0;
      String letter = campo == "lowerFlatPost" ? 'B' : "U";

      return List<DataRow>.generate(
        templatel[campo].length,
            (index) =>
            DataRow(cells: [
              DataCell(Text('$letter${index + 1}')),
              DataCell(
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    top: 5.0,
                  ),
                  child: Focus(
                    child: TextFormField(
                      focusNode: templatel[campo][index].pFocusNode,
                      controller: templatel[campo][index].pController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () =>
                      templatel[campo][index].pController.selection =
                          TextSelection(
                              baseOffset: 0, extentOffset: templatel[campo][index].pController.value.text.length),
                      validator: (value) {
                        print(crotchDistance);
                        if (value == null || double.tryParse(value) == null || value.isEmpty) {
                          templatel[campo][index].error = true;
                          return '';
                        }

                        if (crotch) {
                          List sublista = templatel[campo].sublist(0, index + 1);
                          sumDistance =
                              sublista.fold(0, (sum, element) =>
                              sum.toDouble() + double.parse(element.pController.text));

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
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DataTable(
            dataRowHeight: 60.0,
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
        templatel['rampPost'].length,
            (index) =>
            DataRow(cells: [
              DataCell(Text(alphabet[index])),
              DataCell(
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    top: 5.0,
                  ),
                  child: Focus(
                    child: TextFormField(
                      focusNode: templatel['rampPost'][index].noseFocus,
                      controller: templatel['rampPost'][index].noseController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () =>
                      templatel['rampPost'][index].noseController.selection = TextSelection(
                          baseOffset: 0, extentOffset: templatel['rampPost'][index].noseController.value.text.length),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null || value.isEmpty) {
                          templatel['rampPost'][index].noseError = true;
                          return '';
                        }

                        double noseValue = double.parse(value);
                        if (double.tryParse(lastNoseDistance.text) != null) {
                          if (noseValue >= double.parse(lastNoseDistance.text)) {
                            templatel['rampPost'][index].noseError = true;
                            return "";
                          }
                        }

                        templatel['rampPost'][index].noseError = false;
                        int step = (noseValue / hypotenuse).round()
                          ..toInt();

                        templatel['rampPost'][index].step = step + 1;
                        templatel['rampPost'][index].nosingDistance = double.parse(value);
                        return null;
                      },
                      decoration: kInputDec,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onFocusChange: (value) {
                      if (!lastNoseError) {
                        if (!value) {
                          if (templatel['rampPost'][index].noseError) {
                            templatel['rampPost'][index].noseFocus.requestFocus();
                          }
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
                      focusNode: templatel['rampPost'][index].balusterFocus,
                      controller: templatel['rampPost'][index].balusterController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () =>
                      templatel['rampPost'][index].balusterController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: templatel['rampPost'][index].balusterController.value.text.length),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null || value.isEmpty) {
                          templatel['rampPost'][index].balusterError = true;
                          return '';
                        }

                        // List sublista =templatel['ramPost'].sublist(0, index + 1);
                        // sumDistance =
                        //     sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.noseController.text));
                        double noseValue = double.parse(value);
                        if (noseValue >= 10) {
                          templatel['rampPost'][index].balusterError = true;
                          return "";
                        }

                        templatel['rampPost'][index].balusterError = false;
                        templatel['rampPost'][index].balusterDistance = double.parse(value);

                        return null;
                      },
                      decoration: kInputDec,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onFocusChange: (value) {
                      if (!value) {
                        if (templatel['rampPost'][index].balusterError) {
                          templatel['rampPost'][index].balusterFocus.requestFocus();
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
                    value: templatel['rampPost'][index].embeddedType,
                    onChanged: (value) {
                      setState(() {
                        templatel['rampPost'][index].embeddedType = value;
                      });
                    }

                  //widget.resetView();

                ),
              ),
            ]),
      );
    }

    Widget rampPostTable({required int steps}) {
      return Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DataTable(
            dataRowHeight: 60.0,
            columnSpacing: 15.0,
            columns: const [
              DataColumn(label: Text('Id')),
              DataColumn(label: Expanded(child: SizedBox(width: 80, child: Text('Distance')))),
              DataColumn(label: Expanded(child: SizedBox(width: 80, child: Text('Baluster')))),
              DataColumn(label: Text('Emb. Type')),
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
        //leading: const Text(''),
        title: const ListTile(
          title: Text('Flight'
            //'Flight : ${Provider.of<Projects>(context).projects[pIndex].stairs[sIndex].flights[fIndex].id}',
            //style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text('Local > Projects > Stair > FLight', style: TextStyle(color: Colors.white)),
        ),

        centerTitle: true,
        actions: [
          CustomActionButton(
            txt: 'open',
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
                  "lowerFlatPost": templatel['lowerFlatPost'],
                  "rampPost": templatel['rampPost'],
                  "upperFlatPost": templatel['upperFlatPost'],
                  // "stepsCount": stepsCount.toString(),
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
                Navigator.pop(context);
                await OurDataStorage.writeDocument(
                    "MyProjects", Provider.of<Projects>(context, listen: false).toJson());
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: const Text('Processing Data'),
                //     backgroundColor: Colors.blueGrey.shade400,
                //   ),
                // );
              }
            },
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(padding: EdgeInsets.zero, children: [
      //     ListTile(
      //       leading: const Icon(Icons.list),
      //       title: const Text('READ'),
      //       onTap: () {
      //         Navigator.of(context).pushReplacement(
      //           MaterialPageRoute(
      //             builder: (BuildContext context) => const Home(),
      //           ),
      //         );
      //       },
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.search),
      //       title: Text('SELECT'),
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //     ),
      //   ]),
      // ),
      body: Form(
        key: _formKey,
        child: ListView(children: [
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
                          alignment: WrapAlignment.start,

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
                                      // onChanged: (value) {
                                      //   if (double.tryParse(value) != null) {
                                      //     setState(() {
                                      //      templatel['riser'] = riserController.text;
                                      //       double hypotenuse = sqrt(121 + pow(double.parse(riserController.text), 2));
                                      //      templatel['hypotenuse'] = hypotenuse;
                                      //     });
                                      //   }
                                      // },
                                      validator: (value) {
                                        if (double.tryParse(value!) == null) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      onTap: () =>
                                      riserController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: riserController.value.text.length),
                                      keyboardType: TextInputType.phone,
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
                                            // double hypotenuse = sqrt(121 + pow(double.parse(riserController.text), 2));
                                            // templatel['hypotenuse'] = hypotenuse;
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
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () =>
                                      bevelController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: bevelController.value.text.length),
                                      validator: (value) {
                                        if (double.tryParse(value!) == null) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
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
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          templatel['bottomCrotch'] = !templatel['bottomCrotch'];
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
                                      enabled: templatel['bottomCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () =>
                                      btcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: btcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          bottomFlatDistanceError = true;
                                          return "";
                                        }

                                        if (templatel['lowerFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = templatel['lowerFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            bottomFlatDistanceError = true;
                                            return "";
                                          }
                                        }

                                        bottomFlatDistanceError = false;

                                        // //currentFocus = globalFocus;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
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
                                MyTableCol(name: "Bot\u{00A0}Cr.\u{00A0}Post"),
                                MyTableCell(
                                  Checkbox(
                                      value: templatel['hasBottomCrotchPost'],
                                      onChanged: templatel['bottomCrotch']
                                          ? (value) {
                                        setState(() {
                                          templatel['hasBottomCrotchPost'] = !templatel['hasBottomCrotchPost'];
                                        });
                                      }
                                          : null),
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
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          templatel['topCrotch'] = !templatel['topCrotch'];
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
                                      enabled: templatel['topCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () =>
                                      tcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: tcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          topFlatDistanceError = true;
                                          return "";
                                        }
                                        if (templatel['upperFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = templatel['upperFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            topFlatDistanceError = true;
                                            return "";
                                          }
                                        }


                                        topFlatDistanceError = false;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
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
                                          : null),
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
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () =>
                                      lastNoseDistance.selection = TextSelection(
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
                                        if (templatel['rampPost'].isNotEmpty) {
                                          templatel['rampPost'].forEach((rp) =>
                                          {
                                            if (rp.nosingDistance > parseVal) {lastNoseError = true}
                                          });

                                          if (lastNoseError) {
                                            return '';
                                          }
                                        }

                                        lastNoseError = false;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
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
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lower Flat Post',
                                            style: kCardLabelStyle,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty : ',
                                                style: kCardLabelStyle,
                                              ),
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
                                                        int listRpLen = templatel['rampPost'].length;
                                                        int numRP = int.parse(rampPostQuantity.text);

                                                        if (!rampQuantityError) {
                                                          // If number of post to add in greater than zero
                                                          if (numRP > 0) {
                                                            // If number of post to add is minor than the amount of steps
                                                            if (numRP > listRpLen) {
                                                              for (int i = 0; i < (numRP - listRpLen); i++) {
                                                                templatel['rampPost'].add(RampPost(
                                                                    nosingDistance: 0.0,
                                                                    balusterDistance: 5.5,
                                                                    embeddedType: 'none',
                                                                    step: 0));
                                                              }
                                                              setState(() {});
                                                            } else {
                                                              setState(() {
                                                                templatel['rampPost'] =
                                                                    templatel['rampPost'].sublist(0, numRP);
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              templatel['rampPost'].clear();
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
                                  Container(
                                    height: 20.0,
                                  ),
                                  if (int.parse(rampPostQuantity.text) > 0) ...[
                                    rampPostTable(steps: int.parse(rampPostQuantity.text))
                                  ]
                                  // BuildTable(
                                  //     crotch:templatel['Crotch'],
                                  //     campo: 'upperFlatPost',
                                  //     crotchDistance: double.parse(templatel['topCrotchLength']))
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
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Upper Flat Post',
                                            style: kCardLabelStyle,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty : ',
                                                style: kCardLabelStyle,
                                              ),
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
      ),
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
      width: 380,
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
    return Container(
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
