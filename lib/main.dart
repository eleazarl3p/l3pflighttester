//import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import '/screens/all_projects.dart';
import '/screens/all_stair_from_actual_project.dart';
import 'package:provider/provider.dart';
import '/screens/Home.dart';

import 'file_storage_manager/secretaria.dart';
import 'models/Projects.dart';
import 'models/flight_map.dart';
import 'models/project.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // Projects savedProjects = Projects();
  // OurDataStorage.readDocument('MyProjects');
  //print(anss);
  // try {
  //   await  OurDataStorage.readDocument('MyProjects');
  //
  // } catch(error) {
  //   print(error);
  // }

  /*try {
    print('saveddd: ${savedProjects.projects[0].id} 00');
  } catch (e) {
    print(e);
  }*/

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => Projects()),
      ChangeNotifierProvider(create: (context) => Project()),
      ChangeNotifierProvider(create: (context) => FlightMap())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  bool load = true;

  @override
  Widget build(BuildContext context) {
    if (load) {
      Projects pjs = context.read<Projects>();
      OurDataStorage.readDocument('MyProjects').then((value) {
        value['projects'].forEach((element) => pjs.addProject(Project.fromJson(element)));
        //print('local file ${pjs.projects}');
      }).catchError((e) {
        print('error ->  $e');
      });
      load = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
      ),

      //home: const Home(),
      routes: {'/': (context) => const ProjectsPage()},
    );
  }
}

// class HomeSt extends StatelessWidget {
//   const HomeSt({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Projects pjs = context.read<Projects>();
//     //print(' homest');
//
//     OurDataStorage.readDocument('MyProjects').then((value) {
//       value['projects'].forEach((element) => pjs.addProject(Project.fromJson(element)));
//       print('local file ${pjs.projects}');
//     }).catchError((e) {
//       print('error ->  $e');
//     });
//     return const ProjectsPage();
//   }
// }
