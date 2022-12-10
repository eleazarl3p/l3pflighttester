import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l3pflighttester/screens/flight_editor.dart';
import '../models/flight_map.dart';
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

                   Map<String, dynamic> textFormFields = {
                    'id': '0',
                    "riser": '6.6875', //
                    "bevel": '7.31256',

                    "topCrotch": false,
                    "topCrotchLength": '0.0',
                    'hasBottomCrotchPost': false,

                    "bottomCrotch": false,
                    "bottomCrotchLength": '0.0',
                    'hasTopCrotchPost': false,

                    "lowerFlatPost": <Post>[
                      //Post(distance: 5.0, embeddedType: 'none')
                    ], //Post(distance: 10.0, embeddedType: 'sleeve')
                    "rampPost": <RampPost>[], //RampPost(nosingDistance: 0.0, balusterDistance: 0.0, embeddedType: 'none', step: 5)
                    "upperFlatPost": <Post>[], //Post(distance: 10.0, embeddedType: 'none')
                    "stepsCount": '15',
                     "lastNoseDistance" : '200',


                    'hypotenuse': 12.875,
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FlightEditor(pIndex: 0, sIndex: 0, fIndex: 0, template: textFormFields)
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
