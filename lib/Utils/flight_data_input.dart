//import 'dart:html';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../DB/projectCollection.dart';
import '../models/project.dart';
import '/models/flight_map.dart';

import '../models/Projects.dart';

class FlightDataInput extends StatefulWidget {
  int pIndex;
  int sIndex;
  int fIndex;
  final bool cloud;

  FlightDataInput({Key? key, required this.pIndex, required this.sIndex, required this.fIndex, this.cloud = false})
      : super(key: key);

  //String flightName;
  bool load = true;

  @override
  State<FlightDataInput> createState() =>
      // ignore: no_logic_in_create_state
      _FlightDataInputState();
}

class _FlightDataInputState extends State<FlightDataInput> {
  _FlightDataInputState();

  late TextEditingController riserController = TextEditingController();
  late TextEditingController bevelController = TextEditingController();

  late TextEditingController topCrotchLengthController = TextEditingController();
  late TextEditingController bottomCrotchLengthController = TextEditingController();

  late TextEditingController stairsCountController = TextEditingController();
  late TextEditingController lowerFlatPostCountController = TextEditingController();
  late TextEditingController rampPostCountController = TextEditingController();
  late TextEditingController upperFlatPostCountController = TextEditingController();

  late TextEditingController stairNumberController = TextEditingController();
  late TextEditingController postDistanceController = TextEditingController();

  late bool _hasTopCrotch;
  late bool _hasBottomCrotch;
  late bool _hasBottomCrotchPost;

  late List<Post> _lowerFlatPost;
  late List<RampPost> _rampPost;
  late List<Post> _upperFlatPost;

  // int? _value = 1;
  //late String? _value;

  late double bottomCrotchLength; // = 30.0;
  late double topCrotchLength; // = 0.0;
  //late dynamic flatDistance;
  //late double postDistance;
  //late int stairNum;
  bool showbottomFlatPost = true;
  bool showRampPost = true;
  bool showupperFlatPost = true;
  bool bottomFlatPostEnable = true;
  bool topFlatPostEnable = true;
  bool bottomCrotchTextError = false;
  bool bottomFlatDistanceError = false;
  bool topFlatDistanceError = false;

  //late FocusNode currentFocus;
  late FocusNode btmFocus;
  late FocusNode riserFocus;
  late FocusNode upFlatFocus;
  late FocusNode bevelFocus;
  late FocusNode stepFocus;
  late FocusNode globalFocus;

  bool btmError = false;

  //bool upFlatError = false;

  @override
  void initState() {
    super.initState();
    // create focus
    //currentFocus = FocusNode();
    btmFocus = FocusNode();
    riserFocus = FocusNode();
    upFlatFocus = FocusNode();
    bevelFocus = FocusNode();
    stepFocus = FocusNode();
    globalFocus = FocusNode();

    /////////////
    ///
    FlightMap usript = FlightMap();
    //Map lastInputsValues = usript.textFormFields;
  }

  @override
  void dispose() {
    riserController.dispose();
    bevelController.dispose();
    stairsCountController.dispose();

    topCrotchLengthController.dispose();
    bottomCrotchLengthController.dispose();
    lowerFlatPostCountController.dispose();
    rampPostCountController.dispose();
    upperFlatPostCountController.dispose();

    //currentFocus.dispose();
    riserFocus.dispose();
    upFlatFocus.dispose();
    bevelFocus.dispose();
    stepFocus.dispose();
    globalFocus.dispose();

    super.dispose();
  }

  static const double containerWidth = 350.0;

  bool _enableBtn = true;

  final _formKkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userInputsProvider = context.read<FlightMap>();
    late Map lastInputsVal = userInputsProvider.textFormFields;

