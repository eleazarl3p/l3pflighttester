import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:l3pflighttester/file_manager/PdfService.dart';

// import 'package:flutter_mailer/flutter_mailer.dart';
import '/widget/CustomActionButton.dart';

import 'package:provider/provider.dart';

import '../constants.dart';
import '../file_manager/secretary.dart';
import '/screens/all_flight_on_actual_stair.dart';

import '../models/Projects.dart';
import '../models/stair.dart';

class StairOnCurrentProject extends StatefulWidget {
  const StairOnCurrentProject({Key? key, required this.pIndex}) : super(key: key);

  final int pIndex;

  @override
  State<StairOnCurrentProject> createState() => _StairOnCurrentProjectState();
}

class _StairOnCurrentProjectState extends State<StairOnCurrentProject> {
  @override
  Widget build(BuildContext context) {
    final currentProject = Provider
        .of<Projects>(context, listen: true)
        .projects[widget.pIndex];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          //centerTitle: true,
          title: const Text("STAIRS"),
          actions: [
            CustomActionButton(
              child: const Text("Add Stair"),
              onPressed: () {
                setState(
                      () {
                    Provider
                        .of<Projects>(context, listen: false)
                        .projects[widget.pIndex].addStair(Stair(id: ''));
                  },
                );
              },
            ),
            CustomActionButton(
              child: const Text("Mail"),
              onPressed: () async {
                try {
                  // await OurDataStorage.clearTemporary();
                  List<String> directions = [];
                  //var data;
                  var docPath = await OurDataStorage.temporaryDirectoryPath;

                  Future writeData() async {
                    List<String> tempDirections = [];

                    for (Stair stair in currentProject.stairs) {
                      if (!stair.onHold && stair.selected) {
                        //data = stair.toJson()['flights'];
                        tempDirections.add('$docPath/Project: ${currentProject.id} - Stair: ${stair.id}.json');
                        tempDirections.add('$docPath/Project: ${currentProject.id} - Stair: ${stair.id}.pdf');
                        await OurDataStorage.writeTemporary(
                            'Project: ${currentProject.id} - Stair: ${stair.id}',

                            {
                              'id': stair.id,
                              'flights': stair.toJson()['flights']
                            }

                        );
                        //print({'flights': stair.toJson()['flights']});

                        await PdfService.createFile('$docPath/Project: ${currentProject.id} - Stair: ${stair.id}.pdf', stair);



                      }
                    }
                    return tempDirections;
                  }

                  directions = await writeData();

                  final Email email = Email(
                    body: 'Hello, In attach ...',
                    subject: 'Project ${currentProject.id} field sheck',
                    recipients: [],
                    attachmentPaths: directions,
                    isHTML: false,
                  );

                  String platformResponse = '-';

                  try {
                    await FlutterEmailSender.send(email).then((value) =>
                    // platformResponse = 'success',
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 5000),
                        content: const Text(
                          'Mail sent!!!',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        backgroundColor: Colors.blueGrey.shade400,
                      ),
                    ));
                  } catch (error) {
                    platformResponse = 'error 2 ${error.toString()}';
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 5000),
                        content: Text(
                          'err1 : $platformResponse',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                } catch (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 5000),
                      content: Text(
                        'err1 : ${err.toString()}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              },
            ),
            const SizedBox(
              width: 25.0,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                height: 50.0,
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Project : ',
                          style: kLabel600,
                        ),
                        Text(
                          '${Provider
                              .of<Projects>(context, listen: false)
                              .projects[widget.pIndex].id} ',
                          style: kLabelStyle,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: const Divider(),
              // ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: currentProject.stairs.length,
                  itemBuilder: ((context, index) {
                    return Card(
                      //color: Colors.brown.shade100,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 160.0,
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: currentProject.stairs[index].selected,
                                      onChanged: (value) {
                                        setState(() {
                                          currentProject.stairs[index].selected = !currentProject.stairs[index].selected;
                                        });
                                      }),
                                  Expanded(
                                    child: Focus(
                                      child: TextField(
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          labelText: "Stair Id",
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(8),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 1.0, color: Colors.blueGrey),
                                          ),
                                        ),
                                        controller: currentProject.stairs[index].controller,
                                        onChanged: (value) {
                                          currentProject.stairs[index].setId = value;
                                        },
                                        onTap: () =>
                                        currentProject.stairs[index].controller.selection =
                                            TextSelection(baseOffset: 0, extentOffset: currentProject.stairs[index].controller.value.text.length),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("On hold"),
                                Checkbox(
                                    value: currentProject.stairs[index].onHold,
                                    onChanged: (value) {
                                      setState(() {
                                        currentProject.stairs[index].onHold = !currentProject.stairs[index].onHold;
                                      });
                                    }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MediaQuery
                                  .of(context)
                                  .size
                                  .width > 600 ? MainAxisSize.min : MainAxisSize.max,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Stair str_ = currentProject.stairs[index];
                                    setState(() {
                                      currentProject.addStair(
                                        Stair.copy(str_),
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                ),
                                TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FlightOnActualStair(sIndex: index, pIndex: widget.pIndex, cloud: false),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open')),
                                Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: TextButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.red),
                                      foregroundColor: MaterialStateProperty.all(Colors.white),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Are you sure you want to delete this stair?"),
                                            content: Text('Stair id: ${currentProject.stairs[index].id}'),
                                            actions: [
                                              TextButton.icon(
                                                  onPressed: () {
                                                    setState(
                                                          () {
                                                        currentProject.removeStair(currentProject.stairs[index]);
                                                      },
                                                    );

                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.check),
                                                  label: const Text("Yes")),
                                              TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.cancel),
                                                  label: const Text("No"))
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: Container(
                                        padding: const EdgeInsets.only(right: 10.0),
                                        child: const Text(
                                          'Delete',
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      // child: ListTile(
                      //   minLeadingWidth: 200.0,
                      //   leading: SizedBox(
                      //     width: 200.0,
                      //     child: Row(
                      //       children: [
                      //         Checkbox(
                      //             value: currentProject.stairs[index].selected,
                      //             onChanged: (value) {
                      //               setState(() {
                      //                 currentProject.stairs[index].selected = !currentProject.stairs[index].selected;
                      //               });
                      //             }),
                      //         Expanded(
                      //           child: Focus(
                      //             child: TextField(
                      //               autofocus: true,
                      //               decoration: const InputDecoration(
                      //                 labelText: "Stair Id",
                      //                 isDense: true,
                      //                 contentPadding: EdgeInsets.all(8),
                      //                 border: OutlineInputBorder(
                      //                   borderSide: BorderSide(width: 1.0, color: Colors.blueGrey),
                      //                 ),
                      //               ),
                      //               controller: currentProject.stairs[index].controller,
                      //               onChanged: (value) {
                      //                 currentProject.stairs[index].setId = value;
                      //               },
                      //               onTap: () => currentProject.stairs[index].controller.selection =
                      //                   TextSelection(baseOffset: 0, extentOffset: currentProject.stairs[index].controller.value.text.length),
                      //             ),
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      //   trailing: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const SizedBox(
                      //         width: 30,
                      //       ),
                      //       const Text("On hold"),
                      //       Checkbox(
                      //           value: currentProject.stairs[index].onHold,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               currentProject.stairs[index].onHold = !currentProject.stairs[index].onHold;
                      //             });
                      //           }),
                      //       TextButton.icon(
                      //         onPressed: () {
                      //           Stair str_ = currentProject.stairs[index];
                      //           setState(() {
                      //             currentProject.addStair(
                      //               Stair.copy(str_),
                      //             );
                      //           });
                      //         },
                      //         icon: const Icon(Icons.copy),
                      //         label: const Text('Copy'),
                      //       ),
                      //       TextButton.icon(
                      //           onPressed: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => FlightOnActualStair(sIndex: index, pIndex: widget.pIndex, cloud: false),
                      //               ),
                      //             );
                      //           },
                      //           icon: const Icon(Icons.open_in_new),
                      //           label: const Text('Open')),
                      //       const SizedBox(
                      //         width: 10,
                      //       ),
                      //       TextButton.icon(
                      //         style: ButtonStyle(
                      //           backgroundColor: MaterialStateProperty.all(Colors.red),
                      //           foregroundColor: MaterialStateProperty.all(Colors.white),
                      //         ),
                      //         onPressed: () {
                      //           showDialog(
                      //             context: context,
                      //             builder: (BuildContext context) {
                      //               return AlertDialog(
                      //                 title: const Text("Are you sure you want to delete this stair?"),
                      //                 content: Text('Stair id: ${currentProject.stairs[index].id}'),
                      //                 actions: [
                      //                   TextButton.icon(
                      //                       onPressed: () {
                      //                         setState(
                      //                           () {
                      //                             currentProject.removeStair(currentProject.stairs[index]);
                      //                           },
                      //                         );
                      //
                      //                         Navigator.pop(context);
                      //                       },
                      //                       icon: const Icon(Icons.check),
                      //                       label: const Text("Yes")),
                      //                   TextButton.icon(
                      //                       onPressed: () {
                      //                         Navigator.pop(context);
                      //                       },
                      //                       icon: const Icon(Icons.cancel),
                      //                       label: const Text("No"))
                      //                 ],
                      //               );
                      //             },
                      //           );
                      //         },
                      //         icon: const Icon(Icons.delete),
                      //         label: Container(
                      //             padding: const EdgeInsets.only(right: 10.0),
                      //             child: const Text(
                      //               'Delete',
                      //             )),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ));
  }
}
