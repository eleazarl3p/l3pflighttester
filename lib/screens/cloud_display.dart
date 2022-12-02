import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/file_storage_manager/secretaria.dart';
import '/models/Projects.dart';
import '/screens/all_stair_from_actual_project.dart';
import 'package:provider/provider.dart';

import '../DB/projectCollection.dart';
import '../models/project.dart';
import '../models/stair.dart';

class CloudProjects extends StatelessWidget {
  CloudProjects({Key? key, required this.tempProjects}) : super(key: key);

  Projects tempProjects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud'),
      ),
      body: Center(
        child: ProjectsInformation(tempProjects: tempProjects),
      ),
    );
  }
}

class ProjectsInformation extends StatelessWidget {
  ProjectsInformation({super.key, required this.tempProjects});

  final Projects tempProjects;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('projects').snapshots();

  @override
  Widget build(BuildContext context) {
    TextEditingController projectNameController = TextEditingController();

    FocusNode miFocus = FocusNode();

    bool _error = false;

    @override
    void dispose() {
      projectNameController.dispose();
      miFocus.dispose();
    }

    final pjsProvider = context.watch<Projects>();

    // save temporal projects
    tempProjects.resetProject();
    for (Project pj in pjsProvider.projects) {
      tempProjects.massiveUpdate(pj);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset('images/loading.gif');
        }

        pjsProvider.resetProject();
        List projects = snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          return Project.fromJson(data['data']);
        }).toList();

        for (Project pj in projects) {
          pjsProvider.massiveUpdate(pj);
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
                backgroundBlendMode: BlendMode.colorBurn,
                color: Colors.white12),
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
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 2.0, color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: pjsProvider.projects.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          //color: Colors.brown.shade100,
                                          child: ListTile(
                                            title: Text(
                                              pjsProvider.projects[index].id,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                  color: Colors.blueGrey),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StairOnCurrentProject(
                                                          pIndex: index,
                                                          cloud: true,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.open_in_new),
                                                  label: const Text('Open'),
                                                ),
                                                TextButton.icon(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Are you sure you want to delete this project?"),
                                                          content: Text(
                                                              'Project id: ${pjsProvider.projects[index].id}'),
                                                          actions: [
                                                            TextButton.icon(
                                                              onPressed: () {
                                                                FBDB.delete(
                                                                  'projects',
                                                                  pjsProvider
                                                                      .projects[
                                                                          index]
                                                                      .id,
                                                                );

                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              icon: const Icon(
                                                                  Icons.check),
                                                              label: const Text(
                                                                  "Yes"),
                                                            ),
                                                            TextButton.icon(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              icon: const Icon(
                                                                  Icons.cancel),
                                                              label: const Text(
                                                                  "No"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  label: const Text('Delete'),
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Project's name"),
                                            content: Focus(
                                              child: TextFormField(
                                                controller:
                                                    projectNameController,
                                                focusNode: miFocus,
                                                autofocus: true,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                autocorrect: true,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
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
                                                  projectNameController
                                                          .selection =
                                                      TextSelection(
                                                          baseOffset: 0,
                                                          extentOffset:
                                                              projectNameController
                                                                  .value
                                                                  .text
                                                                  .length);
                                                }
                                              },
                                            ),
                                            actions: [
                                              TextButton.icon(
                                                onPressed: () {
                                                  if (projectNameController
                                                          .text.length >
                                                      1) {
                                                    // pjsProvider.addProject(Project(
                                                    //     id: projectNameController
                                                    //         .text,
                                                    //     stairs: <Stair>[]));
                                                    // projectNameController.text = '';
                                                    Project npj = Project(
                                                        id: projectNameController
                                                            .text,
                                                        stairs: <Stair>[]);
                                                    FBDB.create(
                                                        'projects',
                                                        npj.id,
                                                        {'data': npj.toJson()});
                                                    Navigator.pop(context);
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
                                    icon: const Icon(Icons.new_label),
                                    label: const Text("New Project"),
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
        );
      },
    );
  }
}
