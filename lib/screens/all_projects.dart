import 'dart:convert';
//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:provider/provider.dart';

import '../DB/projectCollection.dart';
import '../file_storage_manager/secretaria.dart';
import '../models/Projects.dart';
import '../models/project.dart';
import '../models/stair.dart';
import '../widget/CustomActionButton.dart';
import 'all_stair_from_actual_project.dart';

//import '../Utils/dbConn.dart';

class ProjectsPage extends StatefulWidget {
  ProjectsPage({
    Key? key,
  }) : super(key: key);

  //final Projects tempProjects;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  TextEditingController projectNameController = TextEditingController();

  FocusNode miFocus = FocusNode();

  bool _error = false;

  bool load = true;

  @override
  void dispose() {
    projectNameController.dispose();
    miFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        centerTitle: true,
        actions: [
          CustomActionButton(
            txt: "New",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Project's name"),
                    content: Focus(
                      child: TextFormField(
                        controller: projectNameController,
                        focusNode: miFocus,
                        autofocus: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        autocorrect: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            _error = true;
                            return '';
                          }
                          _error = false;
                          return null;
                        },
                      ),
                      onFocusChange: (value) {
                        if (!value) {
                          if (_error) {
                            miFocus.requestFocus();
                          }
                        } else {
                          projectNameController.selection =
                              TextSelection(baseOffset: 0, extentOffset: projectNameController.value.text.length);
                        }
                      },
                    ),
                    actions: [
                      TextButton.icon(
                        onPressed: () {
                          if (projectNameController.text.length > 1) {
                            setState(() {
                              context
                                  .read<Projects>()
                                  .addProject(Project(id: projectNameController.text, stairs: <Stair>[]));
                              projectNameController.text = '';

                              Navigator.pop(context);
                            });
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text("OK"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          CustomActionButton(
              txt: "Save",
              onPressed: () {
                OurDataStorage.writeDocument("MyProjects", Provider.of<Projects>(context, listen: false).toJson());
              }),
          const SizedBox(
            width: 25.0,
          )
        ],
      ),

//       drawer: Drawer(
// child: ListView(
//   children: const [
//     DrawerHeader(decoration: BoxDecoration(
//       color: Colors.blue,
//     ),
//         child: Text('Drawer Header'))
//   ],
// ),
//       ),
      body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(width: 2.0, color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // const Center(
                    //   child: Text("Projects"),
                    // ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: context
                              .read<Projects>()
                              .projects
                              .length, //.projects.length, //context.select((Projects pj) => pj.projects.length),
                          itemBuilder: (context, index) {
                            return Card(
                              //color: Colors.brown.shade100,
                              child: ListTile(
                                leading: Checkbox(
                                  //activeColor: Colors.blueGrey,
                                  fillColor: MaterialStateProperty.all(Colors.blueGrey),
                                  checkColor: Colors.white,
                                  value: context.read<Projects>().projects[index].selected,
                                  onChanged: (value) {
                                    context.read<Projects>().projects[index].selected =
                                        !context.read<Projects>().projects[index].selected;
                                  },
                                ),
                                title: Text(
                                  context.read<Projects>().projects[index].id,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.blueGrey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => StairOnCurrentProject(pIndex: index),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Open'),
                                    ),
                                    const SizedBox(
                                      width: 15.0,
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          Project p = Project.copy(
                                              Provider.of<Projects>(context, listen: false).projects[index]);

                                          Provider.of<Projects>(context, listen: false).addProject(p);
                                        });
                                      },
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copy'),
                                    ),
                                    const SizedBox(
                                      width: 15.0,
                                    ),
                                    TextButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.red),
                                        foregroundColor: MaterialStateProperty.all(Colors.white),
                                      ),
                                      onPressed: () {
                                        Project p = Provider.of<Projects>(context, listen: false).projects[index];
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Are you sure you want to delete this project?"),
                                              content: Text('Project id: ${p.id}'),
                                              actions: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    setState(
                                                      () {
                                                        Provider.of<Projects>(context, listen: false).removeProject(p);
                                                      },
                                                    );

                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.check),
                                                  label: const Text("Yes"),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.cancel),
                                                  label: const Text("No"),
                                                ),
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
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}