    if (widget.load) {
      riserController.text = lastInputsVal['riser']; //userInputs['riser'];
      bevelController.text = lastInputsVal['bevel'];

      stairsCountController.text = lastInputsVal['stairsCount'];

      topCrotchLengthController.text = lastInputsVal['topCrotchLength'];
      bottomCrotchLengthController.text = lastInputsVal['bottomCrotchLength'];

      _lowerFlatPost = lastInputsVal['lowerFlatPost'];
      _rampPost = lastInputsVal['rampPost'];
      _upperFlatPost = lastInputsVal['upperFlatPost'];

      _hasTopCrotch = lastInputsVal['topCrotch'];
      _hasBottomCrotch = lastInputsVal['bottomCrotch'];
      _hasBottomCrotchPost = lastInputsVal['hasBottomCrotchPost'];

      bottomCrotchLength = double.parse(lastInputsVal['bottomCrotchLength']);
      topCrotchLength = double.parse(lastInputsVal['topCrotchLength']);
      widget.load = false;
    } else {
      lastInputsVal = userInputsProvider.textFormFields;
      _lowerFlatPost = lastInputsVal['lowerFlatPost'];
      _rampPost = lastInputsVal['rampPost'];
      _upperFlatPost = lastInputsVal['upperFlatPost'];
    }

    double totDistance = 0;
    //print('reload $bottomCrotchLength | $topCrotchLength | total $totDistance');

    List<String> alphabet = List.generate(26, (index) => String.fromCharCode(index + 65));

    void resetView() {
      setState(() {});
    }

