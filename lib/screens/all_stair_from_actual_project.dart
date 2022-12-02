import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'package:provider/provider.dart';
import '../DB/projectCollection.dart';

import '../file_storage_manager/secretaria.dart';
import '/screens/all_flight_on_actual_stair.dart';

import '../models/Projects.dart';
import '../models/stair.dart';

class StairOnCurrentProject extends StatefulWidget {
  StairOnCurrentProject({Key? key, required this.pIndex, this.cloud = false})
      : super(key: key);

  final int pIndex;
  final bool cloud;

  @override
  State<StairOnCurrentProject> createState() => _StairOnCurrentProjectState();
}

class _StairOnCurrentProjectState extends State<StairOnCurrentProject> {
  @override
  Widget build(BuildContext context) {
    final currentProject = context.watch<Projects>().projects[widget.pIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.cloud) {
              FBDB.update(
                  collection: 'projects',
                  document: currentProject.id,
                  data: {'data': currentProject.toJson()});

              FBDB.create('log', DateTime.now().toString(), {
                "user": 1,
                'action': 'update',
                'project': currentProject.id
              });
            }
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: ListTile(
          title: Text(
            'Project : ${currentProject.id}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: widget.cloud
              ? const Text(
                  'Cloud > Projects',
                  style: TextStyle(color: Colors.white),
                )
              : const Text(
                  'Local > Projects',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              backgroundBlendMode: BlendMode.colorBurn, color: Colors.white12),
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  thickness: 3.0,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(width: 2.0, color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
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
                                        leading: Checkbox(
                                            value: currentProject
                                                .stairs[index].selected,
                                            onChanged: (value) {
                                              setState(() {
                                                currentProject.stairs[index]
                                                        .selected =
                                                    !currentProject
                                                        .stairs[index].selected;
                                              });
                                            }),
                                        title: Container(
                                          // width: 200,
                                          // margin:
                                          //     const EdgeInsets.only(right: 150),
                                          child: Focus(
                                            child: TextField(
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                labelText: "Stair Id",
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.blueGrey),
                                                ),
                                              ),
                                              controller: TextEditingController(
                                                  text: currentProject
                                                      .stairs[index].id),
                                              onChanged: (value) {
                                                currentProject.stairs[index]
                                                    .setId = value;
                                              },
                                            ),
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text("On hold"),
                                            Checkbox(
                                                value: currentProject
                                                    .stairs[index].onHold,
                                                onChanged: (value) {
                                                  setState(() {
                                                    currentProject.stairs[index]
                                                            .onHold =
                                                        !currentProject
                                                            .stairs[index]
                                                            .onHold;
                                                  });
                                                }),
                                            TextButton.icon(
                                              onPressed: () {
                                                Stair str_ = currentProject
                                                    .stairs[index];
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
                                                          FlightOnActualStair(
                                                        sIndex: index,
                                                        pIndex: widget.pIndex,
                                                        cloud: widget.cloud,
                                                      ),
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
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Are you sure you want to delete this stair?"),
                                                      content: Text(
                                                          'Stair id: ${currentProject.stairs[index].id}'),
                                                      actions: [
                                                        TextButton.icon(
                                                            onPressed: () {
                                                              setState(
                                                                () {
                                                                  currentProject
                                                                      .removeStair(
                                                                          currentProject
                                                                              .stairs[index]);
                                                                },
                                                              );
                                                              if (widget
                                                                  .cloud) {
                                                                FBDB.update(
                                                                    collection:
                                                                        'projects',
                                                                    document: currentProject.id,
                                                                    data: {
                                                                      'data': currentProject
                                                                          .toJson()
                                                                    });

                                                                FBDB.create(
                                                                    'log',
                                                                    DateTime.now()
                                                                        .toString(),
                                                                    {
                                                                      "user": 1,
                                                                      'action':
                                                                          'add stair',
                                                                      //'project': currentProject.id
                                                                    });
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: const Icon(
                                                                Icons.check),
                                                            label: const Text(
                                                                "Yes")),
                                                        TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: const Icon(
                                                                Icons.cancel),
                                                            label: const Text(
                                                                "No"))
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
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
                      Expanded(
                        flex: 1,
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.cloud) {
                                      FBDB.update(
                                          collection: 'projects',
                                          document: currentProject.id,
                                          data: {
                                            'data': currentProject.toJson()
                                          });

                                      FBDB.create(
                                          'log', DateTime.now().toString(), {
                                        "user": 1,
                                        'action': 'add stair',
                                        //'project': currentProject.id
                                      });
                                    }
                                    setState(() {
                                      currentProject.addStair(Stair(id: ''));
                                    });
                                  },
                                  icon: const Icon(Icons.stairs),
                                  label: const Text("Add Stair"),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              // if (widget.cloud) ...[
                              //   SizedBox(
                              //     width: 200,
                              //     child: ElevatedButton.icon(
                              //       onPressed: () {
                              //
                              //         FBDB.update(
                              //             collection: 'projects',
                              //             document: currentProject.id,
                              //             data: {
                              //               'data': currentProject.toJson()
                              //             });
                              //
                              //         FBDB.create(
                              //             'log', DateTime.now().toString(), {
                              //           "user": 1,
                              //           'action': 'update',
                              //           'project': currentProject.id
                              //         });
                              //       },
                              //       icon: const Icon(Icons.update),
                              //       label: const Text("Update"),
                              //     ),
                              //   ),
                              // ],
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await OurDataStorage.clearTemporary();
                                    List<String> direcciones = [];
                                    var data;
                                    var docpath = await OurDataStorage
                                        .documentsDirectoryPath;
                                    currentProject.stairs.map((stair) => {
                                          data = jsonEncode(currentProject
                                              .stairs[0]
                                              .toJson()['flights']),
                                          OurDataStorage.writeTemporary(
                                              'stair ${currentProject.stairs[0].id}',
                                              {
                                                '${currentProject.stairs[0].id}':
                                                    data
                                              }),
                                          direcciones.add(
                                              '${docpath}/stair-${currentProject.stairs[0].id}}.json')
                                        });

                                    final Email email = Email(
                                      body: 'Hello, In attach the following',
                                      subject: 'Project ${currentProject.id}',
                                      recipients: ['example.user@gmail.com'],
                                      attachmentPaths: direcciones,
                                      isHTML: false,
                                    );

                                    await FlutterEmailSender.send(email);
                                  },
                                  icon: const Icon(Icons.send),
                                  label: const Text('Send'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
