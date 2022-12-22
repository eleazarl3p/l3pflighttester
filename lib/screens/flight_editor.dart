import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:l3pflighttester/widget/CustomIconActionButton.dart';
import '../Utils/unit_converter.dart';
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
  FlightEditor({Key? key, required this.pIndex, required this.sIndex, required this.fIndex, required this.template}) : super(key: key);

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

  bool riserError = false;
  bool bevelError = false;

  bool bottomFlatDistanceError = false;
  bool topFlatDistanceError = false;
  bool lowerQuantityError = false;
  bool upperQuantityError = false;
  bool balusterQuantityError = false;
  bool lastNoseError = false;

  bool eraserOn = false;

  final double hypotenuse = 12.8575;

  Map<String, dynamic> templateFlight = {};
  Map<String, dynamic> templateFlightDraw = {};

  UnitConverter unitConverter = UnitConverter();

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

    templateFlight = widget.template;

    // templateFlight['lowerFlatPost'] = [...templateFlight['lowerFlatPost']];
    // templateFlight['upperFlatPost'] = [...templateFlight['upperFlatPost']];
    // templateFlight['balusters'] = [...templateFlight['balusters']];

    int numStp = (double.parse(unitConverter.toInch(lastNoseDistance.text)) / hypotenuse).round() + 1;
    templateFlight['stepsCount'] = numStp.toString();
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

  onTap(bool eraserOn, TextEditingController controller) {
    print(controller.text);
    eraserOn
        ? () {
            print('enter 122');
            setState(() {
              print('enter');
              controller.text = '';
              eraserOn = false;
            });
          }
        : () => controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);
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
        templateFlight[campo].length,
        (index) => DataRow(cells: [
          DataCell(Text('$letter${index + 1}')),
          DataCell(
            Focus(
              child: TextFormField(
                focusNode: templateFlight[campo][index].pFocusNode,
                controller: templateFlight[campo][index].pController,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: eraserOn && _formKey.currentState!.validate()
                    ? () {
                        setState(() {
                          templateFlight[campo][index].pController.text = '';
                          eraserOn = false;
                        });
                      }
                    : () => templateFlight[campo][index].pController.selection =
                        TextSelection(baseOffset: 0, extentOffset: templateFlight[campo][index].pController.value.text.length),
                validator: (value) {
                  try {
                    if (!InputValidator.inchesValidator(value!)) {
                      templateFlight[campo][index].error = true;

                      return '';
                    }

                    if (crotch) {
                      List sublista = templateFlight[campo].sublist(0, index + 1);
                      sumDistance = sublista.fold(0, (sum, element) => sum.toDouble() + double.parse(unitConverter.toInch(element.pController.text)));

                      if (sumDistance >= crotchDistance && double.parse(unitConverter.toInch(value)) != 0) {
                        templateFlight[campo][index].error = true;

                        return "";
                      }
                    }

                    templateFlight[campo][index].error = false;
                    return null;
                  } catch (err) {
                    print(err.toString());
                    templateFlight[campo][index].error = true;
                    return "";
                  }
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!value) {
                  if (!templateFlight[campo][index].error) {
                    templateFlight[campo][index].distance = templateFlight[campo][index].pController.text;
                  } else {
                    templateFlight[campo][index].pFocusNode.requestFocus();
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
                value: templateFlight[campo][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    templateFlight[campo][index].embeddedType = value;
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
        templateFlight['balusters'].length,
        (index) => DataRow(cells: [
          DataCell(Text(alphabet[index])),
          DataCell(
            Focus(
              child: TextFormField(
                focusNode: templateFlight['balusters'][index].noseFocus,
                controller: templateFlight['balusters'][index].noseController,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: eraserOn && _formKey.currentState!.validate()
                    ? () {
                        setState(() {
                          templateFlight['balusters'][index].noseController.text = '';
                          eraserOn = false;
                        });
                      }
                    : () => templateFlight['balusters'][index].noseController.selection =
                        TextSelection(baseOffset: 0, extentOffset: templateFlight['balusters'][index].noseController.value.text.length),
                validator: (value) {
                  // if (value == null || double.tryParse(value) == null || value.isEmpty) {
                  //   templateFlight['balusters'][index].noseError = true;
                  //   return '';
                  // }
                  // String? valid = InputValidator.inchesValidator(value!);
                  try {
                    if (!InputValidator.inchesValidator(value!)) {
                      templateFlight['balusters'][index].noseError = true;
                      return '';
                    }
                    double noseValue = double.parse(unitConverter.toInch(value));
                    if (double.tryParse(unitConverter.toInch(lastNoseDistance.text)) != null) {
                      if (noseValue >= double.parse(unitConverter.toInch(lastNoseDistance.text))) {
                        templateFlight['balusters'][index].noseError = true;
                        return "";
                      }
                    }

                    templateFlight['balusters'][index].noseError = false;
                    int step = (noseValue / hypotenuse).round()..toInt();

                    templateFlight['balusters'][index].step = step + 1;
                    templateFlight['balusters'][index].nosingDistance = value;
                    return null;
                  } catch (err) {
                    print(err.toString());
                    templateFlight['balusters'][index].noseError = true;
                    return "";
                  }
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!lastNoseError) {
                  if (!value) {
                    if (templateFlight['balusters'][index].noseError) {
                      templateFlight['balusters'][index].noseFocus.requestFocus();
                    } else {
                      setState(() {
                        double noseValue = double.parse(unitConverter.toInch(lastNoseDistance.text));
                        int step = (noseValue / hypotenuse).round()..toInt();

                        templateFlight['balusters'][index].step = step + 1;
                        templateFlight['balusters'][index].nosingDistance = lastNoseDistance.text;
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
                focusNode: templateFlight['balusters'][index].balusterFocus,
                controller: templateFlight['balusters'][index].balusterController,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: eraserOn && _formKey.currentState!.validate()
                    ? () {
                        setState(() {
                          templateFlight['balusters'][index].balusterController.text = '';
                          eraserOn = false;
                        });
                      }
                    : () => templateFlight['balusters'][index].balusterController.selection =
                        TextSelection(baseOffset: 0, extentOffset: templateFlight['balusters'][index].balusterController.value.text.length),
                validator: (value) {
                  try {
                    if (!InputValidator.inchesValidator(value!)) {
                      templateFlight['balusters'][index].balusterError = true;
                      return '';
                    }
                    // if (value == null || double.tryParse(value) == null || value.isEmpty) {
                    //   templateFlight['balusters'][index].balusterError = true;
                    //   return '';
                    // }

                    double noseValue = double.parse(unitConverter.toInch(value));
                    if (noseValue >= 10) {
                      templateFlight['balusters'][index].balusterError = true;
                      return "";
                    }

                    templateFlight['balusters'][index].balusterError = false;
                    templateFlight['balusters'][index].balusterDistance = value;

                    return null;
                  } catch (err) {
                    print(err.toString());
                    return "";
                  }
                },
                decoration: kInputDec,
                style: const TextStyle(fontSize: 14),
              ),
              onFocusChange: (value) {
                if (!value) {
                  if (templateFlight['balusters'][index].balusterError) {
                    templateFlight['balusters'][index].balusterFocus.requestFocus();
                  } else {
                    setState(() {
                      templateFlight['balusters'][index].balusterDistance = templateFlight['balusters'][index].balusterController.text;
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
                value: templateFlight['balusters'][index].embeddedType,
                onChanged: (value) {
                  setState(() {
                    templateFlight['balusters'][index].embeddedType = value;
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

    TextStyle kCardLabelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        leading: const Text(''),
        title: const Text("Edit Flight"),
        actions: [
          CustomIconActionButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  eraserOn = !eraserOn;
                });
              }
            },
            color: eraserOn ? const Color(0x00FFFFFF) : const Color(0x77FFFFFF),
            //borderRadius: BorderRadius.circular(25),

            child: Icon(
              FontAwesomeIcons.eraser,
              size: 16.0,
              color: eraserOn ? Colors.amberAccent : Colors.blueGrey,
            ),
          ),
          CustomActionButton(
            child: const Text('View'),
            onPressed: () {
              templateFlightDraw = {...templateFlight};

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dibujo(templateFlightDraw)));
            },
          ),
          CustomActionButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CustomActionButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Map<String, dynamic> tempFlight = {
                  'id': templateFlight['id'],
                  "riser": riserController.text, //
                  "bevel": bevelController.text,

                  "topCrotch": templateFlight['topCrotch'],
                  "topCrotchLength": tcController.text,
                  'hasBottomCrotchPost': templateFlight['topCrotch'],
                  //
                  "bottomCrotch": templateFlight['bottomCrotch'],
                  "bottomCrotchLength": btcController.text,
                  'hasTopCrotchPost': templateFlight['hasBottomCrotchPost'],
                  //
                  "lowerFlatPost": [...templateFlight['lowerFlatPost']],
                  "balusters": [...templateFlight['balusters']],
                  "upperFlatPost": templateFlight['upperFlatPost'],
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

                await OurDataStorage.writeDocument("allProjects", Provider.of<Projects>(context, listen: false).toJson());

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
                            BlockContainer(
                              padding: const [10.0, 10.0],
                              width: 270,
                              children: [
                                Column(
                                  children: [
                                    MyTableCol(name: 'Riser'),
                                    MyTableCell(
                                      Focus(
                                        child: TextFormField(
                                          focusNode: riserFocus,
                                          controller: riserController,
                                          keyboardType: TextInputType.phone,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            try {
                                              if (InputValidator.inchesValidator(value!)) {
                                                return null;
                                              }
                                              return '';
                                            } catch (err) {
                                              print(err.toString());
                                              return "";
                                            }
                                          },
                                          onTap: eraserOn && _formKey.currentState!.validate()
                                              ? () {
                                                  setState(() {
                                                    riserController.text = '';
                                                    eraserOn = false;
                                                  });
                                                }
                                              : () => riserController.selection =
                                                  TextSelection(baseOffset: 0, extentOffset: riserController.value.text.length),
                                          decoration: kInputDec,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        onFocusChange: (value) {
                                          if (!value) {
                                            if (!InputValidator.inchesValidator(riserController.text)) {
                                              riserFocus.requestFocus();
                                            } else {
                                              setState(() {
                                                templateFlight['riser'] = riserController.text;
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
                                          keyboardType: TextInputType.phone,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onTap: eraserOn && _formKey.currentState!.validate()
                                              ? () {
                                                  setState(() {
                                                    bevelController.text = '';
                                                    eraserOn = false;
                                                  });
                                                }
                                              : () => bevelController.selection =
                                                  TextSelection(baseOffset: 0, extentOffset: bevelController.value.text.length),
                                          validator: (value) {
                                            try {
                                              if (InputValidator.inchesValidator(value!)) {
                                                return null;
                                              }
                                              return '';
                                            } catch (err) {
                                              return "";
                                            }
                                          },
                                          decoration: kInputDec,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        onFocusChange: (value) {
                                          if (!value) {
                                            if (!InputValidator.inchesValidator(bevelController.text)) {
                                              bevelFocus.requestFocus();
                                            } else {
                                              setState(() {
                                                templateFlight['bevel'] = bevelController.text;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Bottom Crotch
                            BlockContainer(
                                padding: const [10, 5],
                                blockName: 'Bottom Crotch',
                                width: 560,
                                children: [
                                  Column(
                                    children: [
                                      MyTableCol(name: 'Bot. Crotch'),
                                      MyTableCell(
                                        Checkbox(
                                            value: templateFlight['bottomCrotch'],
                                            onChanged: (value) {
                                              if (value != null) {
                                                if (templateFlight['lowerFlatPost'].isNotEmpty) {
                                                  double sumDistance = 0.0;
                                                  sumDistance = templateFlight['lowerFlatPost'].fold(
                                                      0,
                                                      (sum, element) =>
                                                          sum.toDouble() + double.parse(unitConverter.toInch(element.pController.text)));

                                                  if (sumDistance >= double.parse(unitConverter.toInch(templateFlight['bottomCrotchLength']))) {
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
                                                templateFlight['bottomCrotch'] = !templateFlight['bottomCrotch'];

                                                // uncheck bottom post if no bottom crotch is false;
                                                if (!value!) {
                                                  templateFlight['hasBottomCrotchPost'] = value;
                                                }
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      MyTableCol(name: 'Distance'),
                                      MyTableCell(
                                        Focus(
                                          child: TextFormField(
                                            focusNode: btcFocus,
                                            controller: btcController,
                                            keyboardType: TextInputType.phone,
                                            enabled: templateFlight['bottomCrotch'],
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onTap: eraserOn && _formKey.currentState!.validate()
                                                ? () {
                                                    setState(() {
                                                      btcController.text = '';
                                                      eraserOn = false;
                                                    });
                                                  }
                                                : () => btcController.selection =
                                                    TextSelection(baseOffset: 0, extentOffset: btcController.value.text.length),
                                            validator: (value) {
                                              // if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                              //   bottomFlatDistanceError = true;
                                              //   return "";
                                              // }

                                              try {
                                                if (!InputValidator.inchesValidator(value!)) {
                                                  bottomFlatDistanceError = true;
                                                  return "";
                                                }

                                                if (templateFlight['bottomCrotch']) {
                                                  if (templateFlight['lowerFlatPost'].isNotEmpty) {
                                                    double totDistance = 0;

                                                    totDistance = templateFlight['lowerFlatPost'].fold(
                                                        0,
                                                        (previousValue, element) =>
                                                            previousValue + double.parse(unitConverter.toInch(element.distance)));

                                                    if (double.parse(unitConverter.toInch(value)) <= totDistance && totDistance != 0) {
                                                      bottomFlatDistanceError = true;
                                                      return "";
                                                    }
                                                  }
                                                }

                                                bottomFlatDistanceError = false;

                                                // //currentFocus = globalFocus;
                                                return null;
                                              } catch (err) {
                                                return "";
                                              }
                                            },
                                            decoration: templateFlight['bottomCrotch'] ? kInputDec : kInputDecDisable,
                                            style: TextStyle(
                                                fontSize: 14, color: templateFlight['bottomCrotch'] ? Colors.black : Colors.blueGrey.shade50),
                                          ),
                                          onFocusChange: (value) {
                                            if (!value) {
                                              if (bottomFlatDistanceError) {
                                                btcFocus.requestFocus();
                                              } else {
                                                setState(() {
                                                  templateFlight['bottomCrotchLength'] = btcController.text;
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyTableCol(name: "Has Post"),
                                      MyTableCell(
                                        Checkbox(
                                            value: templateFlight['hasBottomCrotchPost'],
                                            onChanged: templateFlight['bottomCrotch']
                                                ? (value) {
                                                    setState(() {
                                                      templateFlight['hasBottomCrotchPost'] = !templateFlight['hasBottomCrotchPost'];
                                                    });
                                                  }
                                                : (value) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        duration: const Duration(milliseconds: 3000),
                                                        content: Text("Please add Bottom Crotch first.", style: kLabelAlert),
                                                        backgroundColor: kAlert,
                                                      ),
                                                    );
                                                  }),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      MyTableCol(name: "Embed.\u{00A0}Type"),
                                      Container(
                                        width: 110,
                                        alignment: Alignment.center,
                                        color: Colors.white,
                                        child: DropdownButton(
                                            elevation: 0,
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
                                            value: 'none',
                                            onChanged: (value) {
                                              setState(() {
                                                //templateFlight[campo][index].embeddedType = value;
                                              });
                                            }

                                            //widget.resetView();

                                            ),
                                      )
                                    ],
                                  ),
                                ]),
                            BlockContainer(
                                padding: const [10, 10],
                                width: 140,
                                children: [
                                  Column(
                                    children: [
                                      MyTableCol(name: "Last Nose"),
                                      MyTableCell(
                                        Focus(
                                          child: TextFormField(
                                            focusNode: lastNoseDistFocus,
                                            autocorrect: true,
                                            controller: lastNoseDistance,
                                            keyboardType: TextInputType.phone,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            onTap: eraserOn && _formKey.currentState!.validate()
                                                ? () {
                                                    setState(() {
                                                      lastNoseDistance.text = '';
                                                      eraserOn = false;
                                                    });
                                                  }
                                                : () => lastNoseDistance.selection =
                                                    TextSelection(baseOffset: 0, extentOffset: lastNoseDistance.value.text.length),
                                            validator: (value) {
                                              try {
                                                lastNoseError = false;
                                                if (!InputValidator.inchesValidator(value!)) {
                                                  lastNoseError = true;
                                                  return '';
                                                }

                                                double parseVal = double.parse(unitConverter.toInch(value));
                                                if (parseVal < hypotenuse) {
                                                  lastNoseError = true;
                                                  return '';
                                                }
                                                if (templateFlight['balusters'].isNotEmpty) {
                                                  templateFlight['balusters'].forEach((rp) => {
                                                        if (double.parse(unitConverter.toInch(rp.nosingDistance)) > parseVal) {lastNoseError = true}
                                                      });

                                                  if (lastNoseError) {
                                                    return '';
                                                  }
                                                }

                                                lastNoseError = false;
                                                return null;
                                              } catch (err) {
                                                print(err.toString());
                                              }
                                            },
                                            decoration: kInputDec,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          onFocusChange: (value) {
                                            if (!lastNoseError) {
                                              double? lnd = double.tryParse(unitConverter.toInch(lastNoseDistance.text));

                                              if (!(lnd == null)) {
                                                if (lnd >= hypotenuse) {
                                                  int numSteps = (lnd / hypotenuse).round() + 1;

                                                  setState(() {
                                                    templateFlight['stepsCount'] = numSteps.toString();
                                                    templateFlight['lastNoseDistance'] = lastNoseDistance.text;
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
                                ]),
                            // Top Crotch
                            BlockContainer(
                              padding: const [10, 5],
                              blockName: "Top Crotch",
                              width: 560,
                              children: [
                                Column(
                                  children: [
                                    MyTableCol(name: "Top\u{00A0}Crotch"),
                                    MyTableCell(
                                      Checkbox(
                                          value: templateFlight['topCrotch'],
                                          onChanged: (value) {
                                            if (value != null) {
                                              if (templateFlight['upperFlatPost'].isNotEmpty) {
                                                double sumDistance = 0;
                                                sumDistance = templateFlight['upperFlatPost'].fold(0,
                                                    (sum, element) => sum.toDouble() + double.parse(unitConverter.toInch(element.pController.text)));

                                                if (sumDistance >= double.parse(unitConverter.toInch(templateFlight['topCrotchLength']))) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(milliseconds: 3000),
                                                      content: Text(
                                                        "Total distance of the upper flat posts exceeds the distance value of the bottom crotch.",
                                                        style: kLabelAlert,
                                                      ),
                                                      backgroundColor: kAlert,
                                                    ),
                                                  );
                                                  return;
                                                }
                                              }
                                            }
                                            setState(() {
                                              templateFlight['topCrotch'] = !templateFlight['topCrotch'];

                                              // uncheck top crotch post if no crotch
                                              if (!value!) {
                                                templateFlight['hasTopCrotchPost'] = value;
                                              }
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    MyTableCol(name: "Top\u{00A0}Cr.\u{00A0}Dist."),
                                    MyTableCell(
                                      Focus(
                                        child: TextFormField(
                                          focusNode: tcFocus,
                                          controller: tcController,
                                          keyboardType: TextInputType.phone,
                                          enabled: templateFlight['topCrotch'],
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onTap: eraserOn && _formKey.currentState!.validate()
                                              ? () {
                                                  setState(() {
                                                    tcController.text = '';
                                                    eraserOn = false;
                                                  });
                                                }
                                              : () =>
                                                  tcController.selection = TextSelection(baseOffset: 0, extentOffset: tcController.value.text.length),
                                          validator: (value) {
                                            try {
                                              if (templateFlight['topCrotch']) {
                                                if (templateFlight['upperFlatPost'].isNotEmpty) {
                                                  double totDistance = 0;
                                                  totDistance = templateFlight['upperFlatPost'].fold(
                                                      0,
                                                      (previousValue, element) =>
                                                          previousValue + double.parse(unitConverter.toInch(element.distance.toString())));

                                                  if (double.parse(unitConverter.toInch(value)) <= totDistance && totDistance != 0) {
                                                    topFlatDistanceError = true;
                                                    return "";
                                                  }
                                                }
                                              }

                                              topFlatDistanceError = false;
                                              return null;
                                            } catch (err) {
                                              return "";
                                            }
                                          },
                                          decoration: templateFlight['topCrotch'] ? kInputDec : kInputDecDisable,
                                          style: TextStyle(fontSize: 14, color: templateFlight['topCrotch'] ? Colors.black : Colors.blueGrey.shade50),
                                        ),
                                        onFocusChange: (value) {
                                          if (!value) {
                                            if (topFlatDistanceError) {
                                              tcFocus.requestFocus();
                                            } else {
                                              templateFlight['topCrotchLength'] = tcController.text;
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    MyTableCol(name: "Top\u{00A0}Cr.\u{00A0}Post"),
                                    MyTableCell(
                                      Checkbox(
                                          value: templateFlight['hasTopCrotchPost'],
                                          onChanged: templateFlight['topCrotch']
                                              ? (value) {
                                                  setState(() {
                                                    templateFlight['hasTopCrotchPost'] = !templateFlight['hasTopCrotchPost'];
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
                                    MyTableCol(name: "Embed. Type"),
                                    MyTableCell(Container(
                                      color: Colors.white,
                                      height: 40,
                                      child: DropdownButton(
                                          elevation: 0,
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
                                          value: 'none',
                                          onChanged: (value) {
                                            setState(() {
                                              //templateFlight[campo][index].embeddedType = value;
                                            });
                                          }

                                          //widget.resetView();

                                          ),
                                    ))
                                    // Container(
                                    //   width: 110,
                                    //   alignment: Alignment.center,
                                    //   color: Colors.white,
                                    //   child: ,
                                    // )
                                  ],
                                )
                              ],
                            ),
                            // Last Nose
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
                                                        onTap: eraserOn && _formKey.currentState!.validate()
                                                            ? () {
                                                                setState(() {
                                                                  lowerPostQuantity.text = '';
                                                                  eraserOn = false;
                                                                });
                                                              }
                                                            : () {
                                                                lowerPostQuantity.selection =
                                                                    TextSelection(baseOffset: 0, extentOffset: lowerPostQuantity.value.text.length);
                                                              },
                                                        validator: (value) {
                                                          try {
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
                                                          } catch (err) {
                                                            return "";
                                                          }
                                                        },
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          if (!lowerQuantityError) {
                                                            int numLP = int.parse(lowerPostQuantity.text);
                                                            int listLpLen = templateFlight['lowerFlatPost'].length;
                                                            if (numLP > 0) {
                                                              if (templateFlight['lowerFlatPost'].length < numLP) {
                                                                for (int i = 0; i < (numLP - listLpLen); i++) {
                                                                  templateFlight['lowerFlatPost'].add(Post(distance: '0', embeddedType: 'none'));
                                                                }
                                                                setState(() {});
                                                              } else if (templateFlight['lowerFlatPost'].length > numLP) {
                                                                setState(() {
                                                                  templateFlight['lowerFlatPost'] = templateFlight['lowerFlatPost'].sublist(0, numLP);
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                templateFlight['lowerFlatPost'].clear();
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
                                  if (int.tryParse(lowerPostQuantity.text) != null && int.parse(lowerPostQuantity.text) > 0) ...[
                                    buildTable(
                                        crotch: templateFlight['bottomCrotch'],
                                        campo: 'lowerFlatPost',
                                        crotchDistance: double.parse(unitConverter.toInch(templateFlight['bottomCrotchLength'])))
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
                                                        onTap: eraserOn && _formKey.currentState!.validate()
                                                            ? () {
                                                                setState(() {
                                                                  lowerPostQuantity.text = '';
                                                                  eraserOn = false;
                                                                });
                                                              }
                                                            : () {
                                                                balusterQuantity.selection =
                                                                    TextSelection(baseOffset: 0, extentOffset: balusterQuantity.value.text.length);
                                                              },
                                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                                        validator: (value) {
                                                          try {
                                                            if (value == null) {
                                                              balusterQuantityError = true;
                                                              return '';
                                                            }

                                                            if (int.tryParse(value) == null) {
                                                              balusterQuantityError = true;
                                                              return '';
                                                            }

                                                            int numRP = int.parse(balusterQuantity.text);
                                                            int stepsCount = int.parse(templateFlight['stepsCount']);
                                                            if (numRP > 0) {
                                                              // If number of post to add is minor than the amount of steps
                                                              if (numRP > stepsCount) {
                                                                balusterQuantityError = true;
                                                                return '';
                                                              }
                                                            }
                                                            balusterQuantityError = false;
                                                            return null;
                                                          } catch (err) {
                                                            return "";
                                                          }
                                                        },
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          if (!balusterQuantityError) {
                                                            int listRpLen = templateFlight['balusters'].length;
                                                            int numRP = int.parse(balusterQuantity.text);
                                                            // If number of post to add in greater than zero
                                                            if (numRP > 0) {
                                                              // If number of post to add is minor than the amount of steps
                                                              if (numRP > listRpLen) {
                                                                for (int i = 0; i < (numRP - listRpLen); i++) {
                                                                  templateFlight['balusters'].add(BalusterPost(
                                                                      nosingDistance: '0.0', balusterDistance: '5.5', embeddedType: 'none', step: 0));
                                                                }
                                                                setState(() {});
                                                              } else {
                                                                setState(() {
                                                                  templateFlight['balusters'] = templateFlight['balusters'].sublist(0, numRP);
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                templateFlight['balusters'].clear();
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
                                  if (int.tryParse(balusterQuantity.text) != null && int.parse(balusterQuantity.text) > 0) ...[
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
                                                          upperPostQuantity.selection =
                                                              TextSelection(baseOffset: 0, extentOffset: upperPostQuantity.value.text.length);
                                                        },
                                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                                        validator: (value) {
                                                          try {
                                                            if (value == null) {
                                                              return '';
                                                            }

                                                            if (int.tryParse(value) == null) {
                                                              return '';
                                                            }

                                                            return null;
                                                          } catch (err) {
                                                            return "";
                                                          }
                                                        },
                                                        decoration: kInputDec,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                      onFocusChange: (value) {
                                                        if (!value) {
                                                          int numLP = int.parse(upperPostQuantity.text);
                                                          int listLpLen = templateFlight['upperFlatPost'].length;
                                                          if (numLP > 0) {
                                                            if (templateFlight['upperFlatPost'].length < numLP) {
                                                              for (int i = 0; i < (numLP - listLpLen); i++) {
                                                                templateFlight['upperFlatPost'].add(Post(distance: '0', embeddedType: 'none'));
                                                              }
                                                              setState(() {});
                                                            } else if (templateFlight['upperFlatPost'].length > numLP) {
                                                              setState(() {
                                                                templateFlight['upperFlatPost'] = templateFlight['upperFlatPost'].sublist(0, numLP);
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              templateFlight['upperFlatPost'].clear();
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
                                  if (int.tryParse(upperPostQuantity.text) != null && int.parse(upperPostQuantity.text) > 0) ...[
                                    buildTable(
                                        crotch: templateFlight['topCrotch'],
                                        campo: 'upperFlatPost',
                                        crotchDistance: double.parse(unitConverter.toInch(templateFlight['topCrotchLength'])))
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
      width: 110,
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

class InputValidator {
  static bool inchesValidator(String value) {
    RegExp ftSpaceFraction = RegExp(r'^(\d+) ((\d+)/(\d+))');
    RegExp ftDashInchSpaceFraction = RegExp(r'(\d+)-(\d+) (\d+)/(\d+)');
    RegExp ftDashInch = RegExp(r'(\d+)-(\d+)');
    RegExp ftOnly = RegExp(r'(\d+)');
    RegExp fractionOnly = RegExp(r'(\d+)/(\d+)');
    RegExp decimal = RegExp(r'(\d+)\.(\d+)');

    if (value.isNotEmpty) {
      if (ftSpaceFraction.firstMatch(value) != null && ftSpaceFraction.firstMatch(value)![0]?.length == value.length) {
        //print('fractionOnly p: ${ftSpaceFraction.firstMatch(value)![0]}');

        return true;
      } else if (ftDashInchSpaceFraction.firstMatch(value) != null && ftDashInchSpaceFraction.firstMatch(value)![0]?.length == value.length) {
        //print('fractionOnly: ${ftDashInchSpaceFraction.firstMatch(value)![0]}');
        return true;
      } else if (ftDashInch.firstMatch(value) != null && ftDashInch.firstMatch(value)![0]?.length == value.length) {
        //print('fractionOnly: ${ftDashInch.firstMatch(value)![0]}');
        return true;
      } else if (ftOnly.firstMatch(value) != null && ftOnly.firstMatch(value)![0]?.length == value.length) {
        //print('fractionOnly: ${ftOnly.firstMatch(value)![0]}');
        return true;
      } else if (fractionOnly.firstMatch(value) != null && fractionOnly.firstMatch(value)![0]?.length == value.length) {
        //print('fractionOnly: ${fractionOnly.firstMatch(value)![0]}');
        return true;
      } else if (decimal.firstMatch(value) != null && decimal.firstMatch(value)![0]?.length == value.length) {
        //print('object $value');
        return true;
      }
    }

    return false;
  }
}

class BlockContainer extends StatelessWidget {
  const BlockContainer({Key? key, this.blockName = '', required this.width, required this.children, required this.padding}) : super(key: key);

  final String blockName;
  final double width;
  final List<Widget> children;
  final List<double> padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      //
      decoration: blockName != ""
          ? BoxDecoration(border: Border.all(width: 1.0, color: Colors.blueGrey), borderRadius: BorderRadius.circular(5.0))
          : BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          blockName != ""
              ? Container(
                  alignment: Alignment.center,
                  height: 30,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                  child: Text(
                    blockName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : Text(''),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding[0], vertical: padding[1]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          )
        ],
      ),
    );
  }
}