    //print('second $_enableBtn ${userInputsProvider.textFormFields["enableBtn"]}');
    return ListView(
      children: [
        Form(
          key: _formKkey,
          onChanged: () => setState(() {
            _enableBtn = _formKkey.currentState!.validate();
            //userInputsProvider.updateFields("enableBtn", _enableBtn);
            //print('first $_enableBtn');
          }),
          //autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              // Riser Text Field
              TextFormInput(
                containerWidth: containerWidth,
                controller: riserController,
                provider: userInputsProvider,
                inputLabel: "Riser",
                field: "riser",
                resetView: resetView,
                readOnly: false,
                //currentFocus: currentFocus,
                myFocus: riserFocus,
              ),
              // Bevel Text Field
              TextFormInput(
                containerWidth: containerWidth,
                controller: bevelController,
                provider: userInputsProvider,
                inputLabel: "Bevel",
                field: "bevel",
                resetView: resetView,
                readOnly: false,
                myFocus: bevelFocus,
              ),

              // Top Crotch
              SizedBox(
                width: containerWidth,
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Top Crotch:"),
                        Checkbox(
                            fillColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                            value: _hasTopCrotch,
                            onChanged: (value) {
                              _enableBtn
                                  //userInputsProvider.textFormFields['active']
                                  ? setState(() {
                                      _hasTopCrotch = !_hasTopCrotch;
                                      userInputsProvider.updateFields('topCrotch', _hasTopCrotch);

                                      if (_upperFlatPost.isNotEmpty) {
                                        totDistance = 0;
                                        totDistance = _upperFlatPost.fold(
                                            0, (previousValue, element) => previousValue + element.distance);

                                        if (double.parse(topCrotchLengthController.text) <= totDistance) {
                                          userInputsProvider.updateFields('active', false);
                                          topFlatPostEnable = false;
                                          upFlatFocus.requestFocus();
                                        }
                                      }
                                    })
                                  : null;
                            })
                      ]),
                      if (_hasTopCrotch) ...{
                        Focus(
                          child: TextFormField(
                            //onChanged: (value) {},
                            focusNode: upFlatFocus,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                topFlatDistanceError = true;
                                return "Please enter valid number";
                              }

                              if (_upperFlatPost.isNotEmpty) {
                                totDistance = 0;
                                totDistance = _upperFlatPost.fold(
                                    0, (previousValue, element) => previousValue + element.distance);

                                if (double.parse(value) <= totDistance && totDistance != 0) {
                                  topFlatDistanceError = true;
                                  return "";
                                }
                              }
                              // //currentFocus = globalFocus;
                              //topCrotchLength = double.parse(value);

                              topFlatDistanceError = false;
                              return null;
                            },
                            onTap: () => topCrotchLengthController.selection =
                                TextSelection(baseOffset: 0, extentOffset: topCrotchLengthController.value.text.length),
                            controller: topCrotchLengthController,
                            onChanged: (value) {},
                            decoration: const InputDecoration(labelText: "Distance"),
                            onEditingComplete: () {},
                          ),
                          onFocusChange: (value) {
                            if (!value) {
                              if (!topFlatDistanceError) {
                                userInputsProvider.updateFields('topCrotchLength', topCrotchLengthController.text);
                              } else {
                                upFlatFocus.requestFocus();
                              }
                            } else {
                              topCrotchLengthController.selection = TextSelection(
                                  baseOffset: 0, extentOffset: topCrotchLengthController.value.text.length);
                            }
                          },
                        ),
                      },
                    ],
                  ),
                ),
              ),

              // Bottom Croth
              SizedBox(
                width: containerWidth,
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Bottom Crotch:"),
                        Checkbox(
                            fillColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                            value: _hasBottomCrotch,
                            onChanged: (value) {
                              _enableBtn //userInputsProvider.textFormFields['active']
                                  ? setState(() {
                                      _hasBottomCrotch = !_hasBottomCrotch;
                                      userInputsProvider.updateFields('bottomCrotch', _hasBottomCrotch);

                                      if (_lowerFlatPost.isNotEmpty) {
                                        totDistance = 0;
                                        totDistance = _lowerFlatPost.fold(
                                            0, (previousValue, element) => previousValue + element.distance);

                                        if (double.parse(bottomCrotchLengthController.text) <= totDistance) {
                                          userInputsProvider.updateFields('active', false);
                                          bottomFlatPostEnable = false;
                                          btmFocus.requestFocus();
                                        }
                                      }
                                    })
                                  : null;
                            })
                      ]),
                      if (_hasBottomCrotch) ...{
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Bottom Crotch Post:"),
                            Checkbox(
                              fillColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                              value: _hasBottomCrotchPost,
                              onChanged: (value) {
                                _enableBtn //userInputsProvider.textFormFields['active']
                                    ? setState(() {
                                        _hasBottomCrotchPost = !_hasBottomCrotchPost;
                                        userInputsProvider.updateFields('hasBottomCrotchPost', _hasBottomCrotchPost);
                                      })
                                    : null;
                              },
                            ),
                          ],
                        ),
                        Focus(
                          child: TextFormField(
                            //onChanged: (value) {},
                            focusNode: btmFocus,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (btmFocus.hasFocus) {
                                if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                  bottomFlatDistanceError = true;
                                  return "Please enter valid number";
                                }

                                if (_lowerFlatPost.isNotEmpty) {
                                  totDistance = 0;
                                  totDistance = _lowerFlatPost.fold(
                                      0, (previousValue, element) => previousValue + element.distance);

                                  if (double.parse(value) <= totDistance && totDistance != 0) {
                                    bottomFlatDistanceError = true;
                                    return "";
                                  }
                                }
                                bottomCrotchLength = double.parse(value);

                                bottomFlatDistanceError = false;
                              }
                              // //currentFocus = globalFocus;
                              return null;
                            },
                            onTap: () => bottomCrotchLengthController.selection = TextSelection(
                                baseOffset: 0, extentOffset: bottomCrotchLengthController.value.text.length),
                            controller: bottomCrotchLengthController,
                            onChanged: (value) {},
                            decoration: const InputDecoration(labelText: "Distance"),
                            onEditingComplete: () {},
                          ),
                          onFocusChange: (value) {
                            if (!value) {
                              if (!bottomFlatDistanceError) {
                                userInputsProvider.updateFields('bottomCrotchLength', bottomCrotchLength.toString());
                              } else {
                                btmFocus.requestFocus();
                              }
                            } else {
                              bottomCrotchLengthController.selection = TextSelection(
                                  baseOffset: 0, extentOffset: bottomCrotchLengthController.value.text.length);
                            }
                          },
                        ),
                      },
                    ],
                  ),
                ),
              ),

              // // Stairs
              SizedBox(
                width: containerWidth,
                child: Focus(
                  child: TextFormField(
                    autocorrect: true,
                    autofocus: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(labelText: "Number of steps"),
                    controller: stairsCountController,
                    focusNode: stepFocus,
                    onTap: () => stairsCountController.selection =
                        TextSelection(baseOffset: 0, extentOffset: stairsCountController.value.text.length),
                    validator: (value) {
                      if (int.tryParse(value.toString()) == null || int.parse(value.toString()) <= 0) {
                        return "Please enter valid number";
                      }

                      return null;
                    },
                    onEditingComplete: () {
                      bool error = false;
                      if (int.tryParse(stairsCountController.text) != null) {
                        if (int.parse(stairsCountController.text) >= 1) {
                          userInputsProvider.updateFields('stairsCount', stairsCountController.text);
                        } else {
                          error = true;
                        }
                      } else {
                        error = true;
                      }

                      if (error) {
                        stepFocus.requestFocus();
                      }
                    },
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      bool error = false;
                      if (int.tryParse(stairsCountController.text) != null) {
                        if (int.parse(stairsCountController.text) >= 1) {
                          userInputsProvider.updateFields('stairsCount', stairsCountController.text);
                        } else {
                          error = true;
                        }
                      } else {
                        error = true;
                      }

                      if (error) {
                        stepFocus.requestFocus();
                      }
                    }
                  },
                ),
              ),

              if (_lowerFlatPost.isNotEmpty) ...[
                const SizedBox(
                  width: containerWidth,
                ),
              ],

              // Lower Flat Post Add Button
              Container(
                child: SizedBox(
                    width: containerWidth,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: SizedBox(
                              width: containerWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lower Flat Post',
                                    //style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showbottomFlatPost = !showbottomFlatPost;
                                        });
                                      },
                                      child: showbottomFlatPost
                                          ? const Icon(Icons.remove)
                                          : const Icon(Icons.remove_red_eye_outlined)),
                                  ElevatedButton(
                                      onPressed: _enableBtn //userInputsProvider.textFormFields['active']
                                          ? () {
                                              setState(() {
                                                Post newPost = Post(distance: 0.0, embeddedType: 'none');
                                                newPost.pController.text = "0.0";
                                                newPost.embeddedType = "none";
                                                _lowerFlatPost.add(newPost);
                                              });
                                              //newFlatPost(Post(distance: 0.0));
                                            }
                                          : null,
                                      child: const Icon(Icons.add))
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Divider(
                          height: 2.0,
                        ),
                        if (_lowerFlatPost.isNotEmpty && showbottomFlatPost) ...[
                          const SizedBox(
                            height: 10.0,
                          ),
                          FlatPostTable(
                            postList: _lowerFlatPost,
                            flatposition: "lowerFlatPost",
                            resetView: resetView,
                            alphabet: alphabet,
                            enableLosBtn: _enableBtn,
                            //upFocus: currentFocus,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ],
                    )),
              ),

              // Ramp Post Add button
              Container(
                //margin: const EdgeInsets.only(left: 20.0, right: 32),
                child: SizedBox(
                    width: containerWidth,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                              width: containerWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Post \u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}',
                                    //style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showRampPost = !showRampPost;
                                        });
                                      },
                                      child: showRampPost
                                          ? const Icon(Icons.remove)
                                          : const Icon(Icons.remove_red_eye_outlined)),
                                  ElevatedButton(
                                      style: const ButtonStyle(),
                                      onPressed: _enableBtn //userInputsProvider.textFormFields['active']
                                          ? () {
                                              RampPost rPost = RampPost(
                                                  nosingDistance: 0.0,
                                                  step: 0,
                                                  balusterDistance: 6.0,
                                                  embeddedType: 'none');
                                              rPost.balusterController.text = '5.5';
                                              rPost.noseController.text = '0.0';
                                              rPost.stepController.text = '0';

                                              setState(() {
                                                _rampPost.add(rPost);
                                                //_rampPost.sort(((a, b) => a.step.compareTo(b.step)));
                                                //_rampPost;
                                              });
                                            }
                                          : null,
                                      child: const Icon(Icons.add))
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Divider(
                          height: 2.0,
                        ),
                        if (_rampPost.isNotEmpty && showRampPost) ...[
                          const SizedBox(
                            height: 10.0,
                          ),
                          RampPostTable(
                            postList: _rampPost,
                            resetView: resetView,
                            enableLosBtn: _enableBtn,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ],
                    )),
              ),

              // Upper Flat Post Add Button
              Container(
                //margin: const EdgeInsets.only(left: 20.0, right: 32),
                child: SizedBox(
                    width: containerWidth,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                              width: containerWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Upper Flat Post',
                                    //style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showupperFlatPost = !showupperFlatPost;
                                        });
                                      },
                                      child: showupperFlatPost
                                          ? const Icon(Icons.remove)
                                          : const Icon(Icons.remove_red_eye_outlined)),
                                  ElevatedButton(
                                      onPressed: _enableBtn //userInputsProvider.textFormFields['active']
                                          ? () {
                                              setState(() {
                                                Post newPost = Post(distance: 0.0, embeddedType: 'none');
                                                newPost.pController.text = "0.0";
                                                newPost.embeddedType = "none";
                                                _upperFlatPost.add(newPost);
                                              });
                                            }
                                          : null,
                                      child: const Icon(Icons.add))
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Divider(
                          height: 2.0,
                        ),
                        if (_rampPost.isNotEmpty && showRampPost) ...[
                          const SizedBox(
                            height: 1.0,
                          )
                        ],
                        if (_upperFlatPost.isNotEmpty && showupperFlatPost) ...[
                          const SizedBox(
                            height: 10.0,
                          ),
                          FlatPostTable(
                            postList: _upperFlatPost,
                            flatposition: "upperFlatPost",
                            resetView: resetView,
                            alphabet: alphabet,
                            enableLosBtn: _enableBtn,
                            //upFocus: currentFocus,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ],
                    )),
              ),

              const SizedBox(
                width: containerWidth,
                height: 50.0,
              ),
              Container(
                  width: containerWidth,
                  height: 35,
                  margin: const EdgeInsets.only(right: 20.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKkey.currentState!.validate()) {
                          if (widget.cloud) {
                            // Project pjc = Provider.of<Projects>(context, listen: false)
                            //     .projects[widget.pIndex];
                            // FBDB.update(
                            //   collection: 'projects',
                            //   document: pjc.id,
                            //   data: {'data': pjc.toJson()},
                            // );
                            //
                            // FBDB.create(
                            //   'log',
                            //   DateTime.now().toString(),
                            //   {
                            //     "user": 1,
                            //     'action': 'update',
                            //     'project': pjc.id
                            //   },
                            // );
                          } else {
                            Provider.of<Projects>(context, listen: false)
                                .projects[widget.pIndex]
                                .stairs[widget.sIndex]
                                .flights[widget.fIndex]
                                .updateFlight(userInputsProvider.textFormFields);
                          }
                          //   Map flight = Map.from(userInputsProvider.textFormFields);
                          //   myFlights.addFlight(widget.flightName, flight);
                          //   // UserInput flight = userInputsProvider.textFormFields;
                          //   // myFlights.addFlight(widget.flightNumber, flight);

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save")))
            ],
          ),
        )
      ],
    );
  }
}

