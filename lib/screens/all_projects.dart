import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../file_manager/secretary.dart';
import '../models/Projects.dart';
import '../models/project.dart';
import '../models/stair.dart';
import '../widget/CustomActionButton.dart';
import 'all_stair_from_actual_project.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({
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
    Projects ppj = context.watch<Projects>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROJECTS'),
        //centerTitle: true,
        actions: [
          CustomActionButton(
            child: const Text("New"),
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
              child: const Text("Save"),
              onPressed: () async {
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
              }),
          const SizedBox(
            width: 25.0,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: const BoxDecoration(),
        child: ListView.builder(
            itemCount: ppj.projects.length,
            itemBuilder: (context, index) {
              return Card(
                //color: Colors.brown.shade100,
                child: ListTile(
                  leading: SizedBox(
                    width: 200,
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Project Id",
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0, color: Colors.blueGrey),
                        ),
                      ),
                      controller: context.read<Projects>().projects[index].controller,
                      onChanged: (value) {
                        context.read<Projects>().projects[index].setId = value;
                      },
                      onTap: () => context.read<Projects>().projects[index].controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: context.read<Projects>().projects[index].controller.value.text.length),
                    ),
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
                            Project p = Project.copy(Provider.of<Projects>(context, listen: false).projects[index]);

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
    );
  }
}
