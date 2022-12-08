import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l3pflighttester/screens/flight_editor.dart';
import '/file_storage_manager/secretaria.dart';
import '../models/project.dart';
import '../models/stair.dart';
import '/models/Projects.dart';
import '/screens/cloud_display.dart';

import '/screens/all_projects.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print('object');
    final tempProjects = Projects();
    print('build');
    OurDataStorage.readDocument('MyProjects').then((value) {
      tempProjects.resetProject();
      //print(value['projects']);
      value['projects'].forEach((element) => tempProjects.massiveUpdate(Project.fromJson(element)));
      //print(tempProjects.projects);
      // Projects.fromJson(jsonEncode(value['projects']));
      // tempProjects.massiveUpdate(Project.fromJson(value['projects'][0]));
      // for (var pj in value['projects']) {
      //   print('pj: $pj' );
      //   //if(pj['stairs'].isNotEmpty){
      //
      //   // print(pj['stairs']);
      //   // tempProjects.massiveUpdate(Project.fromJson(pj));
      //   //}
      // }
    }).catchError((e) {
      print(e);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Home'),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CloudProjects(tempProjects: tempProjects),
                    ),
                  );
                },
                child: const Text('Cloud'),
              ),
            ),
            const SizedBox(
              width: 200,
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FlightEditor(pIndex: 0, sIndex: 0, fIndex: 0)
                      //     ProjectsPage(
                      //   tempProjects: tempProjects,
                      //   cloud: false,
                      // ),
                    ),
                  );
                },
                child: const Text('Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