class TextFormInput extends StatelessWidget {
  TextFormInput({
    Key? key,
    required this.containerWidth,
    required this.controller,
    required this.provider,
    required this.inputLabel,
    required this.field,
    this.padding = 10.0,
    required this.resetView,
    required this.readOnly,

    //required this.validator
    //required this.currentFocus,
    required this.myFocus,
  }) : super(key: key);

  final double containerWidth;
  final TextEditingController controller;
  final FlightMap provider;
  final String inputLabel;
  final String field;
  final double padding;
  bool readOnly;

  //final VoidCallback resetView;
  //final VoidCallback resetView;
  //final String validator;
  final VoidCallback resetView;

  //late FocusNode currentFocus;
  final FocusNode myFocus;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding),
      child: SizedBox(
        width: containerWidth,
        child: Focus(
          child: TextFormField(
            focusNode: myFocus,
            keyboardType: TextInputType.number,
            //autofocus: true,
            //autocorrect: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty || double.tryParse(value) == null) {
                //currentFocus = myFocus;
                _error = true;
                //provider.updateFields('active', false);

                return "Please enter valid number";
              }
              //provider.updateFields(field, controler.text);
              //currentFocus = FocusNode();
              _error = false;
              //provider.updateFields('active', true);
              return null;
            },
            onTap: () =>
                controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length),
            controller: controller,
            decoration: InputDecoration(
              labelText: inputLabel,
            ),
            // onEditingComplete: () {
            //   if (controler.value.text.trim().isNotEmpty || double.tryParse(controler.value.text) != null) {
            //     provider.updateFields(field, controler.text);
            //   }
            // },
          ),
          onFocusChange: (value) {
            if (!value) {
              if (!_error) {
                if (controller.value.text.trim().isNotEmpty || double.tryParse(controller.value.text) != null) {
                  provider.updateFields(field, controller.text);

                  resetView();
                }
              } else {
                myFocus.requestFocus();
              }
            } else {
              //currentFocus.requestFocus();
              //print('request 1 $currentFocus');
            }
          },
        ),
      ),
    );
  }
}
