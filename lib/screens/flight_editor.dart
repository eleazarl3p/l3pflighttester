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
import '../constants.dart';
import '../models/flight_map.dart';
import 'Home.dart';



final _formKey = GlobalKey<FormState>();

class FlightEditor extends StatefulWidget {
  FlightEditor({Key? key, required this.pIndex, required this.sIndex, required this.fIndex, required this.template})
      : super(key: key);

  int pIndex;
  int sIndex;
  int fIndex;
  final Map<String, dynamic> template;

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
        widget.template[campo].length,
        (index) => DataRow(cells: [
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
                  focusNode: widget.template[campo][index].pFocusNode,
                  controller: widget.template[campo][index].pController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => widget.template[campo][index].pController.selection = TextSelection(
                      baseOffset: 0, extentOffset: widget.template[campo][index].pController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      widget.template[campo][index].error = true;
                      return '';
                    }

                    if (crotch) {
                      List sublista = widget.template[campo].sublist(0, index + 1);
                      sumDistance =
                          sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.pController.text));

                      if (sumDistance >= crotchDistance && double.parse(value) != 0) {
                        widget.template[campo][index].error = true;

                        return "";
                      }
                    }

                    widget.template[campo][index].error = false;
                    return null;
                  },
                  decoration: kInputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!value) {
                    if (!widget.template[campo][index].error) {
                      widget.template[campo][index].distance =
                          double.parse(widget.template[campo][index].pController.text);
                    } else {
                      widget.template[campo][index].pFocusNode.requestFocus();
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
                value: widget.template[campo][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    widget.template[campo][index].embeddedType = value;
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
        widget.template['rampPost'].length,
        (index) => DataRow(cells: [
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
                  focusNode: widget.template['rampPost'][index].noseFocus,
                  controller: widget.template['rampPost'][index].noseController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => widget.template['rampPost'][index].noseController.selection = TextSelection(
                      baseOffset: 0, extentOffset: widget.template['rampPost'][index].noseController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      widget.template['rampPost'][index].noseError = true;
                      return '';
                    }


                    double noseValue = double.parse(value);
                    if (double.tryParse(lastNoseDistance.text) != null) {
                      if (noseValue >= double.parse(lastNoseDistance.text)) {
                        widget.template['rampPost'][index].noseError = true;
                        return "";
                      }
                    }

                    widget.template['rampPost'][index].noseError = false;
                    int step = (noseValue / widget.template['hypotenuse']).round()..toInt();
                    print('$step - $noseValue ${widget.template['hypotenuse']}');
                    widget.template['rampPost'][index].step = step + 1;
                    widget.template['rampPost'][index].nosingDistance = double.parse(value);
                    return null;
                  },
                  decoration: kInputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!lastNoseError) {
                    if (!value) {
                      if (widget.template['rampPost'][index].noseError) {
                        widget.template['rampPost'][index].noseFocus.requestFocus();
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
                  focusNode: widget.template['rampPost'][index].balusterFocus,
                  controller: widget.template['rampPost'][index].balusterController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: () => widget.template['rampPost'][index].balusterController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: widget.template['rampPost'][index].balusterController.value.text.length),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null || value.isEmpty) {
                      widget.template['rampPost'][index].balusterError = true;
                      return '';
                    }

                    // List sublista = widget.template['ramPost'].sublist(0, index + 1);
                    // sumDistance =
                    //     sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(element.noseController.text));
                    double noseValue = double.parse(value);
                    if (noseValue >= 10) {
                      widget.template['rampPost'][index].balusterError = true;
                      return "";
                    }

                    widget.template['rampPost'][index].balusterError = false;
                    widget.template['rampPost'][index].balusterDistance = double.parse(value);

                    return null;
                  },
                  decoration: kInputDec,
                  style: const TextStyle(fontSize: 14),
                ),
                onFocusChange: (value) {
                  if (!value) {
                    if (widget.template['rampPost'][index].balusterError) {
                      widget.template['rampPost'][index].balusterFocus.requestFocus();
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
                value: widget.template['rampPost'][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    widget.template['rampPost'][index].embeddedType = value;
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
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dibujo(widget.template)));
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
                style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Processing Data'),
                    backgroundColor: Colors.blueGrey.shade400,
                  ),
                );
              }
            },
            child: Container(
              width: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          ListTile(
            leading: Icon(Icons.list),
            title: Text('READ'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => const Home(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('SELECT'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ]),
      ),
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
                                      validator: (value) {
                                        if (double.tryParse(value!) == null) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      onTap: () => riserController.selection =
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
                                          widget.template['riser'] = riserController.text;
                                          double hypotenuse = sqrt(121 + pow(double.parse(riserController.text), 2));
                                          widget.template['hypotenuse'] = hypotenuse;
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
                                      decoration: kInputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (double.tryParse(bevelController.text) == null) {
                                          bevelFocus.requestFocus();
                                        } else {
                                          widget.template['bevel'] = bevelController.text;
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
                                      value: widget.template['bottomCrotch'],
                                      onChanged: (value) {
                                        if (value != null) {
                                          if (widget.template['lowerFlatPost'].isNotEmpty) {
                                            double sumDistance = 0;
                                            sumDistance = widget.template['lowerFlatPost'].fold(
                                                0,
                                                (sum, element) =>
                                                    sum.toDouble() + double.parse(element.pController.text));

                                            if (sumDistance >= double.parse(widget.template['bottomCrotchLength'])) {
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          widget.template['bottomCrotch'] = !widget.template['bottomCrotch'];
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
                                      enabled: widget.template['bottomCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => btcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: btcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          bottomFlatDistanceError = true;
                                          return "";
                                        }

                                        if (widget.template['lowerFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = widget.template['lowerFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            bottomFlatDistanceError = true;
                                            return "";
                                          }
                                        }
                                        widget.template['bottomCrotchLength'] = btcController.text;

                                        bottomFlatDistanceError = false;

                                        // //currentFocus = globalFocus;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: widget.template['bottomCrotch'] ? kInputDec : kInputDecDisable,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              widget.template['bottomCrotch'] ? Colors.black : Colors.blueGrey.shade50),
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
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Bot\u{00A0}Cr.\u{00A0}Post"),
                                MyTableCell(
                                  Checkbox(
                                      value: widget.template['hasBottomCrotchPost'],
                                      onChanged: widget.template['bottomCrotch']
                                          ? (value) {
                                              setState(() {
                                                widget.template['hasBottomCrotchPost'] =
                                                    !widget.template['hasBottomCrotchPost'];
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
                                      value: widget.template['topCrotch'],
                                      onChanged: (value) {
                                        if (value != null) {
                                          if (widget.template['upperFlatPost'].isNotEmpty) {
                                            double sumDistance = 0;
                                            sumDistance = widget.template['upperFlatPost'].fold(
                                                0,
                                                (sum, element) =>
                                                    sum.toDouble() + double.parse(element.pController.text));

                                            if (sumDistance >= double.parse(widget.template['topCrotchLength'])) {
                                              return;
                                            }
                                          }
                                        }
                                        setState(() {
                                          widget.template['topCrotch'] = !widget.template['topCrotch'];
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
                                      enabled: widget.template['topCrotch'],
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTap: () => tcController.selection =
                                          TextSelection(baseOffset: 0, extentOffset: tcController.value.text.length),
                                      validator: (value) {
                                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                          topFlatDistanceError = true;
                                          return "";
                                        }
                                        if (widget.template['upperFlatPost'].isNotEmpty) {
                                          double totDistance = 0;
                                          totDistance = widget.template['upperFlatPost']
                                              .fold(0, (previousValue, element) => previousValue + element.distance);

                                          if (double.parse(value) <= totDistance && totDistance != 0) {
                                            topFlatDistanceError = true;
                                            return "";
                                          }
                                        }

                                        widget.template['topCrotchLength'] = tcController.text;
                                        topFlatDistanceError = false;
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: widget.template['topCrotch'] ? kInputDec : kInputDecDisable,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: widget.template['topCrotch'] ? Colors.black : Colors.blueGrey.shade50),
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
                              ],
                            ),
                            Column(
                              children: [
                                MyTableCol(name: "Top\u{00A0}Cr.\u{00A0}Post"),
                                MyTableCell(
                                  Checkbox(
                                      value: widget.template['hasTopCrotchPost'],
                                      onChanged: widget.template['topCrotch']
                                          ? (value) {
                                              setState(() {
                                                widget.template['hasTopCrotchPost'] =
                                                    !widget.template['hasTopCrotchPost'];
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
                                        if (parseVal < widget.template['hypotenuse']) {
                                          lastNoseError = true;

                                          return '';
                                        }
                                        if (widget.template['rampPost'].isNotEmpty) {
                                          widget.template['rampPost'].forEach((rp) => {
                                                if (rp.nosingDistance > parseVal)
                                                  {lastNoseError = true, print(rp.nosingDistance)}
                                              });

                                          if (lastNoseError) {
                                            return '';
                                          }
                                        }

                                        lastNoseError = false;
                                        return null;
                                      },
                                      controller: lastNoseDistance,
                                      keyboardType: TextInputType.phone,
                                      decoration: kInputDec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onFocusChange: (value) {
                                      if (!lastNoseError) {
                                        double? lnd = double.tryParse(lastNoseDistance.text);
                                        double hypotenuse = widget.template['hypotenuse'];

                                        if (!(lnd == null)) {
                                          if (lnd >= hypotenuse) {
                                            int numSteps = (lnd / hypotenuse).round() + 1;

                                            setState(() {
                                              widget.template['stepsCount'] = numSteps.toString();
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
                                                          int listLpLen = widget.template['lowerFlatPost'].length;
                                                          if (numLP > 0) {
                                                            if (widget.template['lowerFlatPost'].length < numLP) {
                                                              for (int i = 0; i < (numLP - listLpLen); i++) {
                                                                widget.template['lowerFlatPost']
                                                                    .add(Post(distance: 0, embeddedType: 'none'));
                                                              }
                                                              setState(() {});
                                                            } else if (widget.template['lowerFlatPost'].length >
                                                                numLP) {
                                                              setState(() {
                                                                widget.template['lowerFlatPost'] =
                                                                    widget.template['lowerFlatPost'].sublist(0, numLP);
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              widget.template['lowerFlatPost'].clear();
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
                                        crotch: widget.template['bottomCrotch'],
                                        campo: 'lowerFlatPost',
                                        crotchDistance: double.parse(widget.template['bottomCrotchLength']))
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
                                                        int stepsCount = int.parse(widget.template['stepsCount']);
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
                                                        int listRpLen = widget.template['rampPost'].length;
                                                        int numRP = int.parse(rampPostQuantity.text);

                                                        if (!rampQuantityError) {
                                                          // If number of post to add in greater than zero
                                                          if (numRP > 0) {
                                                            // If number of post to add is minor than the amount of steps
                                                            if (numRP > listRpLen) {
                                                              for (int i = 0; i < (numRP - listRpLen); i++) {
                                                                widget.template['rampPost'].add(RampPost(
                                                                    nosingDistance: 0.0,
                                                                    balusterDistance: 5.5,
                                                                    embeddedType: 'none',
                                                                    step: 0));
                                                              }
                                                              setState(() {});
                                                            } else {
                                                              setState(() {
                                                                widget.template['rampPost'] =
                                                                    widget.template['rampPost'].sublist(0, numRP);
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              widget.template['rampPost'].clear();
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
                                  //     crotch: widget.template['Crotch'],
                                  //     campo: 'upperFlatPost',
                                  //     crotchDistance: double.parse(widget.template['topCrotchLength']))
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
                                                        int listLpLen = widget.template['upperFlatPost'].length;
                                                        if (numLP > 0) {
                                                          if (widget.template['upperFlatPost'].length < numLP) {
                                                            for (int i = 0; i < (numLP - listLpLen); i++) {
                                                              widget.template['upperFlatPost']
                                                                  .add(Post(distance: 0, embeddedType: 'none'));
                                                            }
                                                            setState(() {});
                                                          } else if (widget.template['upperFlatPost'].length > numLP) {
                                                            setState(() {
                                                              widget.template['upperFlatPost'] =
                                                                  widget.template['upperFlatPost'].sublist(0, numLP);
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            widget.template['upperFlatPost'].clear();
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
                                        crotch: widget.template['topCrotch'],
                                        campo: 'upperFlatPost',
                                        crotchDistance: double.parse(widget.template['topCrotchLength']))
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
