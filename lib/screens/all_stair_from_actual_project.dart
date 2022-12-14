import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:l3pflighttester/widget/CustomActionButton.dart';

import 'package:provider/provider.dart';
import '../DB/projectCollection.dart';

import '../constants.dart';
import '../file_storage_manager/secretaria.dart';
import '/screens/all_flight_on_actual_stair.dart';

import '../models/Projects.dart';
import '../models/stair.dart';

class StairOnCurrentProject extends StatefulWidget {
  StairOnCurrentProject({Key? key, required this.pIndex}) : super(key: key);

  final int pIndex;

  @override
  State<StairOnCurrentProject> createState() => _StairOnCurrentProjectState();
}

class _StairOnCurrentProjectState extends State<StairOnCurrentProject> {
  @override
  Widget build(BuildContext context) {
    final currentProject = Provider.of<Projects>(context, listen: true).projects[widget.pIndex];

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
              txt: 'Add Stair',
              onPressed: () {
                setState(() {
                  Provider.of<Projects>(context, listen: false).projects[widget.pIndex].addStair(Stair(id: ''));
                });
              }),
          CustomActionButton(
              txt: "Mail",
              onPressed: () async {
                try {
                  await OurDataStorage.clearTemporary();
                  List<String> direcciones = [];
                  var data;
                  var docpath = await OurDataStorage.temporaryDirectoryPath;

                  await currentProject.stairs.forEach((stair) => {
                        //data = jsonEncode(stair.toJson()['flights']),
                        if (!stair.onHold && stair.selected)
                          {
                            data = stair.toJson()['flights'],
                            OurDataStorage.writeTemporary('stair-${stair.id}', {'${stair.id}': data}),
                            direcciones.add('${docpath}/stair-${stair.id}.json')
                          }
                      });

                  final Email email = Email(
                    body: 'Hello, In attach ...',
                    subject: 'Project ${currentProject.id}',
                    recipients: [],
                    attachmentPaths: direcciones,
                    isHTML: false,
                  );

                  await FlutterEmailSender.send(email);
                } catch (err) {
                  print(err);
                }
              }),
          const SizedBox(
            width: 25.0,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
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
                      '${Provider.of<Projects>(context, listen: false).projects[widget.pIndex].id} ',
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
          const Divider(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                //color: Colors.grey[200],
                border: Border.all(width: 2.0, color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // const Center(
                  //   child: Text("Project > Stairs"),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: currentProject.stairs.length,
                      itemBuilder: ((context, index) {
                        return Card(
                          //color: Colors.brown.shade100,

                          child: ListTile(
                            minLeadingWidth: 200.0,
                            leading: SizedBox(
                              width: 200.0,
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: currentProject.stairs[index].selected,
                                      onChanged: (value) {
                                        setState(() {
                                          currentProject.stairs[index].selected =
                                              !currentProject.stairs[index].selected;
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
                                        onTap: () => currentProject.stairs[index].controller.selection = TextSelection(
                                            baseOffset: 0,
                                            extentOffset: currentProject.stairs[index].controller.value.text.length),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // title: Focus(
                            //   child: TextField(
                            //     autofocus: true,
                            //     decoration: const InputDecoration(
                            //       labelText: "Stair Id",
                            //       isDense: true,
                            //       contentPadding: EdgeInsets.all(8),
                            //       border: OutlineInputBorder(
                            //         borderSide: BorderSide(width: 1.0, color: Colors.blueGrey),
                            //       ),
                            //     ),
                            //     controller: currentProject.stairs[index].controller,
                            //     onChanged: (value) {
                            //       currentProject.stairs[index].setId = value;
                            //     },
                            //     onTap: () => currentProject.stairs[index].controller.selection = TextSelection(
                            //         baseOffset: 0,
                            //         extentOffset: currentProject.stairs[index].controller.value.text.length),
                            //   ),
                            // ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 30,
                                ),
                                const Text("On hold"),
                                Checkbox(
                                    value: currentProject.stairs[index].onHold,
                                    onChanged: (value) {
                                      setState(() {
                                        currentProject.stairs[index].onHold = !currentProject.stairs[index].onHold;
                                      });
                                    }),
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
                                          builder: (context) =>
                                              FlightOnActualStair(sIndex: index, pIndex: widget.pIndex, cloud: false),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit')),
                                const SizedBox(
                                  width: 10,
                                ),
                                TextButton.icon(
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
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
